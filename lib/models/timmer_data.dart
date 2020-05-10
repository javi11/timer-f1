import 'dart:math';
import 'package:latlong/latlong.dart';

num toLatLng = pow(10, -7);
num toVolts = pow(10, -2);

class TimmerData {
  String id = '';
  int timestamp = 0;
  LatLng planePosition = LatLng(0, 0);
  double height = 0;
  double temperature = 0;
  double pressure = 0;
  double voltage = 0;
  bool voltageAlert = false;

  TimmerData(String data) {
    if (data.length > 0) {
      List<String> line = data.split(',');

      this.id = line[0];
      this.timestamp = new DateTime(
              int.parse(line[1]),
              int.parse(line[2]),
              int.parse(line[3]),
              int.parse(line[4]),
              int.parse(line[5]),
              int.parse(line[6]))
          .millisecondsSinceEpoch;

      this.planePosition = LatLng(
          double.parse(line[7]) * toLatLng, double.parse(line[8]) * toLatLng);
      // Convert height from mm to meters.
      this.height = double.parse(line[9]) / 1000;
      this.temperature = double.parse(line[10]);
      this.pressure = double.parse(line[11]);
      this.voltage = double.parse(line[12]) * toVolts;
      this.voltageAlert = this.voltage < 3.20;
    }
  }
}
