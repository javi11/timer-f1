import 'dart:collection';
import 'package:latlong/latlong.dart';
import 'package:timmer/models/flight_data.dart';
import 'package:timmer/util/distance_calculator.dart';

class FlightHistory {
  int id;
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
  LatLng farPlaneDistanceCoordinates;
  LatLng flightStartCoordinates;
  LatLng flightEndCoordinates;

  UnmodifiableListView<FlightData> get flightData =>
      UnmodifiableListView(_data);

  static final columns = [
    'id',
    'durationInMs',
    'startTimestamp',
    'endTimestamp',
    'planeId',
    'maxPressure',
    'maxHeight',
    'maxTemperature',
    'farPlaneDistanceLat',
    'farPlaneDistanceLng',
    'maxPlaneDistanceFromStart',
    'startFlightLat',
    'startFlightLng',
    'endFlightLat',
    'endFlightLng'
  ];

  void addAll(Iterable<FlightData> iterable) {
    this._data.addAll(iterable);
  }

  void addData(FlightData timmerData) {
    // There is no point on add the history if there is no plain coordinates to show
    if (timmerData.planeCoordinates != null) {
      if (this.flightStartCoordinates == null &&
          timmerData.planeCoordinates != null) {
        this.flightStartCoordinates = timmerData.planeCoordinates;
      }
      this.planeId = timmerData.planeId;
      this._data.add(FlightData.fromMap(timmerData.toMap()));
    }
  }

  void start() {
    this.startTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  int end() {
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
      if (element.planeDistanceFromUser != null &&
          element.planeDistanceFromUser > this.maxDistanceFromUser) {
        this.maxDistanceFromUser = element.planeDistanceFromUser;
      }
      if (this.farPlaneDistanceCoordinates == null &&
          element.planeCoordinates != null) {
        this.farPlaneDistanceCoordinates = element.planeCoordinates;
      }
      if (element.planeCoordinates != null) {
        double distanceFromStart = calculateDistance(
            element.planeCoordinates, this.flightStartCoordinates);
        if (distanceFromStart > this.maxPlaneDistanceFromStart) {
          this.maxPlaneDistanceFromStart = distanceFromStart;
          this.farPlaneDistanceCoordinates = element.planeCoordinates;
        }
      }
    });
    this.flightEndCoordinates = this
        ._data
        .lastWhere((element) => element.planeCoordinates != null,
            orElse: () => null)
        ?.planeCoordinates;

    return this.durationInMs;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'durationInMs': durationInMs,
      'startTimestamp': startTimestamp,
      'endTimestamp': endTimestamp,
      'planeId': planeId,
      'maxPressure': maxPressure,
      'maxHeight': maxHeight,
      'maxTemperature': maxTemperature,
      'maxPlaneDistanceFromStart': maxPlaneDistanceFromStart,
    };

    if (farPlaneDistanceCoordinates != null) {
      map['farPlaneDistanceLat'] =
          farPlaneDistanceCoordinates.latitude.toString();
      map['farPlaneDistanceLng'] =
          farPlaneDistanceCoordinates.longitude.toString();
    }

    if (flightStartCoordinates != null) {
      map['startFlightLat'] = flightStartCoordinates.latitude.toString();
      map['startFlightLng'] = flightStartCoordinates.longitude.toString();
    }

    if (flightStartCoordinates != null) {
      map['endFlightLat'] = flightEndCoordinates.latitude.toString();
      map['endFlightLng'] = flightEndCoordinates.longitude.toString();
    }

    return map;
  }

  FlightHistory();

  FlightHistory.fromMap(Map map) {
    id = map['id'];
    durationInMs = map['durationInMs'];
    startTimestamp = map['startTimestamp'];
    endTimestamp = map['endTimestamp'];
    planeId = map['planeId'];
    maxPressure = map['maxPressure'];
    maxHeight = map['maxHeight'];
    maxTemperature = map['maxTemperature'];
    if (map['farPlaneDistanceLat'] != null &&
        map['farPlaneDistanceLng'] != null) {
      farPlaneDistanceCoordinates = LatLng(
          double.parse(map['farPlaneDistanceLat']),
          double.parse(map['farPlaneDistanceLng']));
    }
    if (map['startFlightLat'] != null && map['startFlightLng'] != null) {
      flightStartCoordinates = LatLng(double.parse(map['startFlightLat']),
          double.parse(map['startFlightLng']));
    }
    if (map['endFlightLat'] != null && map['endFlightLng'] != null) {
      flightEndCoordinates = LatLng(
          double.parse(map['endFlightLat']), double.parse(map['endFlightLng']));
    }

    maxPlaneDistanceFromStart = map['maxPlaneDistanceFromStart'];
  }
}
