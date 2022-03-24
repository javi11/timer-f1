import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
import 'package:timer_f1/global_widgets/device_info.dart';
import 'package:timer_f1/global_widgets/drawer_items.dart';

class UsbStatus extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedDevice = ref
        .watch(usbControllerProvider.select((value) => value.connectedDevice));

    final openDeviceInfo = useCallback(
        () => AwesomeDialog(
                headerAnimationLoop: false,
                context: context,
                animType: AnimType.SCALE,
                dialogType: DialogType.INFO,
                body: Center(
                  child: Consumer(
                      builder: (ctx, ref, child) => DeviceInfo(
                          device: ref
                              .watch(usbControllerProvider)
                              .connectedDevice)),
                ),
                btnOkText: 'Close',
                btnOkOnPress: () {})
            .show(),
        []);

    return Container(
        decoration: BoxDecoration(color: Colors.green[50]),
        child: DrawerItem(
          leading: Icon(Icons.usb),
          title: '${connectedDevice!.name} connected',
          onTap: openDeviceInfo,
        ));
  }
}
