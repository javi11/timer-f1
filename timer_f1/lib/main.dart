import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:timer_f1/app/data/providers/db_provider.dart';
import 'package:timer_f1/app/data/providers/flutter_reactive_ble_provider.dart';
import 'package:timer_f1/app/data/providers/usb_serial_provider.dart';
import 'package:timer_f1/app/data/services/ble_service.dart';
import 'package:timer_f1/app/data/services/db_service.dart';
import 'package:timer_f1/app/data/services/usb_service.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put<USBService>(USBSerial()).onInit();
  Get.put<BLEService>(FlutterReactiveBLE()).onInit();
  await Get.put<DBService>(DBProvider()).onInit();

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
