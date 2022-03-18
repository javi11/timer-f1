import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';

class ConnectingToDevice extends HookWidget {
  final String deviceName;

  ConnectingToDevice({
    Key? key,
    required this.deviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController();

    return Container(
        padding: EdgeInsets.all(22.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue[300]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Column(children: [
          Center(
              child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Lottie.asset(
                      "assets/animations/bluetooth-connecting.json",
                      controller: controller,
                      repeat: true, onLoaded: (composition) {
                    controller.duration = composition.duration;
                    controller.forward().whenComplete(
                        () => controller.repeat(min: 0.16, reverse: true));
                  }))),
          Center(
              child: Text(
            'Connecting to $deviceName...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )),
        ]));
  }
}
