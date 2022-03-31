import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ConnectedDevice extends HookWidget {
  final String deviceName;
  final String? redirectTo;

  ConnectedDevice({Key? key, required this.deviceName, this.redirectTo})
      : super(key: key);

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
                      "assets/animations/bluetooth-connected.json",
                      controller: controller,
                      repeat: true, onLoaded: (composition) {
                    controller.duration = composition.duration;
                    controller.forward().whenComplete(() => redirectTo != null
                        ? GoRouter.of(context).go(redirectTo!)
                        : GoRouter.of(context).pop());
                  }))),
          Center(
              child: Text(
            'Connected to $deviceName...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blue[100], fontSize: 16),
          )),
        ]));
  }
}
