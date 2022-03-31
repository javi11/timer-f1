import 'package:backdrop_modal_route/backdrop_modal_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
import 'package:timer_f1/global_widgets/device_info.dart';
import 'package:timer_f1/global_widgets/drawer/drawer_items.dart';
import 'package:timer_f1/global_widgets/modals/custom_modal.dart';

const double deviceStatusModalHeight = 400;

class UsbStatus extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectedDevice = ref
        .watch(usbControllerProvider.select((value) => value.connectedDevice));
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
                content: Consumer(
                    builder: (ctx, ref, child) => DeviceInfo(
                        device:
                            ref.watch(usbControllerProvider).connectedDevice))),
          ));
    }, [context]);

    return Container(
        decoration: BoxDecoration(color: Colors.green[50]),
        child: DrawerItem(
          leading: Icon(Icons.usb),
          title: '${connectedDevice!.name} connected',
          onTap: openDeviceInfo,
        ));
  }
}
