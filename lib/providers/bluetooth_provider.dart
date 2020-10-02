import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:timmer/types.dart';
import 'package:timmer/util/timmer_data_transformer.dart';

const Duration tenSeconds = Duration(seconds: 10);
const TIMER_NAME = 'DSD TECH';
const CUSTOM_SERVICE_UUID = '0000ffe0-0000-1000-8000-00805f9b34fb';
const CUSTOM_CHARACTERISTIC_UUID = '0000ffe1-0000-1000-8000-00805f9b34fb';

class BluetoothProvider extends ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<List<ScanResult>> subscription;

  List<ScanResult> _devicesList = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.DISSCONNECTED;
  BluetoothDevice _pairedDevice;

  BluetoothDevice get pairedDevice => _pairedDevice;
  ConnectionStatus get connectionStatus => _connectionStatus;
  UnmodifiableListView<ScanResult> get devicesList =>
      UnmodifiableListView(_devicesList);

  Future<void> startScan({dynamic timeout}) async {
    _connectionStatus = ConnectionStatus.SCANNING;
    notifyListeners();
    await flutterBlue.stopScan();
    if (_pairedDevice != null) {
      await _pairedDevice.disconnect();
    }
    subscription = flutterBlue.scanResults.listen((results) {
      _devicesList = results
          .where((element) => element.device.name.contains(TIMER_NAME))
          .toList();
      notifyListeners();
    });
    try {
      await flutterBlue.startScan(
          timeout: timeout == null ? tenSeconds : timeout);
    } catch (e) {}
    if (_devicesList.length == 0) {
      _connectionStatus = ConnectionStatus.NO_DEVICES_FOUND;
    } else if (_connectionStatus != ConnectionStatus.CONNECTED) {
      _connectionStatus = ConnectionStatus.DISSCONNECTED;
    }

    notifyListeners();
  }

  Future<void> stopScan() async {
    subscription?.cancel();
    await flutterBlue.stopScan();
    if (_connectionStatus != ConnectionStatus.CONNECTED) {
      _connectionStatus = ConnectionStatus.DISSCONNECTED;
    }
    notifyListeners();
  }

  void pairADevice(BluetoothDevice device) {
    _pairedDevice = device;
    notifyListeners();
  }

  Future<void> connectToPairedDevice() async {
    if (_connectionStatus != ConnectionStatus.CONNECTED &&
        _pairedDevice != null) {
      _connectionStatus = ConnectionStatus.CONNECTING;
      notifyListeners();
      try {
        await _pairedDevice.connect().timeout(Duration(seconds: 20),
            onTimeout: () {
          _pairedDevice.disconnect();
          _connectionStatus = ConnectionStatus.TIMEOUT_ERROR;
          notifyListeners();
        });
      } catch (e) {
        print('Error on connecting the device:');
        print(e);
        _connectionStatus = ConnectionStatus.UNKNOWN_ERROR;
        notifyListeners();
      }

      _pairedDevice.state.listen((event) {
        if (event == BluetoothDeviceState.connected) {
          _connectionStatus = ConnectionStatus.CONNECTED;
        } else if (event == BluetoothDeviceState.disconnected &&
            _connectionStatus != ConnectionStatus.TIMEOUT_ERROR) {
          _connectionStatus = ConnectionStatus.DISSCONNECTED;
        }
        notifyListeners();
      });
    }
  }

  Future<Stream<String>> start() async {
    Stream<String> stream;
    if (_connectionStatus == ConnectionStatus.CONNECTED) {
      List<BluetoothService> services = await _pairedDevice.discoverServices();
      BluetoothService service = services.firstWhere(
          (service) => service.uuid.toString() == CUSTOM_SERVICE_UUID);
      if (service != null) {
        BluetoothCharacteristic characteristic = service.characteristics
            .firstWhere((element) =>
                element.uuid.toString() == CUSTOM_CHARACTERISTIC_UUID);
        if (characteristic != null) {
          characteristic.setNotifyValue(true);
          stream = characteristic.value
              .map<String>((val) => Utf8Decoder().convert(val))
              .transform(TimmerDataTransformer());
        }
      }
    }

    return stream;
  }

  Future<void> deletePairedDevice() async {
    if (_pairedDevice != null) {
      await _pairedDevice.disconnect();
      _connectionStatus = ConnectionStatus.DISSCONNECTED;
      _pairedDevice = null;
      notifyListeners();
    }
  }

  Future<void> disconnectPairedDevice() async {
    if (_pairedDevice != null) {
      await _pairedDevice.disconnect();
    }

    _connectionStatus = ConnectionStatus.DISSCONNECTED;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_connectionStatus != ConnectionStatus.SCANNING) {
      this.stopScan();
    }
    if (_connectionStatus != ConnectionStatus.CONNECTED) {
      this.disconnectPairedDevice();
    }
    super.dispose();
  }
}
