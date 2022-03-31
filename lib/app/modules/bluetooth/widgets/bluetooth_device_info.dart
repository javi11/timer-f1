import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/global_widgets/buttons/accept_button.dart';
import 'package:timer_f1/global_widgets/buttons/cancel_button.dart';
import 'package:timer_f1/global_widgets/device_info.dart';

class BluetoothDeviceInfo extends ConsumerWidget {
  const BluetoothDeviceInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var provider = ref.watch(bleControllerProvider);

    return Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: Column(children: [
          DeviceInfo(device: provider.connectedDevice ?? provider.pairedDevice),
          Spacer(),
          Container(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: provider.connectedDevice != null
                      ? CancelButton(
                          text: 'Disconnect',
                          minimumSize: Size(350, 45),
                          onPressed: () async {
                            await provider.disconnect();
                          })
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CancelButton(
                                text: 'Forget Device',
                                minimumSize: Size(150, 45),
                                onPressed: () async {
                                  await provider
                                      .forgetDevice(provider.pairedDevice!);
                                  Navigator.of(context).pop();
                                }),
                            AcceptButton(
                                text: 'Reconnect',
                                onPressed: () async {
                                  await provider
                                      .connect(provider.pairedDevice!);
                                },
                                minimumSize: Size(150, 45)),
                          ],
                        )))
        ])));
  }
}
