import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timerf1c/types.dart';

class ConnectingDevice extends StatefulWidget {
  final String deviceName;
  final Function onConnect;
  final Function onConnected;
  final ConnectionStatus connectionStatus;

  ConnectingDevice(
      {Key key,
      @required this.deviceName,
      @required this.onConnect,
      @required this.connectionStatus,
      @required this.onConnected})
      : super(key: key);
  @override
  _ConnectingDeviceState createState() => _ConnectingDeviceState();
}

class _ConnectingDeviceState extends State<ConnectingDevice>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _errorAnimationController;
  AnimationController _successAnimationController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _errorAnimationController = AnimationController(vsync: this);
    _successAnimationController = AnimationController(vsync: this);
    _errorAnimationController.reset();
    _successAnimationController.reset();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller
      ..stop()
      ..dispose();
    _errorAnimationController
      ..stop()
      ..dispose();
    _successAnimationController
      ..stop()
      ..dispose();
    super.dispose();
  }

  Widget _animation() {
    if (widget.connectionStatus == ConnectionStatus.TIMEOUT_ERROR ||
        widget.connectionStatus == ConnectionStatus.UNKNOWN_ERROR) {
      return Lottie.asset("assets/animations/error-animation.json",
          controller: this._errorAnimationController,
          repeat: true, onLoaded: (composition) {
        _errorAnimationController.duration = composition.duration;
        _errorAnimationController.forward();
      });
    }
    if (widget.connectionStatus == ConnectionStatus.CONNECTED) {
      return Lottie.asset("assets/animations/bluetooth-connected.json",
          controller: this._successAnimationController,
          repeat: true, onLoaded: (composition) {
        _successAnimationController.duration = composition.duration;
        _successAnimationController
            .forward()
            .whenComplete(() => widget.onConnected());
      });
    }

    return Lottie.asset("assets/animations/bluetooth-connecting.json",
        controller: this._controller, repeat: true, onLoaded: (composition) {
      _controller.duration = composition.duration;
      _controller
          .forward()
          .whenComplete(() => _controller.repeat(min: 0.16, reverse: true));
      widget.onConnect();
    });
  }

  Widget _infoText() {
    if (widget.connectionStatus == ConnectionStatus.TIMEOUT_ERROR ||
        widget.connectionStatus == ConnectionStatus.UNKNOWN_ERROR) {
      return Text(
          'Error connecting to ${widget.deviceName}.\n Please make sure that the device is turned ON.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.red[50],
              fontWeight: FontWeight.bold,
              fontSize: 16));
    }

    if (widget.connectionStatus == ConnectionStatus.CONNECTED) {
      return Text(
        'Connected to ${widget.deviceName}!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16),
      );
    }

    return Text(
      'Connecting to ${widget.deviceName}...',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  Widget build(BuildContext context) {
    bool error = widget.connectionStatus == ConnectionStatus.UNKNOWN_ERROR ||
        widget.connectionStatus == ConnectionStatus.TIMEOUT_ERROR;
    if (error) {
      _controller?.stop();
      if (_errorAnimationController.duration != null) {
        _errorAnimationController.forward(from: 0);
      }
    }
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.blue[300]])),
        child: Column(children: [
          Center(
              child: SizedBox(
            width: 400,
            height: 400,
            child: _animation(),
          )),
          Center(child: _infoText()),
          SizedBox(
            height: 10,
          ),
          error
              ? FlatButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    widget.onConnect();
                    _controller
                      ..reset()
                      ..forward().whenComplete(
                          () => _controller.repeat(min: 0.16, reverse: true));
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
