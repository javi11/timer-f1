import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AppSettings extends ChangeNotifier {
  static final storage = GetStorage('AppSettings');
  static GetStorage _perfBox() {
    return storage;
  }

  final timerBleFilter = 'DHD TECH'.val('timerBleFilter', getBox: _perfBox);
  final pairedDeviceId = ''.val('pairedDeviceId', getBox: _perfBox);
  final pairedDeviceName = ''.val('pairedDeviceName', getBox: _perfBox);

  AppSettings() {
    storage.listen(() {
      notifyListeners();
    });
  }
}
