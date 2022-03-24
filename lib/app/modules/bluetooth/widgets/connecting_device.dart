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
        padding: EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue[400]!,
            Colors.indigo[800]!,
          ],
        )),
        child: Padding(
            padding: EdgeInsets.all(22),
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
                style: TextStyle(color: Colors.blue[100], fontSize: 16),
              )),
            ])));
  }
}
