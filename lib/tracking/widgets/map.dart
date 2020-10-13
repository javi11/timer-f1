import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:timmer/models/flight_data.dart';
import 'package:timmer/tracking/widgets/plain_marker.dart';
import 'package:timmer/widgets/map_provider.dart';
import 'package:user_location/user_location.dart';

Widget buildMap(List<Marker> markers, FlightData flightData,
    UserLocationOptions userLocationOptions, MapController mapController) {
  List<Polyline> polylines = [];

  if (flightData.route != null) {
    polylines.add(Polyline(
        points: flightData.route, strokeWidth: 4.0, color: Colors.blue));
  }

  return FlutterMap(
    options: MapOptions(
      interactive: true,
      center: LatLng(0, 0),
      zoom: 15.0,
      plugins: [
        UserLocationPlugin(),
      ],
    ),
    layers: [
      mapProvider,
      MarkerLayerOptions(markers: markers),
      MarkerLayerOptions(
          markers: [buildPlainMarker(flightData.planeCoordinates)]),
      PolylineLayerOptions(
        polylines: polylines,
      ),
      userLocationOptions,
    ],
    // ADD THIS
    mapController: mapController,
  );
}
