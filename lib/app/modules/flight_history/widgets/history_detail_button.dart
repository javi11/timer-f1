import 'package:flutter/material.dart';

class HistoryDetailButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final BorderRadius borderRadius;
  final Color backgroundColor;

  const HistoryDetailButton(
      {Key? key,
      required this.text,
      required this.onPressed,
      required this.borderRadius,
      required this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
            fixedSize: Size.fromHeight(70),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
              color: Colors.blue[50]!,
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ));
  }
}
