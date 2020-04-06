import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:timmer/tracking/components/buetooth_off.dart';
import 'package:timmer/tracking/components/device_pairing.dart';

typedef Widget BluetoothBuilder(BuildContext context);

class TimmerBluetoothProvider extends HookWidget {
  const TimmerBluetoothProvider({Key key, BluetoothBuilder childBuilder})
      : _childBuilder = childBuilder,
        super(key: key);

  final BluetoothBuilder _childBuilder;

  @override
  Widget build(BuildContext context) {
    final device = useState(null);

    return Scaffold(body: Center(
      child: HookBuilder(
        builder: (context) {
          final stream = useMemoized(
            () => FlutterBlue.instance.state,
          );

          AsyncSnapshot<BluetoothState> isBluetoothAvailable =
              useStream(stream);
          if (isBluetoothAvailable.data != BluetoothState.on) {
            return BluetoothOff();
          }
          if (device.value == null) {
            return DevicePairing(
                callback: (BluetoothDevice val) => device.value = val);
          }
          return _childBuilder(context);
        },
      ),
    ));
  }
}
