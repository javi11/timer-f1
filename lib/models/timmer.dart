import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:timmer/models/flight_history.dart';

class Timmer extends ChangeNotifier {
  final List<FlightHistory> _history = [];

  UnmodifiableListView<FlightHistory> get flightHistory =>
      UnmodifiableListView(_history);

  void addFlightHistory(FlightHistory item) {
    _history.insert(0, item);
    notifyListeners();
  }

  void removeAllFlightHistory() {
    _history.clear();
    notifyListeners();
  }

  void removeFlightHistory(int index) {
    _history.removeAt(index);
    notifyListeners();
  }
}
