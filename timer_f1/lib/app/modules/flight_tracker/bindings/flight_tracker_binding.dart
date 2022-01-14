import 'package:get/get.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/bluetooth_controller.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_device_controller.dart';

import '../controllers/flight_tracker_controller.dart';

class FlightTrackerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BluetoothController>(
      () => BluetoothController(),
    );
    Get.lazyPut<UsbDeviceController>(
      () => UsbDeviceController(),
    );
    Get.lazyPut<FlightTrackerController>(
      () => FlightTrackerController(),
    );
  }
}
