import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/bluetooth_status.dart';
import 'package:timer_f1/app/modules/usb_device/widgets/usb_status.dart';

class DeviceStatus extends HookConsumerWidget {
  const DeviceStatus({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isUSBConnected =
        ref.watch(usbControllerProvider.select((value) => value.isConnected));

    if (isUSBConnected == true) {
      return UsbStatus();
    }

    return BluetoothStatus();
  }
}
