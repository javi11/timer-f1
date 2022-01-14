import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class ConnectingAnimationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationControl;

  @override
  void onInit() {
    super.onInit();
    animationControl = AnimationController(vsync: this);
  }

  @override
  void onClose() {
    animationControl.dispose();
    super.onClose();
  }
}
