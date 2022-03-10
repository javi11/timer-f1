import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/data/providers/ble_provider.dart';
import 'package:timer_f1/app/data/providers/storage_provider.dart';
import 'package:timer_f1/core/vicent_timer/vicent_timer_commands.dart';

const maxTimerDataLength = 20;
const timerName = 'DSD TECH';
Uuid timerServiceUUID = Uuid.parse('0000ffe0-0000-1000-8000-00805f9b34fb');
Uuid timerCharacteristicUUID =
    Uuid.parse('0000ffe1-0000-1000-8000-00805f9b34fb');
String _pairedDeviceIdKey = 'PAIRED_DEVICE_NAME';
String _pairedDeviceNameKey = 'PAIRED_DEVICE_ID';

final bleControllerProvider = ChangeNotifierProvider<BLEController>((ref) {
  var ble = FlutterReactiveBleController(
      ble: ref.watch(bleProvider), box: ref.watch(storageProvider));
  ref.onDispose(() => ble.onClose());
  return ble;
});

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
  Future<void> authorize();
  Future<void> pairDevice(Device device);
  Future<void> forgetDevice(Device device);
  StreamSubscription<DiscoveredDevice>? startScan(
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)});
  Future<void> stopScan();
  void connect(Device device,
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)});
  Future<void> disconnect();
  Stream<String> subscribeToDeviceDataStream();
}

class FlutterReactiveBleController extends ChangeNotifier
    implements BLEController {
  final FlutterReactiveBle ble;
  final GetStorage box;
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
  CancelableOperation<void>? _initialHandShakeFuture;
  Stream<String>? _characteristicStream;
  int _dataSubscribers = 0;

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

  FlutterReactiveBleController({required this.ble, required this.box}) {
    _btHWStatusStreamSub = ble.statusStream.listen(_handleBluetoothHWUpdates);

    if (box.hasData(_pairedDeviceIdKey)) {
      _pairedDevice = Device(
          id: box.read<String>(_pairedDeviceIdKey)!,
          name: box.read<String>(_pairedDeviceNameKey)!);
      connect(_pairedDevice!);
    }
  }

  @override
  Future<void> authorize() async {
    await Permission.locationWhenInUse.request();
  }

  @override
  Future<void> pairDevice(Device device) async {
    await box.write(_pairedDeviceIdKey, device.id);
    await box.write(_pairedDeviceNameKey, device.name);
    _pairedDevice = device;
  }

  @override
  Future<void> forgetDevice(Device device) async {
    _reconnectionTimer?.cancel();
    _pairedDevice = null;
    if (_bluetoothState != BluetoothState.off) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
    }
    await box.remove(_pairedDeviceIdKey);
    await box.remove(_pairedDeviceNameKey);
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
    _scanSub = ble
        .scanForDevices(
            withServices: [timerServiceUUID], scanMode: ScanMode.lowPower)
        .takeWhile((element) => element.name == timerName)
        .listen(_addScanResult, onError: _onScanError);
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
      await _scanSub?.cancel();
      _scanTimeout?.cancel();
    }
  }

  @override
  void connect(Device device,
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)}) {
    String deviceId = device.id;

    if (_connectionStream == null) {
      print('BLE_CONTROLLER: Adding connection stream for $deviceId');
      stopScan();
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
    if (_connectionStream == null || _connectionStream!.isPaused) {
      throw Exception(
          'BLE_CONTROLLER: Connection stream is paused or null or blank! It cannot be canceled =============');
    }
    print('BLE_CONTROLLER: Disconnecting from ${_connectedDevice?.id}');
    await _cleanOnDisconnect();
    if (_bluetoothState == BluetoothState.connecting ||
        _bluetoothState == BluetoothState.connected) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
    }
  }

  void onClose() {
    _btHWStatusStreamSub?.cancel();
    _reconnectionTimer?.cancel();
    _scanTimeout?.cancel();
    _initialHandShakeFuture?.cancel();
  }

  void _retryConnection() {
    if (_bluetoothState != BluetoothState.off &&
        _pairedDevice != null &&
        (_reconnectionTimer == null || _reconnectionTimer!.isActive == false)) {
      print(
          'BLE_CONTROLLER: Reconnecting to ${_pairedDevice!.id} in 6 seconds.');
      _reconnectionTimer = Timer.periodic(Duration(seconds: 6), (timer) async {
        if (_pairedDevice != null) {
          connect(_pairedDevice!);
        }
        _reconnectionTimer?.cancel();
      });
    }
  }

  Future<void> _cleanOnDisconnect() async {
    await _connectionStream?.cancel();
    await _initialHandShakeFuture?.cancel();
    _characteristicStream = null;
    _initialHandShakeFuture = null;
    _connectionStream = null;
    _reconnectionTimer?.cancel();
    _connectedDevice = null;
    _deviceConnectingTo = null;
  }

  void _handleBluetoothHWUpdates(BleStatus state) async {
    switch (state) {
      case BleStatus.ready:
        if (_bluetoothState == BluetoothState.unauthorized ||
            _bluetoothState == BluetoothState.off) {
          _bluetoothState = BluetoothState.on;
          _retryConnection();
        }
        break;
      case BleStatus.unauthorized:
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
        _bluetoothState = BluetoothState.connecting;
        print('BLE_CONTROLLER: Connecting to ${event.deviceId}');
        notifyListeners();
        break;
      case DeviceConnectionState.connected:
        _connectedDevice = _deviceConnectingTo;
        _deviceConnectingTo = null;
        _bluetoothState = BluetoothState.connected;
        print('BLE_CONTROLLER: Connected to ${event.deviceId}');
        notifyListeners();
        _initialHandShake();
        break;
      case DeviceConnectionState.disconnected:
        _characteristicStream = null;
        _deviceConnectingTo = null;
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

  void _initialHandShake() {
    print('BLE_CONTROLLER: Initial handshake for ${_connectedDevice!.id}');
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: timerCharacteristicUUID,
        serviceId: timerServiceUUID,
        deviceId: _connectedDevice!.id);

    Brand brand = Brand.unknown;
    var sub = subscribeToDeviceDataStream().handleError((error) {
      print('BLE_CONTROLLER: Error on Initial handshake, $error');
    }).listen((value) {
      if (value.contains(VicentTimerFirmware)) {
        brand = Brand.vicent;
      }
    });

    _initialHandShakeFuture = CancelableOperation.fromFuture(
      () async {
        int maxAttempts = 20;
        int iteration = 0;
        await Future.doWhile(() async {
          if (_bluetoothState != BluetoothState.connected) {
            return false;
          }
          await _sendData(characteristic, VicentTimerCommands.getHelp,
              endOf: '\n');

          if (brand != Brand.unknown ||
              _bluetoothState != BluetoothState.connected) {
            return false;
          }

          //Wait two seconds before retrying again
          await Future.delayed(Duration(seconds: 2));
          iteration += 1;

          return iteration < maxAttempts;
        });

        await sub.cancel();
        if (_connectedDevice != null) {
          print(
              'BLE_CONTROLLER: Device brand for ${_connectedDevice!.id} is $brand');
          _connectedDevice!.brand = brand;
          _initialHandShakeFuture = null;
          notifyListeners();
        } else {
          print('BLE_CONTROLLER: Device disconnected before initial HandShake');
        }
      }(),
      onCancel: () => sub.cancel(),
    );
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
