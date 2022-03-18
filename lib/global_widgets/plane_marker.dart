import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';

final Widget planeIcon = SvgPicture.asset(
  'assets/icons/plain_marker.svg',
  semanticsLabel: 'plain',
  width: 50,
  height: 50,
);

Marker buildPlaneMarker(LatLng planeCoordinates) {
  return Marker(
    point: planeCoordinates,
    width: 55.0,
    height: 55.0,
    anchorPos: AnchorPos.align(AnchorAlign.top),
    builder: (BuildContext context) => planeIcon,
  );
}
