import 'dart:math';
import 'package:latlong/latlong.dart';
import 'package:timmer/util/distance_calculator.dart';

num toLatLng = pow(10, -7);
num toVolts = pow(10, -2);

class FlightData {
  String id = '';
  int timestamp = 0;
  LatLng planeCoordinates = LatLng(0, 0);
  double height = 0;
  double temperature = 0;
  double pressure = 0;
  double voltage = 0;
  bool voltageAlert = false;
  List<LatLng> route = [LatLng(0, 0), LatLng(0, 0)];
  LatLng userCoordinates = LatLng(0, 0);
  double planeDistanceFromUser = 0;

  parseTimmerData(String data) {
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

      this.planeCoordinates = LatLng(
          double.parse(line[7]) * toLatLng, double.parse(line[8]) * toLatLng);
      this.route = <LatLng>[this.planeCoordinates, this.userCoordinates];
      this.planeDistanceFromUser =
          calculateDistance(this.planeCoordinates, this.userCoordinates);
      // Convert height from mm to meters.
      this.height = double.parse(line[9]) / 1000;
      this.temperature = double.parse(line[10]);
      this.pressure = double.parse(line[11]);
      this.voltage = double.parse(line[12]) * toVolts;
      this.voltageAlert = this.voltage < 3.20;
    }
  }

  addUserCoordinates(LatLng userCoordinates) {
    this.userCoordinates = userCoordinates;
    this.route = <LatLng>[this.planeCoordinates, this.userCoordinates];
    this.planeDistanceFromUser =
        calculateDistance(this.planeCoordinates, this.userCoordinates);
  }

  Map toMap() {
    Map map = {
      'planeId': id,
      'timestamp': timestamp,
      'planeLatitude': planeCoordinates.latitude,
      'planeLongitude': planeCoordinates.longitude,
      'height': height,
      'temperature': temperature,
      'pressure': pressure,
      'voltage': voltage,
      'userLongitude': userCoordinates.longitude,
      'userLatitude': userCoordinates.latitude,
      'planeDistanceFromUser': planeDistanceFromUser
    };
    return map;
  }

  FlightData();

  FlightData.fromMap(Map map) {
    id = map['planeId'];
    timestamp = map['timestamp'];
    planeCoordinates = LatLng(map['planeLatitude'], map['planeLongitude']);
    height = map['height'];
    temperature = map['temperature'];
    pressure = map['pressure'];
    voltage = map['voltage'];
    userCoordinates = LatLng(map['userLatitude'], map['userLongitude']);
    planeDistanceFromUser = map['planeDistanceFromUser'];
  }
}
