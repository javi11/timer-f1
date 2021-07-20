import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Marker buildMarker(LatLng coordinates, AnchorAlign anchor, IconData icon) {
  return new Marker(
    point: coordinates,
    width: 55.0,
    height: 55.0,
    anchorPos: AnchorPos.align(anchor),
    builder: (BuildContext context) => Icon(
      icon,
      size: 60.0,
      color: Colors.red,
    ),
  );
}
