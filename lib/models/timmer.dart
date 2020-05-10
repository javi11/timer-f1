import 'package:scoped_model/scoped_model.dart';
import 'package:timmer/models/flight_history.dart';

class Timmer extends Model {
  List<FlightHistory> flightHistory = [];
  static final Timmer _singleton = new Timmer._internal();

  factory Timmer() {
    return _singleton;
  }
  Timmer._internal();

  void init() {}

  addFlightHistory(FlightHistory history) {
    flightHistory.add(history);
  }
}
