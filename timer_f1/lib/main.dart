import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timer_f1/app/data/providers/db_provider.dart';
import 'package:timer_f1/app/data/providers/flutter_reactive_ble_provider.dart';
import 'package:timer_f1/app/data/providers/usb_serial_provider.dart';
import 'package:timer_f1/app/data/services/ble_service.dart';
import 'package:timer_f1/app/data/services/db_service.dart';
import 'package:timer_f1/app/data/services/usb_service.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put<DBService>(DBProvider());
  Get.put<USBService>(USBSerial());
  Get.put<BLEService>(FlutterReactiveBLE());

  runApp(
    GetMaterialApp(
      title: "Timer F1",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
