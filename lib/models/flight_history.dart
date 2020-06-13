import 'dart:collection';
import 'package:latlong/latlong.dart';
import 'package:timmer/models/flight_data.dart';
import 'package:timmer/util/distance_calculator.dart';

class FlightHistory {
  List<FlightData> _data = [];
  int durationInMs = 0;
  int startTimestamp = 0;
  int endTimestamp = 0;
  String planeId = 'uknown';
  double maxPressure = 0;
  double maxHeight = 0;
  double maxTemperature = 0;
  double maxDistanceFromUser = 0;
  double maxPlaneDistanceFromStart = 0;
  LatLng farCoordinates;

  UnmodifiableListView<FlightData> get flightData =>
      UnmodifiableListView(_data);

  void addData(FlightData timmerData) {
    this.planeId = timmerData.id;
    this._data.add(FlightData.fromMap(timmerData.toMap()));
  }

  void start() {
    this.startTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  void end() {
    this.endTimestamp = DateTime.now().millisecondsSinceEpoch;
    this.durationInMs = this.endTimestamp - this.startTimestamp;
    this._data.forEach((element) {
      if (element.height > this.maxHeight) {
        this.maxHeight = element.height;
      }
      if (element.pressure > this.maxPressure) {
        this.maxPressure = element.pressure;
      }
      if (element.temperature > this.maxTemperature) {
        this.maxTemperature = element.temperature;
      }
      if (element.planeDistanceFromUser > this.maxDistanceFromUser) {
        this.maxDistanceFromUser = element.planeDistanceFromUser;
      }
      if (this.farCoordinates == null) {
        this.farCoordinates = element.planeCoordinates;
      }
      double distanceFromStart =
          calculateDistance(element.planeCoordinates, this.farCoordinates);
      if (distanceFromStart > this.maxPlaneDistanceFromStart) {
        this.maxPlaneDistanceFromStart = distanceFromStart;
        this.farCoordinates = element.planeCoordinates;
      }
    });
  }

  Map toMap() {
    Map map = {
      'durationInMs': durationInMs,
      'startTimestamp': startTimestamp,
      'endTimestamp': endTimestamp,
      'planeId': planeId,
      'maxPressure': maxPressure,
      'maxHeight': maxHeight,
      'maxTemperature': maxTemperature,
      'farCoordinates': farCoordinates,
      'maxPlaneDistanceFromStart': maxPlaneDistanceFromStart,
    };
    return map;
  }

  FlightHistory();

  FlightHistory.fromMap(Map map) {
    durationInMs = map['durationInMs'];
    startTimestamp = map['startTimestamp'];
    endTimestamp = map['endTimestamp'];
    planeId = map['planeId'];
    maxPressure = map['maxPressure'];
    maxHeight = map['maxHeight'];
    maxTemperature = map['maxTemperature'];
    farCoordinates = map['farCoordinates'];
    maxPlaneDistanceFromStart = map['maxPlaneDistanceFromStart'];
  }
}
