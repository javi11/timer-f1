import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/providers/db_provider.dart';
import 'package:timer_f1/objectbox.g.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';

abstract class FlightRepository {
  int saveFlight(Flight flight);

  Flight? getFlightById(int id);

  List<Flight> getFlightHistory();
}

final flightRepositoryProvider = Provider<FlightRepository>(
    (ref) => StoreFlightRepository(database: ref.watch(dbProvider)));

class StoreFlightRepository implements FlightRepository {
  final Store database;
  late final Box<Flight> _box;

  StoreFlightRepository({required this.database}) {
    _box = database.box<Flight>();
  }
  @override
  int saveFlight(Flight flight) {
    return _box.put(flight);
  }

  @override
  Flight? getFlightById(int id) {
    return _box.get(id);
  }

  @override
  List<Flight> getFlightHistory() {
    return _box.getAll();
  }
}
