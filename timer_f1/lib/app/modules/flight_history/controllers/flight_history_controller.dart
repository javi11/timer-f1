import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/data/repositories/flight_repository.dart';

final flightHistoryControllerProvider =
    ChangeNotifierProvider<FlightHistoryController>((ref) =>
        FlightHistoryController(
            flightRepository: ref.watch(flightRepositoryProvider)));

class FlightHistoryController extends ChangeNotifier {
  final FlightRepository flightRepository;
  final List<Flight> _flightHistory = [];

  UnmodifiableListView<Flight> get flightHistory =>
      UnmodifiableListView(_flightHistory);

  FlightHistoryController({required this.flightRepository}) {
    _flightHistory.addAll(flightRepository.getFlightHistory());
  }

  void saveFlight(Flight flight) {
    _flightHistory.add(flight);
    flightRepository.saveFlight(flight);
    notifyListeners();
  }

  Flight? getFlightById(int id) {
    return _flightHistory.firstWhere((element) => element.id == id);
  }
}
