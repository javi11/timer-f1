import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_f1/app/data/models/app_settings.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/data/providers/app_settings_provider.dart';
import 'package:timer_f1/app/data/providers/ble_provider.dart';
import 'package:timer_f1/core/pepe_timer/pepe_timer_commands.dart';
import 'package:timer_f1/core/vicent_timer/vicent_get_firmware.dart';
import 'package:timer_f1/core/vicent_timer/vicent_timer_commands.dart';

const maxTimerDataLength = 20;
const timerName = 'DSD TECH';
Uuid timerServiceUUID = Uuid.parse('0000ffe0-0000-1000-8000-00805f9b34fb');
Uuid timerCharacteristicUUID =
    Uuid.parse('0000ffe1-0000-1000-8000-00805f9b34fb');

final bleControllerProvider =
    ChangeNotifierProvider<BLEController>((ref) => FlutterReactiveBleController(
          ble: ref.watch(bleProvider),
          appSettings: ref.read(appSettingsProvider),
        ));

class BluetoothOffException implements Exception {
  String cause;
  BluetoothOffException(this.cause);
}

abstract class BLEController extends ChangeNotifier {
  UnmodifiableListView<Device> get scannedDevices;
  BluetoothState get bluetoothState;
  Device? get connectedDevice;
  Device? get pairedDevice;
  Device? get deviceConnectingTo;
  bool autoReconnect = true;
  Future<void> authorize();
  Future<void> pairDevice(Device device);
  Future<void> forgetDevice(Device device);
  StreamSubscription<DiscoveredDevice>? startScan(
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)});
  Future<void> stopScan();
  Future<void> connect(Device device,
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)});
  Future<void> disconnect();
  Stream<String> subscribeToDeviceDataStream();
}

