import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:timerf1c/models/flight_history.dart';

import '../database_helper.dart';

class HistoryProvider extends ChangeNotifier {
  final List<FlightHistory> _history = [];
  int _total = 0;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  UnmodifiableListView<FlightHistory> get flightHistory =>
      UnmodifiableListView(_history);
  int? get total => _total;

  Future<void> loadHistoryItems(int page) async {
    int limit = 10;
    _isLoading = true;
    notifyListeners();
    try {
      List responses = await Future.wait([
        DBProvider.db.getUserHistory(limit, limit * (page - 1)),
        DBProvider.db.getTotalCountHistory()
      ]);
      _total = responses[1];
      _history.addAll(responses[0]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFlightHistory(FlightHistory item) async {
    _history.insert(0, item);
    _total += 1;
    await DBProvider.db.newFlightHistory(item);
    notifyListeners();
  }
}
