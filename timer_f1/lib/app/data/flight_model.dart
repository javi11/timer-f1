import 'dart:collection';
import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/flight_data_model.dart';
import 'package:latlong2/latlong.dart';

@Entity()
class Flight {
  int id = 0;
  int? durationInMs;
  int? startTimestamp;
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
    flightStartCoordinates = cords;
  }

  LatLng? get flightEndCoordinates {
    return endFlightLat != null && endFlightLng != null
        ? LatLng(endFlightLat!, endFlightLng!)
        : null;
  }

  Flight(
      {required this.id,
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
      this.maxPlaneDistanceFromStart});

  void addAll(Iterable<FlightData> iterable) {
    flightData.addAll(iterable);
  }

  void addData(FlightData data) {
    // There is no point on add the history if there is no plain coordinates to show
    if (data.planeCoordinates != null) {
      if (flightStartCoordinates == null && data.planeCoordinates != null) {
        flightStartCoordinates = data.planeCoordinates;
      }
      planeId = data.planeId;
      flightData.add(data);
    }
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
