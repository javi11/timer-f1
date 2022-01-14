import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:timer_f1/app/data/device_model.dart';

import '../bluetooth_model.dart';

const timerName = 'DSD TECH';
Uuid timerServiceUUID = Uuid.parse('0000ffe0-0000-1000-8000-00805f9b34fb');
Uuid timerCharacteristicUUID =
    Uuid.parse('0000ffe1-0000-1000-8000-00805f9b34fb');

abstract class BLEService extends GetxService {
  /// Initializes the Bluetooth Low Energy service.
  @override
  void onInit();

  /// Returns the current state of a Bluetooth module.
  Rx<BluetoothState> get getBluetoothState;

  /// Returns a reactive list of discovered and connectable Bluetooth devices.
  RxList<Device> get getScannedDevices;

  /// Returns a reactive connected device.
  Rx<Device?> get getConnectedDevice;

  /// Returns a reactive paired device.
  Rx<Device?> get getPairedDevice;

  /// Scans for BLE devices and populates the devices list.
  StreamSubscription<DiscoveredDevice> startScan({void Function()? onTimeout});

  /// Authorize BLE.
  Future<void> authorize();

  /// Stops a scan if it is already running.
  Future<void> stopScan();

  Future<void> pairDevice(Device device);

  Future<void> forgetDevice(Device device);

  /// Connects to a specified [device].
  void connect(Device device, {void Function()? onTimeout, Duration timeLimit});

  /// Disconnects from the connected device.
  void disconnect();
}
