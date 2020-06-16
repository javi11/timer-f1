import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Iterable<String>> _loadMock() async {
  String data =
      await rootBundle.loadString('assets/res/bluetooth_receiver_data.txt');

  return LineSplitter.split(data);
}

class Bluetooth extends ChangeNotifier {
  int mockIndex = 0;
  Timer mockTimer;
  String chunk;

  void start() {
    _loadMock().then((data) {
      List<String> lines = data.toList();
      int mockIndex = 0;
      mockTimer = Timer.periodic(Duration(seconds: 1), (_) {
        if (mockIndex == lines.length) {
          mockIndex = 0;
        }

        chunk = lines[mockIndex];
        mockIndex++;

        notifyListeners();
      });
    });
  }

  void stop(Function listener) {
    removeListener(listener);
    mockTimer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    mockTimer?.cancel();
  }
}
