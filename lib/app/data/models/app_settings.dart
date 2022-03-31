import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timer_f1/app/data/models/device_model.dart';

class AppSettings extends ChangeNotifier {
  static final storage = GetStorage('AppSettings');
  static GetStorage _perfBox() {
    return storage;
  }

  final timerBleFilter = 'DHD TECH'.val('timerBleFilter', getBox: _perfBox);
  final pairedDeviceId = ''.val('pairedDeviceId', getBox: _perfBox);
  final pairedDeviceName = ''.val('pairedDeviceName', getBox: _perfBox);
  final pairedDeviceFirmware = ''.val('pairedDeviceFirmware', getBox: _perfBox);
  final pairedDeviceBrand = ''.val('pairedDeviceBrand', getBox: _perfBox);

  AppSettings() {
    storage.listen(() {
      notifyListeners();
    });
  }

  void removePairedDevice() {
    pairedDeviceId.val = '';
    pairedDeviceName.val = '';
    pairedDeviceFirmware.val = '';
    pairedDeviceBrand.val = '';
  }

  void savePairDevice(Device device) {
    pairedDeviceId.val = device.id;
    pairedDeviceName.val = device.name;
    pairedDeviceFirmware.val = device.firmware;
    pairedDeviceBrand.val = device.brand.toString();
  }

  Device? getPairDevice() {
    if (pairedDeviceId.val.isNotEmpty && pairedDeviceName.val.isNotEmpty) {
      return Device(
          id: pairedDeviceId.val,
          name: pairedDeviceName.val,
          firmware: pairedDeviceFirmware.val,
          brand: Brand.values.firstWhere(
              (e) => e.toString() == pairedDeviceBrand.val,
              orElse: () => Brand.unknown));
    }

    return null;
  }
}
