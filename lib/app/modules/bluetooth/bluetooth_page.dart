import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/connected_device.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/connecting_device.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/devices_list.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/turn_on_bluetooth.dart';
import 'package:timer_f1/app/modules/bluetooth/widgets/unauthorized_ble.dart';

final isScanningListEmptyProvider = Provider.autoDispose<bool>((ref) {
  final List<Device>? scannedDevices =
      ref.watch(bleControllerProvider.select((value) => value.scannedDevices));

  return scannedDevices != null && scannedDevices.isEmpty ? true : false;
});

class BluetoothPage extends HookConsumerWidget {
  final String? redirectTo;

  BluetoothPage({
    Key? key,
    this.redirectTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      var provider = ref.read(bleControllerProvider);
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        if (provider.pairedDevice != null) {
          await provider.connect(provider.pairedDevice!);
        } else if (provider.bluetoothState != BluetoothState.scanning) {
          provider.startScan();
        }
      });

      return provider.stopScan;
    }, []);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: HookConsumer(
                  builder: (BuildContext ctx, WidgetRef ref, Widget? widget) {
                BluetoothState bluetoothState = ref.watch(bleControllerProvider
                    .select((value) => value.bluetoothState));
                Device? connectedDevice = ref.watch(bleControllerProvider
                    .select((value) => value.connectedDevice));
                Device? pairedDevice = ref.watch(bleControllerProvider
                    .select((value) => value.pairedDevice));
                final onScan = useCallback(() {
                  if (bluetoothState != BluetoothState.scanning) {
                    ref.read(bleControllerProvider).startScan()?.onError(
                        (error) =>
                            FlushbarHelper.createError(message: error.message));
                  }
                }, [bluetoothState]);

                if (bluetoothState == BluetoothState.unauthorized) {
                  return UnauthorizedBLE();
                }

                if (bluetoothState == BluetoothState.off) {
                  return TurnOnBluetooth();
                }

                if (bluetoothState == BluetoothState.connected &&
                    connectedDevice != null) {
                  return ConnectedDevice(
                      deviceName: connectedDevice.name, redirectTo: redirectTo);
                }

                if ((bluetoothState == BluetoothState.connecting ||
                        bluetoothState == BluetoothState.connectionTimeout) &&
                    pairedDevice != null) {
                  return ConnectingToDevice(deviceName: pairedDevice.name);
                }

                return DeviceList(
                  isScanning: bluetoothState == BluetoothState.scanning,
                  onPair: (Device device) async {
                    ref.read(bleControllerProvider)
                      ..connect(device)
                      ..pairDevice(device);
                  },
                  onRetry: onScan,
                );
              }),
            ),
            SizedBox(
                height: 80,
                child: AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.blue[100],
                      ),
                      onPressed: () async {
                        await ref.read(bleControllerProvider).stopScan();
                        GoRouter.of(context).pop();
                      },
                    ),
                    centerTitle: true,
                    title: Text(
                      'Connecting...',
                      style: TextStyle(color: Colors.blue[100]),
                    ),
                    elevation: 0)),
          ],
        ));
  }
}
