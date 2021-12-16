import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as bt;
import 'package:timerf1c/ble/ble.dart';
import 'package:timerf1c/ble/ble_scanner.dart';
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
  StreamSubscription<BleScannerState>? _scanSubscription;
  ConnectionStatus _connectionStatus = ConnectionStatus.DISCONNECTED;
  ConnectionStatus get connectionStatus => _connectionStatus;
  BluetoothDevice? get pariedBTDevice => _pairedBTDevice;

  late StreamSubscription<bt.ConnectionStateUpdate> _btSubscription;

  List<bt.DiscoveredDevice> _devicesList = [];
  UnmodifiableListView<bt.DiscoveredDevice> get devicesList =>
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
    await scanner.stopScan();
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
          _btSubscription = connector.state.listen((event) {
            if (event.connectionState == bt.DeviceConnectionState.connected) {
              _connectionStatus = ConnectionStatus.CONNECTED;
            } else if (event.connectionState ==
                    bt.DeviceConnectionState.disconnected &&
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
    await scanner.stopScan();
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
    }
    _scanSubscription = scanner.state.listen((results) async {
      if (results.scanIsInProgress == false && _devicesList.length == 0) {
        _connectionStatus = ConnectionStatus.NO_DEVICES_FOUND;
        notifyListeners();
      } else {
        if (_pairedBTDevice != null) {
          var found = results.discoveredDevices
              .firstWhereOrNull((element) => element.id == _pairedBTDevice!.id);

          if (found != null) {
            _scanSubscription?.cancel();
            await scanner.stopScan();
            Device device = Device(DeviceType.Bluetooth, btDevice: found);
            this.connect(device);
          }
        } else {
          _devicesList = results.discoveredDevices
              .where((element) => element.name.contains(TIMER_NAME))
              .toList();
          notifyListeners();
        }
      }
    });
    scanner.startScan([bt.Uuid.parse(CUSTOM_SERVICE_UUID)]);

    notifyListeners();
  }

  Future<void> stopScan() async {
    _scanSubscription?.cancel();
    await scanner.stopScan();
    if (_connectionStatus != ConnectionStatus.CONNECTED) {
      _connectionStatus = ConnectionStatus.DISCONNECTED;
    }
    notifyListeners();
  }
}
