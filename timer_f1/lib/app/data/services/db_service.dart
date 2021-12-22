import 'package:get/get.dart';
import 'package:timer_f1/app/data/flight_model.dart';

abstract class DBService extends GetxService {
  @override
  Future<void> onInit();

  Future<int> saveFlight(Flight flight);

  Flight? getFlightById(int id);

  List<Flight> getFlightHistory();

  @override
  void onClose();
}
