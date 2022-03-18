import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_tracker_controller.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';

class ConnectionStatusCircle extends ConsumerWidget {
  const ConnectionStatusCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var bluetoothState = ref
        .watch(bleControllerProvider.select((value) => value.bluetoothState));
    var pairedDevice =
        ref.watch(bleControllerProvider.select((value) => value.pairedDevice));
    var usbConnected =
        ref.watch(usbControllerProvider.select((value) => value.isConnected));

    if (usbConnected == true) {
      return CircleAvatar(
        child: Icon(Icons.usb, color: Colors.white),
      );
    } else if (pairedDevice == null) {
      return CircleAvatar(
        child: Icon(Icons.usb_off, color: Colors.red),
      );
    }

    // There is a paired device, so we can try to connect to it.
    if (bluetoothState == BluetoothState.connected) {
      return CircleAvatar(
        child: Icon(Icons.bluetooth_connected, color: Colors.white),
      );
    }

    if (bluetoothState == BluetoothState.connecting) {
      return CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.bluetooth_searching, color: Colors.white),
      );
    }

    return InkWell(
      onTap: () async {
        await ref
            .read(flightControllerProvider)
            .onReConnect(ref.read(bleControllerProvider).pairedDevice!);
      },
      child: CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(
          Icons.bluetooth_disabled,
          color: Colors.white,
        ),
      ),
    );
  }
}
