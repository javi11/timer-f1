import 'package:flutter/material.dart';

Widget roundButton(Widget child, Function onPressed,
    [Color bgColor = Colors.white, bool border = true, double size = 56]) {
  return ClipOval(
    child: Material(
      shape:
          border ? CircleBorder(side: BorderSide(color: Colors.black26)) : null,
      color: bgColor, // button color
      child: InkWell(
        splashColor: Colors.grey, // inkwell color
        child: SizedBox(width: size, height: size, child: child),
        onTap: onPressed as void Function()?,
      ),
    ),
  );
}
