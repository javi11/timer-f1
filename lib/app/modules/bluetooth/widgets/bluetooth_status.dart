import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:backdrop_modal_route/backdrop_modal_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/bluetooth_device_info.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/drawer_items.dart';
import 'package:timer_f1/global_widgets/modal.dart';

const double deviceStatusModalHeight = 400;

class BluetoothStatus extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BluetoothState bluetoothState = ref
        .watch(bleControllerProvider.select((value) => value.bluetoothState));
    Device? pairedDevice =
        ref.watch(bleControllerProvider.select((value) => value.pairedDevice));
    Device? connectedDevice = ref
        .watch(bleControllerProvider.select((value) => value.connectedDevice));

    final openDeviceInfo = useCallback(() {
      Navigator.push(
          context,
          BackdropModalRoute(
            topPadding:
                MediaQuery.of(context).size.height - deviceStatusModalHeight,
            canBarrierDismiss: true,
            safeAreaBottom: false,
            overlayContentBuilder: (context) => CustomModal(
                height: deviceStatusModalHeight,
                title: 'Device Status',
                content: BluetoothDeviceInfo()),
          ));
    }, [context]);

    final onConnect = useCallback(() async {
      var provider = ref.read(bleControllerProvider);
      provider.connect(pairedDevice!);
      await provider.pairDevice(pairedDevice);
    }, [pairedDevice]);

    final onForgetDevice = useCallback(() async {
      await ref.read(bleControllerProvider).forgetDevice(pairedDevice!);
    }, [pairedDevice]);

    if (bluetoothState == BluetoothState.connected) {
      return DrawerItem(
        textColor: Colors.green[200],
        leading: Icon(Icons.bluetooth_connected),
        title: connectedDevice!.name,
        onTap: openDeviceInfo,
      );
    }
    if (bluetoothState == BluetoothState.connecting) {
      return DrawerItem(
        textColor: Colors.yellow[200],
        leading: Icon(Icons.bluetooth_searching),
        title: 'Connecting to ${pairedDevice?.name}...',
        trailing: CircularProgressIndicator(
          color: Colors.blue[100],
        ),
        onTap: openDeviceInfo,
      );
    }

    if (bluetoothState == BluetoothState.off) {
      return DrawerItem(
        textColor: Colors.red[200],
        leading: Icon(Icons.bluetooth_disabled),
        title: 'Bluetooth is off.',
      );
    }

    if (bluetoothState == BluetoothState.connectionTimeout ||
        pairedDevice != null) {
      return DrawerItem(
        textColor: Colors.red[200],
        leading: Icon(Icons.bluetooth_disabled),
        title: '${pairedDevice?.name} disconnected',
        onTap: () {
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.INFO,
                  animType: AnimType.BOTTOMSLIDE,
                  title: 'What do you want to do with ${pairedDevice?.name}?',
                  desc:
                      'Get closer to ${pairedDevice?.name} and push reconnect',
                  btnCancelText: 'Remove device',
                  btnCancelOnPress: onForgetDevice,
                  btnOkText: 'Reconnect',
                  btnOkOnPress: onConnect)
              .show();
        },
      );
    }

    return DrawerItem(
      leading: Icon(Icons.bluetooth),
      title: 'Pair a device',
      onTap: () => GoRouter.of(context).push(Routes.BLUETOOTH),
    );
  }
}
