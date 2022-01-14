import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/connecting_animation_controller.dart';

class ConnectedDevice extends GetWidget<ConnectingAnimationController> {
  final String deviceName;

  ConnectedDevice({
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
                      "assets/animations/bluetooth-connected.json",
                      controller: controller.animationControl,
                      repeat: true, onLoaded: (composition) {
                    controller.animationControl.duration = composition.duration;
                    controller.animationControl.forward().whenComplete(() =>
                        Get.arguments['redirectTo'] != null
                            ? Get.offAndToNamed(Get.arguments['redirectTo']!)
                            : Get.back());
                  }))),
          Center(
              child: Text(
            'Connected to $deviceName...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )),
        ]));
  }
}
