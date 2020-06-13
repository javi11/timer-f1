import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:timmer/models/flight_data.dart';
import 'package:timmer/tracking/widgets/plain_marker.dart';
import 'package:user_location/user_location.dart';

Widget buildMap(List<Marker> markers, FlightData flightData,
    UserLocationOptions userLocationOptions, MapController mapController) {
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
      TileLayerOptions(
        urlTemplate: "https://api.tiles.mapbox.com/v4/"
            "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
        additionalOptions: {
          'accessToken':
              'pk.eyJ1IjoibGFyaXMxMiIsImEiOiJjazgzNHBtajcxNWRyM2twZ3NyeTFndDZuIn0.8-PMlKszRh8ixNyP3u2jrA',
          'id': 'mapbox.streets',
        },
      ),
      MarkerLayerOptions(markers: markers),
      MarkerLayerOptions(
          markers: [buildPlainMarker(flightData.planeCoordinates)]),
      PolylineLayerOptions(
        polylines: [
          Polyline(
              points: flightData.route, strokeWidth: 4.0, color: Colors.blue),
        ],
      ),
      userLocationOptions,
    ],
    // ADD THIS
    mapController: mapController,
  );
}
