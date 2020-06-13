import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong/latlong.dart';

final Widget plainIcon = SvgPicture.asset(
  'assets/icons/plain_start.svg',
  semanticsLabel: 'plain',
  width: 50,
  height: 50,
);

Marker buildPlainStartingPointMarker(LatLng planeCoordinates) {
  return new Marker(
    point: planeCoordinates,
    width: 55.0,
    height: 55.0,
    anchorPos: AnchorPos.align(AnchorAlign.top),
    builder: (BuildContext context) => plainIcon,
  );
}
