import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/connecting_animation_controller.dart';

class ConnectingToDevice extends GetWidget<ConnectingAnimationController> {
  final String deviceName;

  ConnectingToDevice({
    Key? key,
    required this.deviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      controller: controller.animationControl,
                      repeat: true, onLoaded: (composition) {
                    controller.animationControl.duration = composition.duration;
                    controller.animationControl.forward().whenComplete(() =>
                        controller.animationControl
                            .repeat(min: 0.16, reverse: true));
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
