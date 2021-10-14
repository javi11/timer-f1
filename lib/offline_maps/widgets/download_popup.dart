import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:lottie/lottie.dart';

class DownloadPopUp extends StatefulWidget {
  final double percentage;
  final void Function(BuildContext context) onCancel;
  final void Function(BuildContext context) onDownloadFinish;

  DownloadPopUp(
      {Key? key,
      required this.percentage,
      required this.onCancel,
      required this.onDownloadFinish})
      : super(key: key);
  @override
  _DownloadPopUpState createState() => _DownloadPopUpState();
}

class _DownloadPopUpState extends State<DownloadPopUp>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (widget.percentage == 100) {
      return SizedBox(
          width: 75,
          height: 85,
          child: Lottie.asset("assets/animations/download-success.json",
              controller: _controller, repeat: true, onLoaded: (composition) {
            _controller.duration = composition.duration;
            _controller
                .forward()
                .whenComplete(() => widget.onDownloadFinish(context));
          }));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
          width: 75,
          height: 75,
          child: LiquidCircularProgressIndicator(
            value: widget.percentage / 100, // Defaults to 0.5.
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
            borderColor: Colors.blue,
            borderWidth: 2.0,
            direction: Axis
                .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
            center: Text(
              widget.percentage.toStringAsFixed(0) + '%',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
      TextButton(
        onPressed: () => widget.onCancel(context),
        child: Text('Cancel'),
      ),
    ]);
  }
}
