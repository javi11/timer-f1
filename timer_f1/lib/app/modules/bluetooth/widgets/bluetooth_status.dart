import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/device_info.dart';

class BluetoothStatus extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BluetoothState bluetoothState = ref
        .watch(bleControllerProvider.select((value) => value.bluetoothState));
    Device? pairedDevice =
        ref.watch(bleControllerProvider.select((value) => value.pairedDevice));
    Device? connectedDevice = ref
        .watch(bleControllerProvider.select((value) => value.connectedDevice));

    final openDeviceInfo = useCallback(
        () => AwesomeDialog(
                headerAnimationLoop: false,
                context: context,
                animType: AnimType.SCALE,
                dialogType: DialogType.INFO,
                body: Center(
                  child: Consumer(builder: (ctx, ref, child) {
                    var provider = ref.watch(bleControllerProvider);
                    return DeviceInfo(
                        device:
                            provider.connectedDevice ?? provider.pairedDevice);
                  }),
                ),
                btnCancelText: 'Disconnect device',
                btnCancelOnPress: () async {
                  var provider = ref.read(bleControllerProvider);
                  await provider.disconnect();
                },
                btnOkText: 'Close',
                btnOkOnPress: () {})
            .show(),
        []);

    final onConnect = useCallback(() async {
      var provider = ref.read(bleControllerProvider);
      provider.connect(pairedDevice!);
      await provider.pairDevice(pairedDevice);
    }, [pairedDevice]);

    final onForgetDevice = useCallback(() async {
      await ref.read(bleControllerProvider).forgetDevice(pairedDevice!);
    }, [pairedDevice]);

    if (bluetoothState == BluetoothState.connected) {
      return Container(
          decoration: BoxDecoration(color: Colors.green[50]),
          child: ListTile(
            leading: Icon(Icons.bluetooth_connected),
            title: Text(connectedDevice!.name),
            onTap: openDeviceInfo,
          ));
    }
    if (bluetoothState == BluetoothState.connecting) {
      return Container(
          decoration: BoxDecoration(color: Colors.lightBlue[50]),
          child: ListTile(
            leading: Icon(Icons.bluetooth_searching),
            title: Text('Connecting to ${pairedDevice?.name}...'),
            trailing: CircularProgressIndicator(),
            onTap: openDeviceInfo,
          ));
    }

    if (bluetoothState == BluetoothState.off) {
      return Container(
          decoration: BoxDecoration(color: Colors.red[50]),
          child: ListTile(
            leading: Icon(Icons.bluetooth_disabled),
            title: Text('Bluetooth is off.'),
          ));
    }

    if (bluetoothState == BluetoothState.connectionTimeout ||
        pairedDevice != null) {
      return Container(
          decoration: BoxDecoration(color: Colors.amber[50]),
          child: ListTile(
            leading: Icon(Icons.bluetooth_disabled),
            title: Text('${pairedDevice?.name} disconnected'),
            onTap: () {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.INFO,
                      animType: AnimType.BOTTOMSLIDE,
                      title:
                          'What do you want to do with ${pairedDevice?.name}?',
                      desc:
                          'Get closer to ${pairedDevice?.name} and push reconnect',
                      btnCancelText: 'Remove device',
                      btnCancelOnPress: onForgetDevice,
                      btnOkText: 'Reconnect',
                      btnOkOnPress: onConnect)
                  .show();
            },
          ));
    }

    return ListTile(
      leading: Icon(Icons.bluetooth),
      title: Text('Pair a device'),
      onTap: () => GoRouter.of(context).push(Routes.BLUETOOTH),
    );
  }
}
