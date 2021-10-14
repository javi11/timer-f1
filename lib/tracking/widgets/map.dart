import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:timerf1c/models/flight_data.dart';
import 'package:timerf1c/tracking/widgets/plain_marker.dart';

Widget buildMap(
    LocationMarkerPlugin locationMarkerPlugin,
    List<Marker> markers,
    FlightData flightData,
    MapController mapController,
    TileProvider? mapProvider) {
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
          options: mapProvider != null
              ? TileLayerOptions(
                  tileProvider: mapProvider,
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'])
              : TileLayerOptions(
                  tileProvider: StorageCachingTileProvider(),
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
        plugin: locationMarkerPlugin,
        options: LocationMarkerLayerOptions(
            showAccuracyCircle: true, showHeadingSector: true),
      ),
    ],
    // ADD THIS
    mapController: mapController,
  );
}
