import 'package:flutter/material.dart';
import 'package:flutter_lottie/flutter_lottie.dart';

class BluetoothOff extends StatelessWidget {
  LottieController controller;

  @override
  Widget build(BuildContext context) {
    // user defined function

    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(30),
                child: SizedBox(
                    width: 300,
                    height: 300,
                    child: LottieView.fromFile(
                      filePath: "assets/animations/bluetooth-off.json",
                      autoPlay: true,
                      loop: true,
                      reverse: true,
                      onViewCreated: onViewCreatedFile,
                    )))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(30),
                child: Text('Please turn on the bluetooth module...'))
          ],
        )
      ],
    )));
  }

  Future<void> onViewCreatedFile(LottieController controller) async {
    this.controller = controller;
    await this.controller.setLoopAnimation(true);
  }
}
