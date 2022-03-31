import 'package:flutter/material.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';

class VoltageIndicator extends StatelessWidget {
  final bool voltageAlert;
  final double? voltage;

  VoltageIndicator(
      {Key? key, required this.voltageAlert, required this.voltage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isNullVoltage(voltage)) {
      return Tooltip(
          waitDuration: Duration(seconds: 0),
          message: "Waiting for voltage data...",
          child: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(
              Icons.battery_unknown,
              color: Colors.white,
            ),
          ));
    }

    if (voltageAlert == true) {
      return Tooltip(
          waitDuration: Duration(seconds: 0),
          message: "Voltage is below 3.20 V",
          child: CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.battery_alert, color: Colors.white),
          ));
    }
    return CircleAvatar(
      backgroundColor: Colors.indigo,
      child: Icon(Icons.battery_full),
    );
  }
}
