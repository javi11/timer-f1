import 'package:get/get.dart';
import 'package:timer_f1/app/routes/middlewares/bluetooth_guard.dart';

import '../modules/bluetooth/bindings/bluetooth_binding.dart';
import '../modules/bluetooth/views/bluetooth_view.dart';
import '../modules/flight_tracker/bindings/flight_tracker_binding.dart';
import '../modules/flight_tracker/views/flight_tracker_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import 'middlewares/device_connection_guard.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.BLUETOOTH,
      page: () => BluetoothView(),
      binding: BluetoothBinding(),
      middlewares: [BluetoothGuard()],
    ),
    GetPage(
        name: _Paths.FLIGHT_TRACKER,
        page: () => FlightTrackerView(),
        binding: FlightTrackerBinding(),
        middlewares: [DeviceConnectionGuard()]),
  ];
}
