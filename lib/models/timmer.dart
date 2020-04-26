import 'dart:async';
import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:latlong/latlong.dart';

import '../util/constants.dart';

num toLatLng = pow(10, -7);

class TimmerParser {
  String id;
  int timestamp;
  LatLng position;
  double height;
  double temperature;
  double pressure;

  TimmerParser(String data) {
    List<String> line = data.split(',');

    this.id = line[0];
    this.timestamp = new DateTime(
            int.parse(line[3]),
            int.parse(line[4]),
            int.parse(line[5]),
            int.parse(line[6]),
            int.parse(line[7]),
            int.parse(line[8]))
        .millisecondsSinceEpoch;

    this.position = LatLng(
        double.parse(line[9]) * toLatLng, double.parse(line[10]) * toLatLng);
    // Convert height from mm to meters.
    this.height = double.parse(line[11]) / 1000;
    this.temperature = double.parse(line[12]);
    this.pressure = double.parse(line[13]);
  }
}

class Timmer extends Model {
  static final Timmer _singleton = new Timmer._internal();

  factory Timmer() {
    return _singleton;
  }
  Timmer._internal();

  FlutterBlue _flutterBlue = FlutterBlue.instance;

  /// Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  /// State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice device;
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  /// Device metrics
  LatLng gpsPosition;

  void init() {
    // Subscribe to state changes
    _stateSubscription = _flutterBlue.state.listen((s) {
      state = s;
      print('State updated: $state');
      notifyListeners();
    });
  }

  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
  }

  void startScan() {
    scanResults = new Map();
    _scanSubscription = _flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {
      if (scanResult.advertisementData.localName.startsWith('HM-')) {
        scanResults[scanResult.device.id] = scanResult;
        notifyListeners();
      }
    }, onDone: stopScan);

    isScanning = true;
    notifyListeners();
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    isScanning = false;
    notifyListeners();
  }

  connect(BluetoothDevice d) async {
    device = d;
    print('Connecting device ' + d.name);
    // Connect to device

    deviceConnection =
        device.connect(timeout: const Duration(seconds: 4)).asStream().listen(
              null,
              onDone: disconnect,
            );
    // Subscribe to connection changes
    deviceStateSubscription = device.state.listen((s) {
      deviceState = s;
      notifyListeners();
      if (s == BluetoothDeviceState.connected) {
        device.discoverServices().then((s) {
          services = s;
          _setNotifications();
          notifyListeners();
        });
      }
    });
  }

  disconnect() {
    // Remove all value changed listeners
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    device = null;
    notifyListeners();
  }

  _setNotifications() {
    _setNotification(_getCharacteristic(hm10UUID));
  }

  _getCharacteristic(String charUUID) {
    BluetoothCharacteristic characteristic;
    for (BluetoothService s in services) {
      for (BluetoothCharacteristic c in s.characteristics) {
        if (c.uuid.toString() == charUUID) {
          characteristic = c;
        }
      }
    }
    return characteristic;
  }

  _setNotification(BluetoothCharacteristic characteristic) async {
    if (characteristic != null) {
      await characteristic.setNotifyValue(true);
      // ignore: cancel_subscriptions
      final sub = characteristic.value.listen((d) {
        _onValuesChanged(characteristic, d);
        notifyListeners();
      });
      // Add to map
      valueChangedSubscriptions[characteristic.uuid] = sub;
      notifyListeners();
    }
  }

  _onValuesChanged(BluetoothCharacteristic characteristic, List<int> data) {
    String uuid = characteristic.uuid.toString();
    print('onValuesChanged ' + characteristic.value.toString() + " " + uuid);

    if (uuid == hm10UUID) {
      gpsPosition = new LatLng(data[9] as double, data[10] as double);
    }
  }
}
