import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Flushbar buildVoltageWarningPopup() {
  return Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    borderRadius: 8,
    backgroundGradient: LinearGradient(
      colors: [Colors.red.shade800, Colors.red.shade700],
      stops: [0.6, 1],
    ),
    boxShadows: [
      BoxShadow(
        color: Colors.black45,
        offset: Offset(3, 3),
        blurRadius: 3,
      ),
    ],
    // All of the previous Flushbars could be dismissed by swiping down
    // now we want to swipe to the sides
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    // The default curve is Curves.easeOut
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
    icon: Icon(Icons.battery_alert),
    title: 'Voltage Warning',
    message: 'Voltage is below 3.20 V',
  );
}
