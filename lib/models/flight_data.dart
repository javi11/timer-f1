import 'dart:math';
import 'package:latlong/latlong.dart';
import 'package:timmer/util/distance_calculator.dart';

num toLatLng = pow(10, -7);
num toVolts = pow(10, -2);

double parseLatLng(String timmerLatLng) {
  return double.parse(timmerLatLng) * toLatLng;
}

double parseHeight(String timmerHeight) {
  return double.parse(timmerHeight) / 1000;
}

double parseVoltage(String voltage) {
  int vInt = int.tryParse(voltage);
  if (vInt == null) {
    double vDouble = double.tryParse(voltage);
    return vDouble * toVolts;
  }
  return vInt * toVolts;
}

class FlightData {
  int id;
  int flightHistoryId;
  String planeId = '';
  int timestamp = 0;
  LatLng planeCoordinates;
  double height = 0;
  double temperature = 0;
  double pressure = 0;
  double voltage = 0;
  bool voltageAlert = false;
  List<LatLng> route = [LatLng(0, 0), LatLng(0, 0)];
  LatLng userCoordinates = LatLng(0, 0);
  double planeDistanceFromUser;

  static final columns = [
    'id',
    'flightHistoryId',
    'planeId',
    'timestamp',
    'planeLat',
    'planeLng',
    'height',
    'temperature',
    'pressure',
    'voltage',
    'userLng',
    'userLat',
    'planeDistanceFromUser'
  ];

  FlightData();

  parseTimmerData(List<String> line) {
    if (line.length > 0) {
      this.planeId = line[0];
      this.timestamp = new DateTime(
              int.parse(line[3]),
              int.parse(line[4]),
              int.parse(line[5]),
              int.parse(line[6]),
              int.parse(line[7]),
              int.parse(line[8]))
          .millisecondsSinceEpoch;

      this.planeCoordinates =
          LatLng(parseLatLng(line[9]), parseLatLng(line[10]));

      if (this.planeCoordinates.latitude == 0 &&
          this.planeCoordinates.longitude == 0) {
        this.planeCoordinates = null;
      }

      if (this.planeCoordinates == null) {
        this.planeDistanceFromUser = null;
        this.route = null;
      } else {
        this.route = <LatLng>[this.planeCoordinates, this.userCoordinates];
        this.planeDistanceFromUser =
            calculateDistance(this.planeCoordinates, this.userCoordinates);
      }
      // Convert height from mm to meters.
      this.height = parseHeight(line[11]);
      this.temperature = double.parse(line[12]);
      this.pressure = double.parse(line[13]);
      this.voltage = parseVoltage(line[14]);
      this.voltageAlert = this.voltage < 3.20;
    }
  }

  addUserCoordinates(LatLng userCoordinates) {
    this.userCoordinates = userCoordinates;
    if (this.planeCoordinates == null) {
      this.planeDistanceFromUser = null;
      this.route = null;
    } else {
      this.planeDistanceFromUser =
          calculateDistance(this.planeCoordinates, this.userCoordinates);
    }
  }

  Map<String, dynamic> toRAW() {
    String planeLan = planeCoordinates?.latitude != null
        ? (planeCoordinates.latitude / toLatLng).toString()
        : null;
    String planeLng = planeCoordinates?.longitude != null
        ? (planeCoordinates.longitude / toLatLng).toString()
        : null;
    String userLan = userCoordinates?.latitude != null
        ? (userCoordinates.latitude / toLatLng).toString()
        : null;
    String userLng = userCoordinates?.longitude != null
        ? (userCoordinates.longitude / toLatLng).toString()
        : null;

    Map<String, dynamic> map = {
      'id': id,
      'flightHistoryId': flightHistoryId,
      'planeId': planeId,
      'timestamp': timestamp,
      'planeLat': planeLan,
      'planeLng': planeLng,
      'height': (height * 1000).toString(),
      'temperature': temperature,
      'pressure': pressure,
      'voltage': (voltage / toVolts).toString(),
      'userLng': userLan,
      'userLat': userLng,
      'planeDistanceFromUser': planeDistanceFromUser
    };
    return map;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'flightHistoryId': flightHistoryId,
      'planeId': planeId,
      'timestamp': timestamp,
      'height': height,
      'temperature': temperature,
      'pressure': pressure,
      'voltage': voltage,
      'planeDistanceFromUser': planeDistanceFromUser
    };

    if (planeCoordinates != null) {
      map['planeLat'] = planeCoordinates.latitude.toString();
      map['planeLng'] = planeCoordinates.longitude.toString();
    }

    if (userCoordinates != null) {
      map['userLng'] = userCoordinates.latitude.toString();
      map['userLat'] = userCoordinates.longitude.toString();
    }

    return map;
  }

  FlightData.fromMap(Map map) {
    id = map['id'];
    flightHistoryId = map['flightHistoryId'];
    planeId = map['planeId'];
    timestamp = map['timestamp'];
    if (map['planeLat'] != null && map['planeLng'] != null) {
      planeCoordinates =
          LatLng(double.parse(map['planeLat']), double.parse(map['planeLng']));
    }
    height = map['height'];
    temperature = map['temperature'];
    pressure = map['pressure'];
    voltage = map['voltage'];
    if (map['userLat'] != null && map['userLng'] != null) {
      userCoordinates =
          LatLng(double.parse(map['userLat']), double.parse(map['userLng']));
    }
    planeDistanceFromUser = map['planeDistanceFromUser'];
  }
}
