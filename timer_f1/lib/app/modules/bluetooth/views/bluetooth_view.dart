import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timer_f1/app/data/bluetooth_model.dart';
import 'package:timer_f1/app/data/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/connected_device.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/no_devices_found.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/scan_animation.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/connecting_device.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/devices_list.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/turn_on_bluetooth.dart';
import '../controllers/bluetooth_controller.dart';

class BluetoothView extends GetView<BluetoothController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                await controller.stopScan();
                Get.back();
              },
            ),
            centerTitle: true,
            title: Text('Connecting...'),
            elevation: 0),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Obx(() {
            if (controller.bluetoothState.value == BluetoothState.off) {
              return TurnOnBluetooth();
            }

            if (controller.bluetoothState.value == BluetoothState.connected &&
                controller.connectedDevice.value != null) {
              return ConnectedDevice(
                  deviceName: controller.connectedDevice.value!.name);
            }

            if (controller.bluetoothState.value == BluetoothState.connecting &&
                controller.pairedDevice.value != null) {
              return ConnectingToDevice(
                  deviceName: controller.pairedDevice.value!.name);
            }

            if (controller.bluetoothState.value == BluetoothState.scanning &&
                controller.scannedDevices.isEmpty) {
              return ScanAnimation();
            }

            if (controller.bluetoothState.value == BluetoothState.scanTimeout ||
                (controller.bluetoothState.value != BluetoothState.scanning &&
                    controller.scannedDevices.isEmpty)) {
              return NoDevicesFound(
                onRetry: () => controller.onScan(),
              );
            }

            return DeviceList(
              deviceList: controller.scannedDevices,
              isScanning:
                  controller.bluetoothState.value == BluetoothState.scanning,
              onPair: (Device device) async =>
                  await controller.onConnect(device),
              onRetry: () => controller.onScan(),
            );
          }),
        ));
  }
}
