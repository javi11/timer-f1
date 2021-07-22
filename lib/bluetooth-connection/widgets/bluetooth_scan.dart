import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timerf1c/types.dart';

class ScanView extends StatefulWidget {
  final ConnectionStatus connectionStatus;
  final Function startScan;

  ScanView({Key? key, required this.connectionStatus, required this.startScan})
      : super(key: key);
  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller!.reset();
  }

  @override
  void dispose() {
    _controller!.stop();
    _controller!.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (widget.connectionStatus == ConnectionStatus.NO_DEVICES_FOUND) {
      _controller?.stop();
    }
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
                controller: this._controller,
                repeat: true, onLoaded: (composition) {
              _controller!.duration = composition.duration;
              _controller!.repeat();
              if (widget.connectionStatus != ConnectionStatus.SCANNING) {
                widget.startScan();
              }
            }),
          )),
          Center(
              child: Text(
            widget.connectionStatus == ConnectionStatus.NO_DEVICES_FOUND
                ? 'No devices found. \n Please get closer to your device.'
                : 'Scanning for devices...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )),
          SizedBox(
            height: 10,
          ),
          widget.connectionStatus == ConnectionStatus.NO_DEVICES_FOUND
              ? FlatButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    widget.startScan(timeout: Duration(seconds: 20));
                    _controller!.repeat();
                  },
                  child: Text(
                    "Retry",
                    style: TextStyle(fontSize: 20.0),
                  ),
                )
              : SizedBox()
        ]));
  }
}
