import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/data/models/device_model.dart';

class DeviceInfo extends StatelessWidget {
  final Device? device;
  const DeviceInfo({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      return Lottie.asset("assets/animations/device-disconnected.json",
          repeat: true);
    }

    return Column(
      children: [
        ListTile(
          title: const Text('Device id:'),
          trailing: Text(device!.id),
        ),
        ListTile(
          title: const Text('Device name:'),
          trailing: Text(device!.name),
        ),
        ListTile(
          title: const Text('Device firmware:'),
          trailing: device!.connectionState == DeviceConnection.handshaking
              ? CircularProgressIndicator()
              : Text(device!.firmware),
        ),
        ListTile(
          title: const Text('Device brand:'),
          trailing: device!.connectionState == DeviceConnection.handshaking
              ? CircularProgressIndicator()
              : Text(device!.brand.toString()),
        ),
      ],
    );
  }
}
