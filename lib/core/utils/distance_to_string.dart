String distanceToString(double distance) {
  if (distance > 10000) {
    return (distance / 1000).toStringAsFixed(2).substring(0, 3) + '... Km';
  }
  return distance > 1000
      ? (distance / 1000).toStringAsFixed(2) + ' Km'
      : distance.toStringAsFixed(2) + ' m';
}
