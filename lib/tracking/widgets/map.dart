import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:timerf1c/models/flight_data.dart';
import 'package:timerf1c/providers/map_provider.dart';
import 'package:timerf1c/tracking/widgets/plain_marker.dart';

Widget buildMap(LocationMarkerLayer locationMarkerLayer, List<Marker> markers,
    FlightData flightData, MapController mapController) {
  List<Polygon> polylines = [];

  if (flightData.route != null) {
    polylines.add(Polygon(
        points: flightData.route!, borderStrokeWidth: 4.0, color: Colors.blue));
  }

  return FlutterMap(
    options: MapOptions(
        interactiveFlags: InteractiveFlag.all,
        center: LatLng(0, 0),
        zoom: 15.0),
    children: [
      TileLayerWidget(
          options: TileLayerOptions(
              tileProvider: tileProvider,
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'])),
      MarkerLayerWidget(
          options: MarkerLayerOptions(
        markers: markers,
      )),
      MarkerLayerWidget(
          options: MarkerLayerOptions(
        markers: flightData.planeCoordinates != null
            ? [buildPlainMarker(flightData.planeCoordinates)]
            : [],
      )),
      PolygonLayerWidget(
          options: PolygonLayerOptions(
        polygons: polylines,
      )),
      LocationMarkerLayerWidget(
        options: LocationMarkerLayerOptions(
            showAccuracyCircle: true, showHeadingSector: true),
      ),
    ],
    // ADD THIS
    mapController: mapController,
  );
}
