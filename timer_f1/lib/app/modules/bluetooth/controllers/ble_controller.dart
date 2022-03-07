import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/data/providers/ble_provider.dart';
import 'package:timer_f1/app/data/providers/storage_provider.dart';

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
  StreamSubscription<DiscoveredDevice> startScan(
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)});
  Future<void> stopScan();
  void connect(Device device,
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)});
  void disconnect();
  Stream<List<int>> subscribeToDeviceDataStream();
}

class FlutterReactiveBleController extends ChangeNotifier
    implements BLEController {
  final FlutterReactiveBle ble;
  final GetStorage box;
  late StreamSubscription<ConnectionStateUpdate>? _connectedDeviceStreamSub;
  late StreamSubscription<BleStatus>? _btHWStatusStreamSub;
  final List<Device> _scannedDevices = [];
  BluetoothState _bluetoothState = BluetoothState.off;
  Device? _connectedDevice;
  Device? _pairedDevice;
  Device? _deviceConnectingTo;
  StreamSubscription<ConnectionStateUpdate>? _connectionStream;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  Timer? _reconnectionTimer;

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
    _connectedDeviceStreamSub =
        ble.connectedDeviceStream.listen(_handleConnectionStateUpdates);
    _btHWStatusStreamSub = ble.statusStream.listen(_handleBluetoothHWUpdates);

    if (box.hasData(_pairedDeviceIdKey)) {
      _pairedDevice = Device(
          id: box.read<String>(_pairedDeviceIdKey)!,
          name: box.read<String>(_pairedDeviceNameKey)!);
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
    await box.remove(_pairedDeviceIdKey);
    await box.remove(_pairedDeviceNameKey);
    _reconnectionTimer?.cancel();
    if (_bluetoothState != BluetoothState.off) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
    }
  }

  @override
  StreamSubscription<DiscoveredDevice> startScan(
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)}) {
    if (ble.status != BleStatus.ready) {
      _bluetoothState = BluetoothState.off;
      notifyListeners();
    }
    _scannedDevices.clear();
    _bluetoothState = BluetoothState.scanning;
    _scanSub?.cancel();
    _scanSub = ble
        .scanForDevices(
            withServices: [timerServiceUUID], scanMode: ScanMode.lowPower)
        .takeWhile((element) => element.name == timerName)
        .timeout(timeLimit, onTimeout: (event) async {
          if (_bluetoothState == BluetoothState.scanning) {
            _bluetoothState = BluetoothState.scanTimeout;
            notifyListeners();
            await _scanSub?.cancel();
          }
          onTimeout?.call();
        })
        .listen((result) => _addScanResult(result));

    _scanSub?.onError((e) async {
      if (_bluetoothState == BluetoothState.scanning) {
        _bluetoothState = BluetoothState.on;
        notifyListeners();
        await _scanSub?.cancel();
      }
      print('Error during scanning: =====================================');
      print(e.toString());
    });

    return _scanSub!;
  }

  @override
  Future<void> stopScan() async {
    if (_bluetoothState == BluetoothState.scanning) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
    }
    await _scanSub?.cancel();
  }

  @override
  void connect(Device device,
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)}) {
    String deviceId = device.id;

    if (_connectionStream == null) {
      print('BLE_CONTROLLER: Adding connection stream for $deviceId');
      _deviceConnectingTo = device;
      _bluetoothState = BluetoothState.connecting;
      notifyListeners();
      _connectionStream = ble
          .connectToAdvertisingDevice(
              id: deviceId,
              prescanDuration: timeLimit,
              withServices: [timerServiceUUID],
              connectionTimeout: timeLimit)
          .listen((stateUpdate) {
        if (stateUpdate.failure != null) {
          // On connection failure reset the connection stream.
          _bluetoothState = BluetoothState.connectionTimeout;
          _connectedDevice = null;
          _deviceConnectingTo = null;
          _connectionStream?.cancel();
          _connectionStream = null;
          notifyListeners();
          onTimeout?.call();
          _retryConnection();
        }
        print('BLE_CONTROLLER: connectToDevice state update: $stateUpdate');
      });
    }
  }

  @override
  void disconnect() {
    if (_connectionStream == null || _connectionStream!.isPaused) {
      throw Exception(
          'BLE_CONTROLLER: Connection stream is paused or null or blank! It cannot be canceled =============');
    }
    _connectionStream?.cancel();
    _connectionStream = null;
    _reconnectionTimer?.cancel();
    if (_bluetoothState == BluetoothState.connecting ||
        _bluetoothState == BluetoothState.connected) {
      _bluetoothState = BluetoothState.on;
      notifyListeners();
    }
  }

  void onClose() {
    _btHWStatusStreamSub?.cancel();
    _connectedDeviceStreamSub?.cancel();
    _reconnectionTimer?.cancel();
  }

  void _retryConnection() {
    if (_pairedDevice != null && _reconnectionTimer?.isActive == false) {
      _reconnectionTimer = Timer.periodic(Duration(seconds: 6), (timer) {
        if (_pairedDevice != null) {
          connect(_pairedDevice!);
        } else {
          _reconnectionTimer?.cancel();
        }
      });
    }
  }

  void _handleBluetoothHWUpdates(BleStatus state) async {
    switch (state) {
      case BleStatus.ready:
        if (_bluetoothState == BluetoothState.unauthorized ||
            _bluetoothState == BluetoothState.off) {
          _bluetoothState = BluetoothState.on;
        }
        break;
      case BleStatus.unauthorized:
        await authorize();
        break;
      default: // Off, unauthorized, unavailable, unknown
        _scannedDevices.clear();
        _bluetoothState == BluetoothState.off;
    }
    notifyListeners();
  }

  /// Keep track of connected devices count and update the isConnected stream.
  void _handleConnectionStateUpdates(ConnectionStateUpdate stateUpdate) {
    print('BLE_CONTROLLER: _connectedDeviceStream update: $stateUpdate');
    String deviceId = stateUpdate.deviceId;
    DeviceConnectionState connectionState = stateUpdate.connectionState;

    // Device connected.
    if (connectionState == DeviceConnectionState.connected) {
      _bluetoothState = BluetoothState.connected;
      // Cancel reconnection timer if device is connected.
      _reconnectionTimer?.cancel();

      // Add to connected devices and remove from scanned devices.
      int deviceIndex =
          _scannedDevices.indexWhere((device) => device.id == deviceId);
      if (deviceIndex != -1) {
        _connectedDevice = _scannedDevices[deviceIndex];
      } else {
        if (_deviceConnectingTo == null) {
          _connectedDevice = Device(id: deviceId);
        } else {
          if (_connectedDevice == null) {
            print('BLE_CONTROLLER: Adding connected device');
            _connectedDevice = _deviceConnectingTo;
          } else {
            print(
                'BLE_CONTROLLER: Device already connected, this shouldn\'t happen! ================');
          }
        }
      }

      if (_deviceConnectingTo != null) {
        print(
            'BLE_CONTROLLER: Clearing _deviceConnectingTo (after connecting)');
        _deviceConnectingTo = null;
      }

      // Subscribe to connection stream if not subbed yet (usually after restart).
      if (_connectionStream == null) {
        print(
            'BLE_CONTROLLER: Probably performed a hot restart after being connected to a device, reconnecting to it');
        connect(Device(id: deviceId));
      }
    } else if (connectionState == DeviceConnectionState.disconnected) {
      // Device disconnected.
      if (_deviceConnectingTo != null && deviceId == _deviceConnectingTo?.id) {
        print(
            'BLE_CONTROLLER: Clearing _deviceConnectingTo (after disconnected) -------');
        _deviceConnectingTo = null;
      }

      // Remove connection stream, if it exists.
      if (_connectionStream != null) {
        print(
            'BLE_CONTROLLER: Removing connection stream (this should appear only after unsuccessful connect or unexpected disconnect)');
        _connectionStream?.cancel();
        _connectionStream = null;
      }

      // Run a reconnection timer in case the device was disconnected unintentionally.
      if (_bluetoothState == BluetoothState.connectionTimeout) {
        _retryConnection();
      }

      if (_bluetoothState == BluetoothState.connected) {
        print('BLE_CONTROLLER: Set default ble state to ON');
        _bluetoothState = BluetoothState.on;
      }

      // Move to list of scanned devices from connected device, if needed.
      if (_connectedDevice?.id == deviceId) {
        if (_scannedDevices.every((item) => item.id != _connectedDevice?.id)) {
          _scannedDevices.add(_connectedDevice!);
        }
        _connectedDevice = null;
      }
    }

    // Update connection state of the Device model
    try {
      Device? device =
          _scannedDevices.firstWhere((device) => device.id == deviceId);
      _setConnectionState(device, connectionState);
    } on StateError {
      if (_connectedDevice != null) {
        _reconnectionTimer?.cancel();
        print(
            'BLE_CONTROLLER: Device ${_connectedDevice!.name} already connected, updating status! ---------------');
        _setConnectionState(_connectedDevice!, connectionState);
      } else if (_pairedDevice != null) {
        print(
            'BLE_CONTROLLER: Connecting to paired device ${_pairedDevice!.name}! ---------------');
        connect(_pairedDevice!);
      } else if (connectionState == DeviceConnectionState.disconnected) {
        print(
            'BLE_CONTROLLER: Device neither scanned, nor connected to! ---------------');
        notifyListeners();
      }
    }
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

  /// Sets the connection state of a [device] to [connectionState].
  /// Performs a conversion of flutter_reactiveble's DeviceConnectionState enum
  /// to Device's DeviceConnectionState enum.
  void _setConnectionState(
      Device device, DeviceConnectionState connectionState) {
    switch (connectionState) {
      case DeviceConnectionState.connecting:
        device.connectionState = DeviceConnection.connecting;
        break;
      case DeviceConnectionState.connected:
        device.connectionState = DeviceConnection.connected;
        break;
      case DeviceConnectionState.disconnecting:
        device.connectionState = DeviceConnection.disconnecting;
        break;
      case DeviceConnectionState.disconnected:
        device.connectionState = DeviceConnection.disconnected;
        break;
    }
    notifyListeners();
  }

  @override
  Stream<List<int>> subscribeToDeviceDataStream() {
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: timerCharacteristicUUID,
        serviceId: timerServiceUUID,
        deviceId: _connectedDevice!.id);
    return ble.subscribeToCharacteristic(characteristic);
  }
}
