import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;
  final Color bgColor;
  final bool border;
  final double size;

  RoundButton(
      {Key? key,
      required this.child,
      required this.onPressed,
      this.bgColor = Colors.white,
      this.border = true,
      this.size = 56})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        shape: border
            ? CircleBorder(side: BorderSide(color: Colors.black26))
            : null,
        color: bgColor, // button color
        child: InkWell(
          splashColor: Colors.grey, // inkwell color
          child: SizedBox(width: size, height: size, child: child),
          onTap: onPressed as void Function()?,
        ),
      ),
    );
  }
}
