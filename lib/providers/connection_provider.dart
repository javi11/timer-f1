import 'package:flutter/material.dart';
import 'package:timmer/models/bluetooth_device.dart';
import 'package:timmer/models/device.dart';
import 'package:timmer/models/settings.dart';
import 'package:usb_serial/usb_serial.dart';
import '../types.dart';

class ConnectionProvider extends ChangeNotifier {
  BluetoothDevice _pairedBTDevice;
  Device connectedDevice;
  ConnectionStatus _connectionStatus = ConnectionStatus.DISCONNECTED;
  ConnectionStatus get connectionStatus => _connectionStatus;
  BluetoothDevice get pariedBTDevice => _pairedBTDevice;

  Future<void> loadPairedDeviceFromSettings() async {
    _pairedBTDevice = await Settings.pairedBTDevice;
    notifyListeners();
  }

  Future<void> pairADevice(BluetoothDevice btDevice) async {
    _pairedBTDevice = btDevice;
    await Settings.savePairedBTDevice(btDevice);

    notifyListeners();
  }

  Future<bool> isUsbConnected() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.length == 0) {
      return false;
    }

    return true;
  }
}
