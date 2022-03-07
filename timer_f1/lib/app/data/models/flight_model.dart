import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:timer_f1/core/utils/distance_calculator.dart';

@Entity()
class Flight {
  int id = 0;
  int? startTimestamp;
  int? durationInMs;
  int? endTimestamp;
  String? planeId;
  double? maxPressure;
  double? maxHeight;
  double? maxTemperature;
  double? farPlaneDistanceLat;
  double? farPlaneDistanceLng;
  double? startFlightLng;
  double? startFlightLat;
  double? endFlightLng;
  double? endFlightLat;
  double? maxPlaneDistanceFromStart;
  double? maxPlaneDistanceFromUser;

  @Backlink('flight')
  final flightData = ToMany<FlightData>();

  LatLng? get farPlaneDistanceCoordinates {
    return farPlaneDistanceLat != null && farPlaneDistanceLng != null
        ? LatLng(farPlaneDistanceLat!, farPlaneDistanceLng!)
        : null;
  }

  LatLng? get flightStartCoordinates {
    return startFlightLat != null && startFlightLng != null
        ? LatLng(startFlightLat!, startFlightLng!)
        : null;
  }

  set flightStartCoordinates(LatLng? cords) {
    startFlightLat = cords?.latitude;
    startFlightLng = cords?.longitude;
  }

  LatLng? get flightEndCoordinates {
    return endFlightLat != null && endFlightLng != null
        ? LatLng(endFlightLat!, endFlightLng!)
        : null;
  }

  set flightEndCoordinates(LatLng? cords) {
    endFlightLat = cords?.latitude;
    endFlightLng = cords?.longitude;
  }

  Flight(
      {this.id = 0,
      this.durationInMs,
      this.startTimestamp,
      this.endTimestamp,
      this.planeId,
      this.maxPressure,
      this.maxHeight,
      this.maxTemperature,
      this.farPlaneDistanceLat,
      this.farPlaneDistanceLng,
      this.startFlightLng,
      this.startFlightLat,
      this.endFlightLng,
      this.endFlightLat,
      this.maxPlaneDistanceFromStart,
      this.maxPlaneDistanceFromUser});

  void addAll(Iterable<FlightData> iterable) {
    for (var element in iterable) {
      addData(element);
    }
  }

  void addData(FlightData data) {
    // There is no point on add the history if there is no plain coordinates to show
    if (data.planeCoordinates != null) {
      if (flightStartCoordinates == null && data.planeCoordinates != null) {
        flightStartCoordinates = data.planeCoordinates;
      }
      planeId ??= data.planeId;
      flightData.add(data);
    }
  }

  get elapsedTime {
    return startTimestamp != null
        ? DateTime.now().millisecondsSinceEpoch - startTimestamp!
        : 0;
  }

  void start() {
    startTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  int? finish() {
    durationInMs = elapsedTime;
    for (var element in flightData) {
      if (element.height! > maxHeight!) {
        maxHeight = element.height;
      }
      if (element.pressure! > maxPressure!) {
        maxPressure = element.pressure;
      }
      if (element.temperature! > maxTemperature!) {
        maxTemperature = element.temperature;
      }
      if (element.planeDistanceFromUser != null &&
          element.planeDistanceFromUser! > maxPlaneDistanceFromUser!) {
        maxPlaneDistanceFromUser = element.planeDistanceFromUser;
      }
      if (maxPlaneDistanceFromStart == null &&
          element.planeCoordinates != null) {
        farPlaneDistanceLat = element.planeCoordinates!.latitude;
        farPlaneDistanceLng = element.planeCoordinates!.longitude;
      }
      if (element.planeCoordinates != null) {
        double distanceFromStart = calculateDistance(
            element.planeCoordinates, flightStartCoordinates)!;
        if (distanceFromStart > maxPlaneDistanceFromStart!) {
          maxPlaneDistanceFromStart = distanceFromStart;
          farPlaneDistanceLat = element.planeCoordinates!.latitude;
          farPlaneDistanceLng = element.planeCoordinates!.longitude;
        }
      }
    }
    var lastPlainCoordinates = flightData
        .lastWhere((element) => element.planeCoordinates != null)
        .planeCoordinates;

    if (lastPlainCoordinates != null) {
      flightEndCoordinates = lastPlainCoordinates;
    }

    return durationInMs;
  }

  Flight.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    durationInMs = json['durationInMs'];
    startTimestamp = json['startTimestamp'];
    endTimestamp = json['endTimestamp'];
    planeId = json['planeId'];
    maxPressure = json['maxPressure'];
    maxHeight = json['maxHeight'];
    maxTemperature = json['maxTemperature'];
    farPlaneDistanceLat = json['farPlaneDistanceLat'];
    farPlaneDistanceLng = json['farPlaneDistanceLng'];
    startFlightLng = json['startFlightLng'];
    startFlightLat = json['startFlightLat'];
    endFlightLng = json['endFlightLng'];
    endFlightLat = json['endFlightLat'];
    maxPlaneDistanceFromStart = json['maxPlaneDistanceFromStart'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['durationInMs'] = durationInMs;
    data['startTimestamp'] = startTimestamp;
    data['endTimestamp'] = endTimestamp;
    data['planeId'] = planeId;
    data['maxPressure'] = maxPressure;
    data['maxHeight'] = maxHeight;
    data['maxTemperature'] = maxTemperature;
    data['farPlaneDistanceLat'] = farPlaneDistanceLat;
    data['farPlaneDistanceLng'] = farPlaneDistanceLng;
    data['startFlightLng'] = startFlightLng;
    data['startFlightLat'] = startFlightLat;
    data['endFlightLng'] = endFlightLng;
    data['endFlightLat'] = endFlightLat;
    data['maxPlaneDistanceFromStart'] = maxPlaneDistanceFromStart;
    return data;
  }
}
