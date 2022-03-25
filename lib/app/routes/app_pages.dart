import 'package:go_router/go_router.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/bluetooth/bluetooth_page.dart';
import 'package:timer_f1/app/modules/flight_history/history_detail_page.dart';
import 'package:timer_f1/app/modules/flight_tracker/flight_tracker_page.dart';
import 'package:timer_f1/app/modules/home/home_page.dart';
import 'package:timer_f1/app/modules/settings/settings_page.dart';

part 'app_routes.dart';

const initial = Routes.HOME;
const bluetoothRequiredPaths = [_Paths.FLIGHT_TRACKER];

final router = GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(
        path: _Paths.HOME,
        builder: (context, state) => HomePage(),
        routes: [
          GoRoute(
              path: _Paths.FLIGHT_DETAILS,
              // Is protected by bluetooth but can not be redirected to ble connection page if ble connection is lost
              builder: (context, state) => FlightHistoryDetailPage(
                    flight: state.extra as Flight,
                  )),
          GoRoute(
              path: _Paths.FLIGHT_TRACKER,
              builder: (context, state) => FlightTrackerPage()),
          GoRoute(
              path: _Paths.SETTINGS,
              // Is protected by bluetooth but can not be redirected to ble connection page if ble connection is lost
              builder: (context, state) => SettingsPage()),
        ]),
    GoRoute(
        path: _Paths.BLUETOOTH,
        builder: (context, state) =>
            BluetoothPage(redirectTo: state.queryParams['redirectTo'])),
  ],
);
