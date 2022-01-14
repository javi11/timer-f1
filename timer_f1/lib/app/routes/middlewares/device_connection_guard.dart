import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timer_f1/app/data/services/ble_service.dart';
import 'package:timer_f1/app/data/services/usb_service.dart';
import 'package:timer_f1/app/routes/app_pages.dart';

class DeviceConnectionGuard extends GetMiddleware {
//   Get the auth service
  final bleService = Get.find<BLEService>();
  final usbService = Get.find<USBService>();

//   The default is 0 but you can update it to any number. Please ensure you match the priority based
//   on the number of guards you have.
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (bleService.getConnectedDevice.value == null &&
        usbService.getConnectedDevice.value == null) {
      return RouteSettings(
          name: Routes.BLUETOOTH, arguments: {'redirectTo': route});
    }

    return null;
  }
}
