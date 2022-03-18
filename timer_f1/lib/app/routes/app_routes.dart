part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const BLUETOOTH = _Paths.BLUETOOTH;
  static const FLIGHT_TRACKER = _Paths.FLIGHT_TRACKER;
  static const FLIGHT_DETAILS = _Paths.FLIGHT_DETAILS;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/';
  static const FLIGHT_DETAILS = 'flight-details';
  static const BLUETOOTH = '/bluetooth';
  static const FLIGHT_TRACKER = 'flight-tracker';
  static const SETTINGS = 'settings';
}
