import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';

class DeviceList extends ConsumerWidget {
  final bool isScanning;
  final Future<void> Function(Device device) onPair;
  final Function onRetry;

  DeviceList({
    Key? key,
    required this.isScanning,
    required this.onPair,
    required this.onRetry,
  }) : super(key: key);

  Widget build(BuildContext context, WidgetRef ref) {
    final deviceList = ref
        .watch(bleControllerProvider.select((value) => value.scannedDevices));
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(color: Colors.blue[50]),
            child: ListTile(
              title: Text(
                '${deviceList.length} DEVICES FOUND.',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey[500]),
              ),
              subtitle: Text(
                'Select one of the devices to pair.',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              trailing: isScanning
                  ? CircularProgressIndicator()
                  : TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(8.0)),
                      ),
                      onPressed: () => onRetry(),
                      child: Text(
                        "Scan",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      )),
            )),
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 200,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: deviceList.length,
                itemBuilder: (BuildContext ctx, int index) {
                  Device device = deviceList[index];

                  return ListTile(
                    onTap: () async {
                      await onPair(device);
                    },
                    leading: Icon(Icons.bluetooth),
                    isThreeLine: true,
                    subtitle:
                        Text('Signal: ${device.rssi} mDb \n Id: ${device.id}'),
                    title: Text(device.name),
                  );
                })),
      ],
    );
  }
}
