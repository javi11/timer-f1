import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart'
    hide DeviceConnectionState;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as ble
    show DeviceConnectionState;
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_f1/app/data/bluetooth_model.dart';
import 'package:timer_f1/app/data/device_model.dart';
import 'package:timer_f1/app/data/services/ble_service.dart';

String pairedDeviceIdKey = 'PAIRED_DEVICE_NAME';
String pairedDeviceNameKey = 'PAIRED_DEVICE_ID';

class BluetoothOffException implements Exception {
  String cause;
  BluetoothOffException(this.cause);
}

class FlutterReactiveBLE extends BLEService {
  late FlutterReactiveBle _ble;
  late StreamSubscription<ConnectionStateUpdate>? _connectedDeviceStreamSub;
  late StreamSubscription<BleStatus>? _btHWStatusStreamSub;
  late GetStorage _box;
  final Rx<BluetoothState> _bluetoothState = BluetoothState.off.obs;
  final _scannedDevices = <Device>[].obs;
  final _connectedDevice = Rx<Device?>(null);
  final _pairedDevice = Rx<Device?>(null);

  StreamSubscription<ConnectionStateUpdate>? _connectionStream;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  Device? _deviceConnectingTo;

  @override
  void onInit() {
    _box = GetStorage();
    _ble = FlutterReactiveBle();
    _ble.logLevel = LogLevel.none;
    _connectedDeviceStreamSub =
        _ble.connectedDeviceStream.listen(_handleConnectionStateUpdates);
    _btHWStatusStreamSub = _ble.statusStream.listen(_handleBluetoothHWUpdates);

    if (_box.hasData(pairedDeviceIdKey)) {
      _pairedDevice.value = Device(
          id: _box.read<String>(pairedDeviceIdKey)!,
          name: _box.read<String>(pairedDeviceNameKey)!);
      connect(_pairedDevice.value!);
    }
    super.onInit();
  }

  @override
  Future<void> authorize() async {
    await Permission.locationWhenInUse.request();
  }

  @override
  Rx<BluetoothState> get getBluetoothState => _bluetoothState;

  @override
  RxList<Device> get getScannedDevices => _scannedDevices;

  @override
  Rx<Device?> get getConnectedDevice => _connectedDevice;

  @override
  Rx<Device?> get getPairedDevice => _pairedDevice;

  @override
  Future<void> pairDevice(Device device) async {
    await _box.write(pairedDeviceIdKey, device.id);
    await _box.write(pairedDeviceNameKey, device.name);
    _pairedDevice.value = device;
  }

  @override
  Future<void> forgetDevice(Device device) async {
    await _box.remove(pairedDeviceIdKey);
    await _box.remove(pairedDeviceNameKey);
    if (_bluetoothState.value != BluetoothState.off) {
      _bluetoothState.value = BluetoothState.on;
    }
  }

