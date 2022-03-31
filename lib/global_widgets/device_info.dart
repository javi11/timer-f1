import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/data/models/device_model.dart';

const titleStyle =
    TextStyle(fontWeight: FontWeight.bold, color: Colors.black54);

class DeviceInfo extends HookWidget {
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
    var statusColor = useState(Colors.green);
    useEffect(() {
      if (device!.connectionState == DeviceConnection.handshaking) {
        statusColor.value = Colors.amber;
      } else if (device!.connectionState == DeviceConnection.disconnected) {
        statusColor.value = Colors.red;
      } else {
        statusColor.value = Colors.green;
      }
      return null;
    }, [device!.connectionState]);

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Device id:',
            style: titleStyle,
          ),
          trailing: Text(device!.id),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Device name:',
            style: titleStyle,
          ),
          trailing: Text(device!.name),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Status:',
            style: titleStyle,
          ),
          trailing: Icon(
            Icons.circle,
            color: statusColor.value,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Device firmware:',
            style: titleStyle,
          ),
          trailing: device!.connectionState == DeviceConnection.handshaking
              ? CircularProgressIndicator()
              : Text(device!.firmware),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Device brand:',
            style: titleStyle,
          ),
          trailing: device!.connectionState == DeviceConnection.handshaking
              ? CircularProgressIndicator()
              : Text(device!.brand.toString()),
        ),
      ],
    );
  }
}
