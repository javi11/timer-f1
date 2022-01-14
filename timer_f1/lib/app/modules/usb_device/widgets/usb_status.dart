import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_device_controller.dart';

class UsbStatus extends Container {
  final UsbDeviceController usbController = Get.find<UsbDeviceController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
          decoration: BoxDecoration(color: Colors.green[50]),
          child: ListTile(
            leading: Icon(Icons.usb),
            title:
                Text('${usbController.connectedDevice.value!.name} connected'),
          ));
    });
  }
}
