import 'dart:async';

import 'package:get/get.dart';
import 'package:timer_f1/app/data/device_model.dart';

const timerServiceUUID = '0000ffe0-0000-1000-8000-00805f9b34fb';
const timerCharacteristicUUID = '0000ffe1-0000-1000-8000-00805f9b34fb';

abstract class USBService extends GetxService {
  /// Initializes the USB service.
  @override
  void onInit();

  /// Returns a boolean stream, true if connected to any device.
  Stream<bool> get isConnected;

  /// Returns a reactive list of connected devices.
  Rx<Device?> get getConnectedDevice;

  /// Connects to a specified [device].
  void connect(Device device);

  /// Disconnects from the connected device.
  void disconnect();
}