class FlutterReactiveBleController extends ChangeNotifier
    implements BLEController {
  final FlutterReactiveBle ble;
  final AppSettings appSettings;
  late StreamSubscription<BleStatus>? _btHWStatusStreamSub;
  final List<Device> _scannedDevices = [];
  BluetoothState _bluetoothState = BluetoothState.off;
  Device? _connectedDevice;
  Device? _pairedDevice;
  Device? _deviceConnectingTo;
  StreamSubscription<ConnectionStateUpdate>? _connectionStream;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  Timer? _reconnectionTimer;
  Timer? _scanTimeout;
  CancelableOperation<void>? _connectionFuture;
  Stream<String>? _characteristicStream;
  int _dataSubscribers = 0;
  bool _autoReconnect = true;
  bool _disposed = false;

  @override
  set autoReconnect(bool value) {
    if (value == false) {
      _reconnectionTimer?.cancel();
    }
    _autoReconnect = value;
  }

  @override
  bool get autoReconnect => _autoReconnect;

  @override
  Device? get deviceConnectingTo => _deviceConnectingTo;

  @override
  Device? get pairedDevice => _pairedDevice;

  @override
  Device? get connectedDevice => _connectedDevice;

  @override
  BluetoothState get bluetoothState => _bluetoothState;

  @override
  UnmodifiableListView<Device> get scannedDevices =>
      UnmodifiableListView(_scannedDevices);

  FlutterReactiveBleController({required this.ble, required this.appSettings}) {
    _btHWStatusStreamSub = ble.statusStream.listen(_handleBluetoothHWUpdates);
  }

  @override
  Future<void> authorize() async {
    await Permission.locationWhenInUse.request();
  }

  @override
  Future<void> pairDevice(Device device) async {
    appSettings.savePairDevice(device);
    _pairedDevice = device;
  }

  @override
  Future<void> forgetDevice(Device device) async {
    print('BLE_CONTROLLER: Removing device ${device.id}');
    _reconnectionTimer?.cancel();
    await disconnect();
    _pairedDevice = null;
    if (_bluetoothState != BluetoothState.off) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
    }
    appSettings.removePairedDevice();
  }

  @override
  StreamSubscription<DiscoveredDevice> startScan(
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)}) {
    _scannedDevices.clear();
    _bluetoothState = BluetoothState.scanning;
    notifyListeners();
    _scanSub?.cancel();
    _scanTimeout?.cancel();
    _scanSub = ble.scanForDevices(
        withServices: [timerServiceUUID],
        scanMode:
            ScanMode.lowPower).listen(_addScanResult, onError: _onScanError);
    _scanTimeout = Timer(timeLimit, () {
      if (_bluetoothState == BluetoothState.scanning) {
        _bluetoothState = BluetoothState.scanTimeout;
        notifyListeners();
        _scanSub?.cancel();
      }
      onTimeout?.call();
    });
    return _scanSub!;
  }

  @override
  Future<void> stopScan() async {
    if (_bluetoothState == BluetoothState.scanning) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
      _scanTimeout?.cancel();
      await _scanSub?.cancel();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  Future<void> connect(Device device,
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)}) async {
    String deviceId = device.id;

    if (_connectionStream == null) {
      try {
        await ble.clearGattCache(deviceId);
        print('BLE_CONTROLLER: Device $deviceId Gatt cleared on Hot Reload.');
      } catch (e) {
        print('BLE_CONTROLLER: Device $deviceId $e.');
      }
      print('BLE_CONTROLLER: Adding connection stream for $deviceId');
      await stopScan();
      _deviceConnectingTo = device;
      _bluetoothState = BluetoothState.connecting;
      notifyListeners();
      _connectionStream = ble
          .connectToAdvertisingDevice(
              id: deviceId,
              prescanDuration: timeLimit,
              withServices: [timerServiceUUID],
              connectionTimeout: timeLimit)
          .listen(_handleConnectionEvents, onError: _handleConnectionErrors);
    }
  }

  @override
  Future<void> disconnect() async {
    print('BLE_CONTROLLER: Disconnecting from ${_connectedDevice?.id}');
    await _cleanOnDisconnect();
    if (_bluetoothState == BluetoothState.connecting ||
        _bluetoothState == BluetoothState.connected) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    await clean();
    await ble.deinitialize();
    _disposed = true;
    super.dispose();
  }

  Future<void> clean() async {
    _pairedDevice = null;
    _scanTimeout?.cancel();
    await _cleanOnDisconnect();
    await _btHWStatusStreamSub?.cancel();
    await _connectionFuture?.cancel();
  }

  Future<void> _cleanOnDisconnect() async {
    try {
      _reconnectionTimer?.cancel();
      _connectedDevice = null;
      _deviceConnectingTo = null;
      _characteristicStream = null;
      _scanTimeout?.cancel();
      await _connectionStream?.cancel();
      _connectionStream = null;
      await _connectionFuture?.cancel();
      _connectionFuture = null;
    } catch (e) {
      print('BLE_CONTROLLER: Unhandled error on disconnect from device, $e');
    }
  }

  void _retryConnection() {
    if (_autoReconnect == true &&
        _bluetoothState != BluetoothState.off &&
        _pairedDevice != null &&
        !_disposed &&
        (_reconnectionTimer == null || _reconnectionTimer!.isActive == false)) {
      print(
          'BLE_CONTROLLER: Reconnecting to ${_pairedDevice!.id} in 6 seconds.');
      _reconnectionTimer = Timer.periodic(Duration(seconds: 6), (timer) async {
        if (_pairedDevice != null && _autoReconnect == true) {
          _connectionFuture =
              CancelableOperation.fromFuture(connect(_pairedDevice!));
        }
        _reconnectionTimer?.cancel();
      });
    }
  }

  void _handleBluetoothHWUpdates(BleStatus state) async {
    switch (state) {
      case BleStatus.ready:
        if (_bluetoothState == BluetoothState.unauthorized ||
            _bluetoothState == BluetoothState.off) {
          _bluetoothState = BluetoothState.on;
          _pairedDevice = appSettings.getPairDevice();
          print(
              'BLE_CONTROLLER: Device paired ${_pairedDevice!.id}, retrying connection.');
          _retryConnection();
        }
        break;
      case BleStatus.unauthorized:
        _bluetoothState = BluetoothState.unauthorized;
        notifyListeners();
        await authorize();
        break;
      case BleStatus.unknown:
        _scannedDevices.clear();
        break;
      default: // Off, unauthorized, unavailable
        await _cleanOnDisconnect();
        _scannedDevices.clear();
        _bluetoothState = BluetoothState.off;
    }
    notifyListeners();
  }

  Future<void> _sendData(QualifiedCharacteristic characteristic, String data,
      {String endOf = ''}) async {
    try {
      var toSend = data + endOf;
      while (toSend.length >= maxTimerDataLength) {
        //Prepare first message
        var message = toSend.substring(0, maxTimerDataLength);
        try {
          await ble.writeCharacteristicWithoutResponse(characteristic,
              value: utf8.encode(message));
        } catch (e) {}

        //Update remaining data
        toSend = toSend.substring(maxTimerDataLength, toSend.length);

        //Wait 500 milliseconds before sending more data
        await Future.delayed(Duration(milliseconds: 500));
      }
      //Send remaining data
      await ble.writeCharacteristicWithoutResponse(characteristic,
          value: utf8.encode(toSend));
    } catch (ex) {
      print(
          'BLE_CONTROLLER: Caught error when sending data to timer: $ex. Data: $data');
    }
  }

  void _handleConnectionEvents(ConnectionStateUpdate event) {
    switch (event.connectionState) {
      case DeviceConnectionState.connecting:
        _deviceConnectingTo?.connectionState = DeviceConnection.connecting;
        _bluetoothState = BluetoothState.connecting;
        print('BLE_CONTROLLER: Connecting to ${event.deviceId}');
        notifyListeners();
        break;
      case DeviceConnectionState.connected:
        _connectedDevice = _deviceConnectingTo;
        _connectedDevice!.connectionState = DeviceConnection.connected;
        _deviceConnectingTo = null;
        _bluetoothState = BluetoothState.connected;
        print('BLE_CONTROLLER: Connected to ${event.deviceId}');
        _connectedDevice!.connectionState = DeviceConnection.handshaking;
        notifyListeners();
        _connectionFuture = CancelableOperation.fromFuture(_initialHandShake());
        break;
      case DeviceConnectionState.disconnected:
        _characteristicStream = null;
        _deviceConnectingTo = null;
        _connectedDevice?.connectionState = DeviceConnection.disconnected;
        _connectedDevice = null;
        _connectionStream?.cancel();
        _connectionStream = null;
        _bluetoothState = BluetoothState.on;
        print('BLE_CONTROLLER: Disconnected from ${event.deviceId}');
        _retryConnection();
        notifyListeners();
        break;
      case DeviceConnectionState.disconnecting:
        print('BLE_CONTROLLER: Disconnecting from ${event.deviceId}');
        break;
    }
  }

  Future<void> _initialHandShake() async {
    print('BLE_CONTROLLER: Initial handshake for ${_connectedDevice!.id}');
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: timerCharacteristicUUID,
        serviceId: timerServiceUUID,
        deviceId: _connectedDevice!.id);

    Brand brand = Brand.unknown;
    String firmware = 'unknown';
    var sub = subscribeToDeviceDataStream().handleError((error) {
      print('BLE_CONTROLLER: Error on Initial handshake, $error');
      print('BLE_CONTROLLER: Retrying handshake from the beginning.');
      _connectionFuture?.cancel();
      _connectionFuture = CancelableOperation.fromFuture(_initialHandShake());
    }).listen((value) {
      var currentFirmware = getVicentFirmwareVersion(value);
      if (currentFirmware != null) {
        brand = Brand.vicent;
        firmware = currentFirmware;
      } else if (value.length == PepeTimerDataFrameLenght) {
        brand = Brand.pepe;
      }
    });

    await Future.doWhile(() async {
      print('BLE_CONTROLLER: Retrying handshake.');

      await _sendData(characteristic, VicentTimerCommands.getHelp, endOf: '\n');
      await Future.delayed(Duration(milliseconds: 1000));
      /*  await _sendData(characteristic, PepeTimerCommands.downloadConfiguration,
          endOf: '\n'); */

      if (brand != Brand.unknown ||
          _bluetoothState != BluetoothState.connected ||
          _disposed) {
        await sub.cancel();
        return false;
      }

      //Wait two seconds before retrying again
      await Future.delayed(Duration(seconds: 10));

      return true;
    });

    if (_connectedDevice != null) {
      print(
          'BLE_CONTROLLER: Device brand for ${_connectedDevice!.id} is $brand and has firmware $firmware.');
      _connectedDevice!.brand = brand;
      _connectedDevice!.firmware = firmware;
      _connectedDevice!.connectionState = DeviceConnection.connected;
      appSettings.savePairDevice(_connectedDevice!);
      notifyListeners();
    } else {
      print('BLE_CONTROLLER: Device disconnected before initial HandShake');
    }
  }

  void _handleConnectionErrors(error) async {
    print(
        'BLE_CONTROLLER: Error on ${_deviceConnectingTo?.id} connection, $error');
    _bluetoothState = BluetoothState.connectionTimeout;
    _deviceConnectingTo = null;
    _connectedDevice = null;
    await _connectionStream?.cancel();
    _connectionStream = null;
    _retryConnection();
  }

  /// Adds a [device] to a private list of discovered devices, unless already added.
  /// Also converts the DiscoveredDevice type into a custom Device type.
  /// Returns true if added, otherwise false.
  bool _addScanResult(DiscoveredDevice device) {
    for (Device _device in _scannedDevices) {
      if (_device.id == device.id) return false;
    }
    if (_connectionStream != null) {
      print(
          'BLE_CONTROLLER: The connected device is scanned anyways ===================');
      return false;
    }

    Device newDevice =
        Device(id: device.id, name: device.name, rssi: device.rssi);
    _scannedDevices.add(newDevice);
    print('BLE_CONTROLLER: Adding $newDevice!');
    notifyListeners();
    return true;
  }

  Future<void> _onScanError(e) async {
    if (_bluetoothState == BluetoothState.scanning) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
      await _scanSub?.cancel();
    }
    print('Error during scanning: =====================================');
    print(e.toString());
  }

  @override
  Stream<String> subscribeToDeviceDataStream() {
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: timerCharacteristicUUID,
        serviceId: timerServiceUUID,
        deviceId: _connectedDevice!.id);
    _characteristicStream ??= ble
        .subscribeToCharacteristic(characteristic)
        .transform(Utf8Decoder(allowMalformed: true))
        .transform(LineSplitter())
        .asBroadcastStream(onCancel: ((subscription) {
      _dataSubscribers--;
      print(
          'BLE_CONTROLLER: A subscriber leaved the characteristic ${characteristic.characteristicId} data stream [$_dataSubscribers].');
    }), onListen: ((subscription) {
      _dataSubscribers++;
      print(
          'BLE_CONTROLLER: A subscriber entered to characteristic ${characteristic.characteristicId} data stream [$_dataSubscribers].');
    }));

    return _characteristicStream!;
  }
}
