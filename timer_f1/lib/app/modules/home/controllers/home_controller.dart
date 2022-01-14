import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animator/widgets/in_out_animation.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final GlobalKey<InOutAnimationState> fabAnimation =
      GlobalKey<InOutAnimationState>();

  final currentPage = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    fabAnimation.currentState!.dispose();
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              fabAnimation.currentState!.animateIn();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              fabAnimation.currentState!.animateOut();
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }
}
