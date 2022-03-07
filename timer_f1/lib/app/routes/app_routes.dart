part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const BLUETOOTH = _Paths.BLUETOOTH;
  static const FLIGHT_TRACKER = _Paths.FLIGHT_TRACKER;
  static const FLIGHT_DETAIL = _Paths.FlightDetail;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/';
  static const FlightDetail = '/flight-details';
  static const BLUETOOTH = '/bluetooth';
  static const FLIGHT_TRACKER = 'flight-tracker';
}
