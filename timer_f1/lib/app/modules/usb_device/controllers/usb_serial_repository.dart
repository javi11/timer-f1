import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:usb_serial/usb_serial.dart';

final usbControllerProvider = ChangeNotifierProvider<USBController>((ref) {
  var usb = USBSerialController();
  ref.onDispose(() => usb.onClose());
  return usb;
});

abstract class USBController extends ChangeNotifier {
  late StreamSubscription<UsbEvent> usbSubscription;
  bool isConnected = false;
  Future<void> connect(Device device);
  Device? connectedDevice;
  void disconnect();
  void onClose();
}

class USBSerialController extends ChangeNotifier implements USBController {
  @override
  late StreamSubscription<UsbEvent> usbSubscription;
  UsbPort? _connectedPort;

  @override
  bool isConnected = false;

  @override
  Device? connectedDevice;

  void onInit() {
    usbSubscription =
        UsbSerial.usbEventStream!.listen(_handleConnectionStateUpdates);
  }

  USBSerialController() {
    usbSubscription =
        UsbSerial.usbEventStream!.listen(_handleConnectionStateUpdates);
  }

  @override
  Future<void> connect(Device device) async {
    String deviceId = device.id;

    print('SERVICE: Adding connection port for $deviceId');
    _connectedPort = await UsbSerial.createFromDeviceId(int.parse(deviceId));

    bool openResult = await _connectedPort!.open();
    if (!openResult) {
      print('SERVICE: Failed to open a the USB port -------');
    }

    await _connectedPort?.setDTR(true);
    await _connectedPort?.setRTS(true);

    _connectedPort?.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    isConnected = true;
    connectedDevice = device;
    notifyListeners();
  }

  @override
  void disconnect() {
    if (connectedDevice != null) {
      connectedDevice = null;
      _connectedPort = null;
      notifyListeners();
    }
  }

  @override
  void onClose() {
    usbSubscription.cancel();
  }

  /// Keep track of connected devices count and update the isConnected stream.
  void _handleConnectionStateUpdates(UsbEvent stateUpdate) {
    print('SERVICE: connectedDeviceStream update: $stateUpdate');
    String? connectionState = stateUpdate.event;

    String? deviceId = stateUpdate.device?.deviceId.toString();
    String? deviceName = stateUpdate.device?.deviceName;
    // Device connected.
    if (connectionState == UsbEvent.ACTION_USB_ATTACHED && deviceId != null) {
      connect(Device(id: deviceId, name: deviceName!)).catchError((error) {
        isConnected = false;
      });
      // Device disconnected.
    } else if (connectionState == UsbEvent.ACTION_USB_DETACHED) {
      if (connectedDevice == null) {
        print('SERVICE: Clearing connectedDevice (after disconnected) -------');
        connectedDevice = null;
        isConnected = false;
      }
    }
  }
}
