String distanceToString(double distance) {
  return distance > 1000
      ? (distance / 1000).toStringAsFixed(2) + ' Km'
      : distance.toStringAsFixed(2) + ' m';
}
