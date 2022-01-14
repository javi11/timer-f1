import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoDevicesFound extends Container {
  final void Function() onRetry;

  NoDevicesFound({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(22.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.blue[300]!])),
        child: Column(children: [
          Center(
              child: SizedBox(
            width: 400,
            height: 400,
            child: Lottie.asset("assets/animations/error-animation.json",
                repeat: false),
          )),
          Center(
              child: Text(
                  'No devices found. \n Please get closer to your device.',
                  style: TextStyle(fontSize: 18.0, color: Colors.white))),
          SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: onRetry,
              child: Text(
                "Retry",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.all(8.0),
              ))
        ]));
  }
}
