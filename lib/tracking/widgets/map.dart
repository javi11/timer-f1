import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:timerf1c/models/flight_data.dart';
import 'package:timerf1c/tracking/widgets/plain_marker.dart';
import 'package:timerf1c/providers/map_provider.dart';

Widget buildMap(LocationMarkerPlugin locationMarkerPlugin, List<Marker> markers,
    FlightData flightData, MapController mapController) {
  List<Polygon> polylines = [];

  if (flightData.route != null) {
    polylines.add(Polygon(
        points: flightData.route as List<LatLng>,
        borderStrokeWidth: 4.0,
        color: Colors.blue));
  }

  return FlutterMap(
    options: MapOptions(
        interactiveFlags: InteractiveFlag.all,
        center: LatLng(0, 0),
        zoom: 15.0),
    children: [
      mapProvider,
      MarkerLayerWidget(
          options: MarkerLayerOptions(
        markers: markers,
      )),
      MarkerLayerWidget(
          options: MarkerLayerOptions(
        markers: [buildPlainMarker(flightData.planeCoordinates)],
      )),
      PolygonLayerWidget(
          options: PolygonLayerOptions(
        polygons: polylines,
      )),
      LocationMarkerLayerWidget(
        plugin: locationMarkerPlugin,
        options: LocationMarkerLayerOptions(
            showAccuracyCircle: true, showHeadingSector: true),
      ),
    ],
    // ADD THIS
    mapController: mapController,
  );
}
