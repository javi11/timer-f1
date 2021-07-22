import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart' as bt;
import 'package:timerf1c/models/bluetooth_device.dart';
import 'package:timerf1c/models/device.dart';
import 'package:timerf1c/models/settings.dart';
import 'package:timerf1c/models/usb_device.dart';
import 'package:usb_serial/usb_serial.dart';
import '../types.dart';

const TIMER_NAME = 'DSD TECH';
const Duration tenSeconds = Duration(seconds: 10);

class ConnectionProvider extends ChangeNotifier {
  BluetoothDevice? _pairedBTDevice;
  Device? connectedDevice;
  ConnectionStatus _connectionStatus = ConnectionStatus.DISCONNECTED;
  ConnectionStatus get connectionStatus => _connectionStatus;
  BluetoothDevice? get pariedBTDevice => _pairedBTDevice;
  bt.FlutterBlue flutterBlue = bt.FlutterBlue.instance;
  StreamSubscription<List<bt.ScanResult>>? _scanSubscription;
  StreamSubscription<bt.BluetoothDeviceState>? _btSubscription;

  List<bt.ScanResult> _devicesList = [];
  UnmodifiableListView<bt.ScanResult> get devicesList =>
      UnmodifiableListView(_devicesList);

  Future<void> init() async {
    await this.loadPairedDeviceFromSettings();

    UsbSerial.usbEventStream!.listen((event) {
      if (event.event!.contains(UsbEvent.ACTION_USB_ATTACHED) &&
          event.device!.manufacturerName == USB_DEVICE_NAME) {
        connectedDevice = Device(DeviceType.USB, usbDevice: event.device);
      } else if (event.event!.contains(UsbEvent.ACTION_USB_DETACHED) &&
          connectedDevice != null) {
        this.disconnect();
      }
    });
  }

  Future<void> loadPairedDeviceFromSettings() async {
    _pairedBTDevice = await Settings.pairedBTDevice;
    notifyListeners();
  }

  Future<void> pairADevice(BluetoothDevice btDevice) async {
    _pairedBTDevice = btDevice;
    await Settings.savePairedBTDevice(btDevice);

    notifyListeners();
  }

  Future<void> _disconnect() async {
    await _btSubscription?.cancel();
    if (_connectionStatus == ConnectionStatus.CONNECTED) {
      await connectedDevice!.disconnect();
    }
    _connectionStatus = ConnectionStatus.DISCONNECTED;
    connectedDevice = null;
  }

  Future<void> deletePairedDevice() async {
    if (_pairedBTDevice != null) {
      await this._disconnect();

      _pairedBTDevice = null;
      notifyListeners();
    }
  }

  Future<bool> isUsbConnected() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.length == 0) {
      return false;
    }

    return true;
  }

  Future<void> stopDataStream() async {
    if (connectedDevice!.type == DeviceType.Bluetooth) {
      await (connectedDevice as BluetoothDevice).stopDataStream();
    }
  }

  Future<void> connect(Device? device) async {
    if (device != null) {
      // Force disconnect bluetooth in case that usb is connected
      if (device.type == DeviceType.USB &&
          _connectionStatus == ConnectionStatus.CONNECTED) {
        await connectedDevice!.disconnect();
        _connectionStatus = ConnectionStatus.DISCONNECTED;
      }

      if (_connectionStatus != ConnectionStatus.CONNECTED) {
        _connectionStatus = ConnectionStatus.CONNECTING;
        notifyListeners();

        try {
          await device.connect(onTimeout: () {
            device.disconnect();
            _connectionStatus = ConnectionStatus.TIMEOUT_ERROR;
            notifyListeners();
          });
        } catch (e) {
          print('Error on connecting the device:');
          print(e);
          _connectionStatus = ConnectionStatus.UNKNOWN_ERROR;
          notifyListeners();
        }
        connectedDevice = device;

        if (connectedDevice!.type == DeviceType.Bluetooth) {
          _btSubscription =
              (connectedDevice as BluetoothDevice).state.listen((event) {
            if (event == bt.BluetoothDeviceState.connected) {
              _connectionStatus = ConnectionStatus.CONNECTED;
            } else if (event == bt.BluetoothDeviceState.disconnected &&
                _connectionStatus != ConnectionStatus.TIMEOUT_ERROR) {
              _connectionStatus = ConnectionStatus.DISCONNECTED;
            }

            notifyListeners();
          });
        } else {
          _connectionStatus = ConnectionStatus.CONNECTED;
        }

        notifyListeners();
      }
    }
  }

  Future<void> disconnect() async {
    await this._disconnect();

    notifyListeners();
  }

  Future<void> startScan({dynamic timeout}) async {
    _connectionStatus = ConnectionStatus.SCANNING;
    notifyListeners();
    await flutterBlue.stopScan();
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
    }
    _scanSubscription = flutterBlue.scanResults.listen((results) async {
      if (_pairedBTDevice != null) {
        var found = results.firstWhereOrNull(
            (element) => element.device.id.id == _pairedBTDevice!.id);

        if (found != null) {
          _scanSubscription?.cancel();
          await flutterBlue.stopScan();
          Device device = Device(DeviceType.Bluetooth, btDevice: found.device);
          this.connect(device);
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
    _scanSubscription?.cancel();
    await flutterBlue.stopScan();
    if (_connectionStatus != ConnectionStatus.CONNECTED) {
      _connectionStatus = ConnectionStatus.DISCONNECTED;
    }
    notifyListeners();
  }
}
