import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:timerf1c/models/bluetooth_device.dart';
import 'package:timerf1c/models/usb_device.dart';
import 'package:usb_serial/usb_serial.dart';

enum DeviceType { Bluetooth, USB }

abstract class Device {
  late final DeviceType type;
  String? get name;
  String get id;

  factory Device(DeviceType deviceType,
      {fb.BluetoothDevice? btDevice, UsbDevice? usbDevice}) {
    if (deviceType == DeviceType.Bluetooth) {
      return BluetoothDevice(btDevice);
    }

    return USBDevice(usbDevice);
  }

  Future<void> connect(
      {Duration? timeout, FutureOr<void> Function()? onTimeout}) async {}

  Future<Stream<List<String>?>?> getDataStream();

  Future<void> disconnect() async {}
}
