import 'package:latlong2/latlong.dart';

double? calculateDistance(LatLng? point1, LatLng? point2) {
  final Distance distance = Distance();
  if (point1 == null || point2 == null) {
    return null;
  }
  return distance(point1, point2);
}
