import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/bluetooth_status.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_device_controller.dart';
import 'package:timer_f1/app/modules/usb_device/widgets/usb_status.dart';

class DeviceStatus extends Container {
  final UsbDeviceController usbController = Get.find<UsbDeviceController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (usbController.isConnected.value == true) {
        return UsbStatus();
      }

      return BluetoothStatus();
    });
  }
}
