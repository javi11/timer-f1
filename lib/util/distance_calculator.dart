import 'package:latlong/latlong.dart';

double calculateDistance(LatLng point1, LatLng point2) {
  final Distance distance = Distance();
  return distance(point1, point2);
}
