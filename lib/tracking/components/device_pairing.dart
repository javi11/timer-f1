import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lottie/flutter_lottie.dart';

enum PairingStatus { FINDING_DEVICES, PAIRING, PAIR, ERROR }
typedef void DeviceCallback(BluetoothDevice val);

final String deviceName = 'DSD TECH';

class DevicePairing extends HookWidget {
  final DeviceCallback callback;
  DevicePairing({this.callback});
  LottieController controller;

  @override
  Widget build(BuildContext context) {
    final step = useState(PairingStatus.FINDING_DEVICES);

    return Scaffold(body: Center(child: HookBuilder(builder: (context) {
      Text message;
      if (step.value == PairingStatus.FINDING_DEVICES) {
        message = Text(
          'Looking for the timmer... Please keep the phone closer to it.',
          maxLines: 5,
        );
      } else if (step.value == PairingStatus.PAIRING) {
        message = Text('Pairing DSD TECH device.');
      } else if (step.value == PairingStatus.PAIR) {
        message = Text('Timmer pair.');
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(30),
                  child: SizedBox(
                      width: 300,
                      height: 300,
                      child: LottieView.fromFile(
                        filePath: "assets/animations/bluetooth-pairing.json",
                        autoPlay: true,
                        loop: true,
                        reverse: true,
                        onViewCreated: onViewCreatedFile,
                      )))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(30), child: message)
                  ],
                ),
              ),
            ],
          )
        ],
      );
    })));
  }

  Future<void> onViewCreatedFile(LottieController controller) async {
    this.controller = controller;
    await this.controller.setLoopAnimation(true);
  }
}
