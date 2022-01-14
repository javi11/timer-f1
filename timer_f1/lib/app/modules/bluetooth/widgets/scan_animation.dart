import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScanAnimation extends Container {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Lottie.asset("assets/animations/start-scanning.json",
                repeat: true),
          )),
          Center(
              child: Text(
            'Searching for devices...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )),
        ]));
  }
}
