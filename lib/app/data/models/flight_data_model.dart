import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/core/utils/distance_calculator.dart';

num toLatLng = pow(10, -7);
num toVolts = pow(10, -2);

double parseLatLng(String rawLatLng) {
  return double.parse(rawLatLng) * toLatLng;
}

double parseHeight(String rawLatLng) {
  return double.parse(rawLatLng) / 1000;
}

double parseVoltage(String voltage) {
  int? vInt = int.tryParse(voltage);
  if (vInt == null) {
    double vDouble = double.tryParse(voltage)!;
    return vDouble * toVolts;
  }
  return vInt * (toVolts as double);
}

bool isNullVoltage(double? voltage) {
  return voltage == 0 || voltage == 0.0 || voltage == 0.00;
}

@Entity()
class FlightData {
  int id = 0;
  bool isConnectedToPlane = false;
  int? flightHistoryId;
  String? planeId;
  int? timestamp;
  double? planeLat;
  double? planeLng;
  double? height;
  double? temperature;
  double? pressure;
  double? voltage;
  double? userLng;
  double? userLat;
  bool? isInitial;

  final flight = ToOne<Flight>();

  FlightData(
      {this.id = 0,
      this.isConnectedToPlane = false,
      this.flightHistoryId,
      this.planeId,
      this.timestamp,
      this.planeLat,
      this.planeLng,
      this.height,
      this.temperature,
      this.pressure,
      this.voltage,
      this.userLng,
      this.userLat,
      this.isInitial});

  LatLng? get planeCoordinates {
    return planeLat != null && planeLng != null
        ? LatLng(planeLat!, planeLng!)
        : null;
  }

  LatLng? get userCoordinates {
    return userLat != null && userLng != null
        ? LatLng(userLat!, userLng!)
        : null;
  }

  bool get voltageAlert {
    return voltage != null && voltage! < 3.20;
  }

  double? get planeDistanceFromUser {
    return planeCoordinates != null
        ? calculateDistance(planeCoordinates, userCoordinates)
        : null;
  }

  List<LatLng>? get route {
    return planeCoordinates != null && userCoordinates != null
        ? [planeCoordinates!, userCoordinates!]
        : null;
  }

  Map<String, dynamic> toRaw() {
    String? planeLan = planeCoordinates?.latitude != null
        ? (planeCoordinates!.latitude / toLatLng).toString()
        : null;
    String? planeLng = planeCoordinates?.longitude != null
        ? (planeCoordinates!.longitude / toLatLng).toString()
        : null;
    String? userLan = userCoordinates?.latitude != null
        ? (userCoordinates!.latitude / toLatLng).toString()
        : null;
    String? userLng = userCoordinates?.longitude != null
        ? (userCoordinates!.longitude / toLatLng).toString()
        : null;

    Map<String, dynamic> map = {
      'id': id,
      'flightHistoryId': flightHistoryId,
      'planeId': planeId,
      'timestamp': timestamp,
      'planeLat': planeLan,
      'planeLng': planeLng,
      'height': (height! * 1000).toString(),
      'temperature': temperature,
      'pressure': pressure,
      'voltage': (voltage! / toVolts).toString(),
      'userLng': userLan,
      'userLat': userLng,
      'isInitial': isInitial
    };
    return map;
  }

  FlightData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    flightHistoryId = json['flightHistoryId'];
    planeId = json['planeId'];
    timestamp = json['timestamp'];
    planeLat = json['planeLat'];
    planeLng = json['planeLng'];
    height = json['height'];
    temperature = json['temperature'];
    pressure = json['pressure'];
    voltage = json['voltage'];
    userLng = json['userLng'];
    userLat = json['userLat'];
    isInitial = json['isInitial'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['flightHistoryId'] = flightHistoryId;
    data['planeId'] = planeId;
    data['timestamp'] = timestamp;
    data['planeLat'] = planeLat;
    data['planeLng'] = planeLng;
    data['height'] = height;
    data['temperature'] = temperature;
    data['pressure'] = pressure;
    data['voltage'] = voltage;
    data['userLng'] = userLng;
    data['userLat'] = userLat;
    data['isInitial'] = isInitial;
    return data;
  }

  static FlightData parse(List<String> line) {
    FlightData flightData = FlightData();
    flightData.planeId = line[0];
    flightData.timestamp = DateTime(
            int.parse(line[3]),
            int.parse(line[4]),
            int.parse(line[5]),
            int.parse(line[6]),
            int.parse(line[7]),
            int.parse(line[8]))
        .millisecondsSinceEpoch;

    flightData.planeLat = parseLatLng(line[9]);
    flightData.planeLng = parseLatLng(line[10]);

    // Convert height from mm to meters.
    flightData.height = parseHeight(line[11]);
    flightData.temperature = double.parse(line[12]);
    flightData.pressure = double.parse(line[13]);
    flightData.voltage = parseVoltage(line[14]);
    // if the voltage has 0 values, the timer receiver is not connected to the plain.
    flightData.isConnectedToPlane = !isNullVoltage(flightData.voltage);

    return flightData;
  }
}
