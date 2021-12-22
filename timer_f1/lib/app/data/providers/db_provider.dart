import 'package:timer_f1/app/data/flight_data_model.dart';
import 'package:timer_f1/app/data/services/db_service.dart';
import 'package:timer_f1/objectbox.g.dart';
import 'package:timer_f1/app/data/flight_model.dart';

class DBProvider extends DBService {
  late final Store store;
  late final Box<FlightData> flightDataBox;
  late final Box<Flight> flightBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    store = await openStore();
    flightDataBox = store.box<FlightData>();
    flightBox = store.box<Flight>();
  }

  @override
  Future<int> saveFlight(Flight flight) async {
    return await flightBox.putAsync(flight);
  }

  @override
  Flight? getFlightById(int id) {
    return flightBox.get(id);
  }

  @override
  List<Flight> getFlightHistory() {
    return flightBox.getAll();
  }

  @override
  void onClose() {
    store.close();
  }
}
