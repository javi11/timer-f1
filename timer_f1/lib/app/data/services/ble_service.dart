import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:timer_f1/app/data/device_model.dart';

const timerServiceUUID = '0000ffe0-0000-1000-8000-00805f9b34fb';
const timerCharacteristicUUID = '0000ffe1-0000-1000-8000-00805f9b34fb';

abstract class BLEService extends GetxService {
  /// Initializes the Bluetooth Low Energy service.
  @override
  void onInit();

  /// Returns the current state of a Bluetooth module.
  Stream<BleStatus> get getState;

  /// Returns a boolean stream, true if the module is currently scanning.
  Stream<bool> get isScanning;

  /// Returns a boolean stream, true if connected to any device.
  Stream<bool> get isConnected;

  /// Returns a reactive list of discovered and connectable Bluetooth devices.
  RxList<Device> get getScannedDevices;

  /// Returns a reactive list of connected devices.
  Rx<Device?> get getConnectedDevice;

  /// Scans for BLE devices and populates the devices list.
  Future<void> startScan();

  /// Stops a scan if it is already running.
  Future<void> stopScan();

  /// Connects to a specified [device].
  void connect(Device device);

  /// Disconnects from the connected device.
  void disconnect();
}
