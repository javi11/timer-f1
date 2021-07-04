import 'dart:async';
import 'dart:convert';
import 'package:timmer/models/device.dart';
import 'package:timmer/util/timer_data_transformer.dart';
import 'package:usb_serial/usb_serial.dart';

const USB_DEVICE_NAME = 'DSD';

class USBDevice implements Device {
  final DeviceType type = DeviceType.USB;
  UsbDevice _usbDevice;
  UsbPort _usbPort;

  USBDevice(UsbDevice _usbDevice);

  String get name {
    return _usbDevice.manufacturerName;
  }

  String get id {
    return _usbDevice.deviceId.toString();
  }

  Future<void> connect(
      {Duration timeout: const Duration(seconds: 20),
      FutureOr<void> Function() onTimeout}) async {
    _usbPort = await _usbDevice.create();

    bool openResult = await _usbPort.open();
    if (!openResult) {
      throw ('Failed to open usb port.');
    }

    await _usbPort.setDTR(true);
    await _usbPort.setRTS(true);

    _usbPort.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
  }

  Future<Stream<List<String>>> getDataStream() async {
    return _usbPort.inputStream
        .map<String>((val) => Utf8Decoder().convert(val))
        .transform(TimerDataTransformer());
  }

  Future<void> disconnect() async {
    try {
      _usbPort.close();
    } catch (e) {
      // Nothing to do if can not be closed.
    }
  }
}
