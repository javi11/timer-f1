import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
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
                  child: TextButton(
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all<Size>(Size(350, 45)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.red[400]!),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      side: BorderSide(color: Colors.red)))),
                      onPressed: () async {
                        await provider.disconnect();
                      },
                      child: Text(
                        'Disconnect',
                        style: TextStyle(color: Colors.red[50]),
                      ))))
        ])));
  }
}
