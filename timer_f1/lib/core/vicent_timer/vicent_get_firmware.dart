String? getVicentFirmwareVersion(String line) {
  var lines = line.split('Ver ');
  if (lines.length > 1) {
    return lines[1];
  }

  return null;
}
