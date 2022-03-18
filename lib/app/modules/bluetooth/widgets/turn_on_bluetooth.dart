import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TurnOnBluetooth extends Container {
  TurnOnBluetooth({Key? key}) : super(key: key);

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
            child: Lottie.asset("assets/animations/bluetooth-off.json",
                repeat: true),
          )),
          Center(
              child: Text(
                  'Turn on your bluetooth connection to start scanning.',
                  style: TextStyle(fontSize: 18.0, color: Colors.white))),
        ]));
  }
}
