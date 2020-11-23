import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:timmer/models/bluetooth_device.dart';
import 'package:timmer/models/device.dart';
import 'package:timmer/models/settings.dart';
import 'package:timmer/types.dart';
import 'package:timmer/util/timer_data_transformer.dart';

const Duration tenSeconds = Duration(seconds: 10);
const TIMER_NAME = 'DSD TECH';
const CUSTOM_SERVICE_UUID = '0000ffe0-0000-1000-8000-00805f9b34fb';
const CUSTOM_CHARACTERISTIC_UUID = '0000ffe1-0000-1000-8000-00805f9b34fb';
enum DeviceBtType { LE, CLASSIC, DUAL, UNKNOWN }
enum ConnectionType { Bluetooth, USB }

class BluetoothProvider extends ChangeNotifier {
  Device pairedDevice;
  Settings _settings;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<List<ScanResult>> subscription;

  List<ScanResult> _devicesList = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.DISCONNECTED;
  BluetoothDevice _connection;
  BluetoothCharacteristic _characteristic;

  BluetoothDevice get connection => _connection;
  ConnectionStatus get connectionStatus => _connectionStatus;
  UnmodifiableListView<ScanResult> get devicesList =>
      UnmodifiableListView(_devicesList);

  BluetoothProvider update(Settings settings) {
    if (settings != null) {
      _settings = settings;

      if (_settings.pairedDeviceMAC != null) {
        BluetoothDevice device = BluetoothDevice.createBluetoothDevice(
            deviceIdentifier: _settings.pairedDeviceMAC,
            deviceName: _settings.pairedDeviceName);
        pairedDevice = Device(DeviceType.Bluetooth, {btDevice: device})
      }
    }

    return this;
  }

  Future<void> startScan({dynamic timeout}) async {
    _connectionStatus = ConnectionStatus.SCANNING;
    notifyListeners();
    await flutterBlue.stopScan();
    if (_connection != null) {
      await _connection.disconnect();
    }
    subscription = flutterBlue.scanResults.listen((results) async {
      if (pairedDevice != null) {
        var found = results.firstWhere(
            (element) => element.device.id.id == pairedDevice.id.id,
            orElse: () => null);

        if (found != null) {
          subscription?.cancel();
          await flutterBlue.stopScan();
          pairADevice(found.device);
          connectToPairedDevice();
        }
      } else {
        _devicesList = results
            .where((element) => element.device.name.contains(TIMER_NAME))
            .toList();
        notifyListeners();
      }
    });
    try {
      await flutterBlue.startScan(
          timeout: timeout == null ? tenSeconds : timeout);
    } catch (e) {}
    if (_devicesList.length == 0) {
      _connectionStatus = ConnectionStatus.NO_DEVICES_FOUND;
    } else if (_connectionStatus != ConnectionStatus.CONNECTED) {
      _connectionStatus = ConnectionStatus.DISCONNECTED;
    }

    notifyListeners();
  }

  Future<void> stopScan() async {
    subscription?.cancel();
    await flutterBlue.stopScan();
    if (_connectionStatus != ConnectionStatus.CONNECTED) {
      _connectionStatus = ConnectionStatus.DISCONNECTED;
    }
    notifyListeners();
  }

  void pairADevice(BluetoothDevice device) {
    _connection = device;
    pairedDevice = device;
    _settings.pairedDeviceMAC = device.id.id;
    _settings.pairedDeviceName = device.name;

    notifyListeners();
  }

  Future<void> connectToPairedDevice() async {
    if (_connectionStatus != ConnectionStatus.CONNECTED &&
        _connection != null) {
      _connectionStatus = ConnectionStatus.CONNECTING;
      notifyListeners();
      try {
        await _connection.connect().timeout(Duration(seconds: 20),
            onTimeout: () {
          _connection.disconnect();
          _connectionStatus = ConnectionStatus.TIMEOUT_ERROR;
          notifyListeners();
        });
      } catch (e) {
        print('Error on connecting the device:');
        print(e);
        _connectionStatus = ConnectionStatus.UNKNOWN_ERROR;
        notifyListeners();
      }

      _connection.state.listen((event) {
        if (event == BluetoothDeviceState.connected) {
          _connectionStatus = ConnectionStatus.CONNECTED;
        } else if (event == BluetoothDeviceState.disconnected &&
            _connectionStatus != ConnectionStatus.TIMEOUT_ERROR) {
          _connectionStatus = ConnectionStatus.DISCONNECTED;
        }
        notifyListeners();
      });
    }
  }

  Future<Stream<List<String>>> getGenericServiceDataStream() async {
    Stream<List<String>> stream;
    if (_connectionStatus == ConnectionStatus.CONNECTED) {
      List<BluetoothService> services = await _connection.discoverServices();
      BluetoothService service = services.firstWhere(
          (service) => service.uuid.toString() == CUSTOM_SERVICE_UUID);
      if (service != null) {
        _characteristic = service.characteristics.firstWhere(
            (element) => element.uuid.toString() == CUSTOM_CHARACTERISTIC_UUID);
        if (_characteristic != null) {
          await _characteristic.setNotifyValue(true);
          stream = _characteristic.value
              .map<String>((val) => Utf8Decoder().convert(val))
              .transform(TimerDataTransformer());
        }
      }
    }

    return stream;
  }

  Future<void> stopListening() async {
    if (_characteristic != null) {
      await _characteristic.setNotifyValue(false);
    }
  }

  Future<void> deletePairedDevice() async {
    if (_connection != null) {
      if (_connectionStatus == ConnectionStatus.CONNECTED) {
        await this.stopListening();
        await _connection.disconnect();
      }
      _connectionStatus = ConnectionStatus.DISCONNECTED;
      _connection = null;
      notifyListeners();
    }
  }

  Future<void> disconnectPairedDevice() async {
    if (_connection != null) {
      await _connection.disconnect();
      await this.stopListening();
    }

    _connectionStatus = ConnectionStatus.DISCONNECTED;
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