  @override
  StreamSubscription<DiscoveredDevice> startScan(
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)}) {
    if (_ble.status != BleStatus.ready) {
      _bluetoothState.value = BluetoothState.off;
      throw BluetoothOffException('Bluetooth is not enabled');
    } else {
      _scannedDevices.clear();
      _bluetoothState.value = BluetoothState.scanning;
      _scanSub?.cancel();
      _scanSub = _ble
          .scanForDevices(
              withServices: [timerServiceUUID], scanMode: ScanMode.lowPower)
          .takeWhile((element) => element.name == timerName)
          .timeout(timeLimit, onTimeout: (event) async {
            if (_bluetoothState.value == BluetoothState.scanning) {
              _bluetoothState.value = BluetoothState.scanTimeout;
              await _scanSub?.cancel();
            }
            onTimeout?.call();
          })
          .listen((result) => _addScanResult(result));

      _scanSub?.onError((e) async {
        if (_bluetoothState.value == BluetoothState.scanning) {
          _bluetoothState.value = BluetoothState.on;
          await _scanSub?.cancel();
        }
        print('Error during scanning: =====================================');
        print(e.toString());
      });

      return _scanSub!;
    }
  }

  @override
  Future<void> stopScan() async {
    if (_bluetoothState.value == BluetoothState.scanning) {
      _bluetoothState.value = BluetoothState.on;
    }
    await _scanSub?.cancel();
  }

  @override
  void connect(Device device,
      {void Function()? onTimeout,
      Duration timeLimit = const Duration(seconds: 30)}) {
    String deviceId = device.id;
    _deviceConnectingTo = device;

    if (_connectionStream == null) {
      print('SERVICE: Adding connection stream for $deviceId');
      _bluetoothState.value = BluetoothState.connecting;
      _connectionStream = _ble
          .connectToAdvertisingDevice(
              id: deviceId,
              prescanDuration: timeLimit,
              withServices: [timerServiceUUID],
              connectionTimeout: timeLimit)
          .listen((stateUpdate) {
        if (stateUpdate.failure != null) {
          _bluetoothState.value = BluetoothState.connectionTimeout;
          _connectionStream?.cancel();
          _connectionStream = null;
          onTimeout?.call();
        }
        print('SERVICE: connectToDevice state update: $stateUpdate');
      });
      _connectionStream?.onError((error) {
        _bluetoothState.value = BluetoothState.connectionTimeout;
        _connectionStream?.cancel();
        _connectionStream = null;
        onTimeout?.call();
      });
    }
  }

  @override
  void disconnect() {
    if (_connectionStream == null || _connectionStream!.isPaused) {
      throw Exception(
          'SERVICE: Connection stream is paused or null or blank! It cannot be canceled =============');
    }
    _connectionStream?.cancel();
    _connectionStream = null;
    if (_bluetoothState.value == BluetoothState.connecting ||
        _bluetoothState.value == BluetoothState.connected) {
      _bluetoothState.value = BluetoothState.on;
    }
  }

  @override
  void onClose() {
    _ble.deinitialize();
    _btHWStatusStreamSub?.cancel();
    _connectedDeviceStreamSub?.cancel();
    super.onClose();
  }

  void _handleBluetoothHWUpdates(BleStatus state) async {
    switch (state) {
      case BleStatus.ready:
        if (_bluetoothState.value == BluetoothState.unauthorized ||
            _bluetoothState.value == BluetoothState.off) {
          _bluetoothState.value = BluetoothState.on;
        }
        break;
      case BleStatus.unauthorized:
        await authorize();
        break;
      default: // Off, unauthorized, unavailable, unknown
        _scannedDevices.clear();
        _bluetoothState.value == BluetoothState.off;
    }
  }

  /// Keep track of connected devices count and update the isConnected stream.
  void _handleConnectionStateUpdates(ConnectionStateUpdate stateUpdate) {
    print('SERVICE: connectedDeviceStream update: $stateUpdate');
    String deviceId = stateUpdate.deviceId;
    ble.DeviceConnectionState connectionState = stateUpdate.connectionState;

    // Device connected.
    if (connectionState == ble.DeviceConnectionState.connected) {
      _bluetoothState.value = BluetoothState.connected;

      // Add to connected devices and remove from scanned devices.
      int deviceIndex =
          _scannedDevices.indexWhere((device) => device.id == deviceId);
      if (deviceIndex != -1) {
        _connectedDevice.value = _scannedDevices[deviceIndex];
      } else {
        if (_deviceConnectingTo == null) {
          _connectedDevice.value = Device(id: deviceId);
        } else {
          if (_connectedDevice.value == null) {
            print('SERVICE: Adding connected device');
            _connectedDevice.value = _deviceConnectingTo;
          } else {
            print(
                'SERVICE: Device already connected, this shouldn\'t happen! ================');
          }
        }
      }

      if (_deviceConnectingTo != null) {
        print('SERVICE: Clearing _deviceConnectingTo (after connecting)');
        _deviceConnectingTo = null;
      }

      // Subscribe to connection stream if not subbed yet (usually after restart).
      if (_connectionStream == null) {
        print(
            'SERVICE: Probably performed a hot restart after being connected to a device, reconnecting to it');
        connect(Device(id: deviceId));
      }

      // Device disconnected.
    } else if (connectionState == ble.DeviceConnectionState.disconnected) {
      if (_deviceConnectingTo != null && deviceId == _deviceConnectingTo?.id) {
        print(
            'SERVICE: Clearing _deviceConnectingTo (after disconnected) -------');
        _deviceConnectingTo = null;
      }

      // Remove connection stream, if it exists.
      if (_connectionStream != null) {
        print(
            'SERVICE: Removing connection stream (this should appear only after unsuccessful connect or unexpected disconnect)');
        _connectionStream?.cancel();
        _connectionStream = null;
      }

      if (_bluetoothState.value == BluetoothState.connected) {
        _bluetoothState.value = BluetoothState.on;
      }

      // Move from list of scanned devices to connected devices, if needed.
      if (_connectedDevice.value?.id == deviceId) {
        _scannedDevices.addIf(
            _scannedDevices
                .every((item) => item.id != _connectedDevice.value?.id),
            _connectedDevice.value!);
        _connectedDevice.value = null;
      }
    }

    // Update connection state of the Device model
    try {
      Device device = _scannedDevices.firstWhere(
          (device) => device.id == deviceId,
          orElse: () => _connectedDevice.value!);
      _setConnectionState(device, connectionState);
      if (_connectedDevice.value != null) {
        _connectedDevice.refresh();
      } else {
        _scannedDevices.refresh();
      }
    } on StateError {
      if (connectionState == ble.DeviceConnectionState.disconnected) {
        print(
            'SERVICE: Device neither scanned, nor connected to! ---------------');
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
          'SERVICE: The connected device is scanned anyways ===================');
      return false;
    }

    Device newDevice =
        Device(id: device.id, name: device.name, rssi: device.rssi);
    _scannedDevices.add(newDevice);
    print('SERVICE: Adding $newDevice!');
    return true;
  }

  /// Sets the connection state of a [device] to [connectionState].
  /// Performs a conversion of flutter_reactive_ble's DeviceConnectionState enum
  /// to Device's DeviceConnectionState enum.
  void _setConnectionState(
      Device device, ble.DeviceConnectionState connectionState) {
    switch (connectionState) {
      case ble.DeviceConnectionState.connecting:
        device.connectionState = DeviceConnectionState.connecting;
        break;
      case ble.DeviceConnectionState.connected:
        device.connectionState = DeviceConnectionState.connected;
        break;
      case ble.DeviceConnectionState.disconnecting:
        device.connectionState = DeviceConnectionState.disconnecting;
        break;
      case ble.DeviceConnectionState.disconnected:
        device.connectionState = DeviceConnectionState.disconnected;
        break;
    }
  }
}
