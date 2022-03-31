import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final double fontSize;
  final Size minimumSize;
  final void Function() onPressed;
  final String text;

  const CancelButton(
      {Key? key,
      required this.text,
      required this.minimumSize,
      required this.onPressed,
      this.fontSize = 18})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Text(
          text,
          style: TextStyle(
              color: Colors.red.shade300,
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ),
        style: TextButton.styleFrom(
            minimumSize: minimumSize,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(color: Colors.red.shade300, width: 1.5)),
            elevation: 0),
        onPressed: onPressed);
  }
}
