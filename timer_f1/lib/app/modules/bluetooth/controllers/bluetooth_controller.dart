import 'dart:async';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:get/get.dart';
import 'package:timer_f1/app/data/bluetooth_model.dart';
import 'package:timer_f1/app/data/device_model.dart';
import 'package:timer_f1/app/data/services/ble_service.dart';

class BluetoothController extends GetxController {
  final BLEService _ble = Get.find<BLEService>();
  final isEnabled = false.obs;
  final scannedDevices = <Device>[].obs;
  Rx<Device?> connectedDevice = Rx<Device?>(null);
  Rx<Device?> pairedDevice = Rx<Device?>(null);
  Rx<BluetoothState> bluetoothState = BluetoothState.off.obs;

  @override
  void onInit() {
    super.onInit();
    scannedDevices(_ble.getScannedDevices);
    connectedDevice = _ble.getConnectedDevice;
    pairedDevice = _ble.getPairedDevice;
    bluetoothState = _ble.getBluetoothState;
  }

  void onScan() {
    if (bluetoothState.value != BluetoothState.scanning) {
      try {
        _ble.startScan().onError(
            (error) => FlushbarHelper.createError(message: error.message));
      } catch (e) {}
    }
  }

  Future<void> stopScan() async {
    await _ble.stopScan();
  }

  Future<void> onConnect(Device device) async {
    _ble.connect(device);
    await _ble.pairDevice(device);
  }

  Future<void> onRemoveDevice(Device device) async {
    await _ble.forgetDevice(device);
  }

  Future<void> onDisconnect(Device device) async {
    _ble.disconnect();
    await onRemoveDevice(device);
  }

  @override
  Future<void> onClose() async {
    await stopScan();
    super.onClose();
  }
}
