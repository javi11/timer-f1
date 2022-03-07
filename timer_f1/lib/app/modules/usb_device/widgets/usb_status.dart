import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_repository.dart';

class UsbStatus extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedDevice = ref
        .watch(usbControllerProvider.select((value) => value.connectedDevice));

    return Container(
        decoration: BoxDecoration(color: Colors.green[50]),
        child: ListTile(
          leading: Icon(Icons.usb),
          title: Text('${connectedDevice!.name} connected'),
        ));
  }
}
