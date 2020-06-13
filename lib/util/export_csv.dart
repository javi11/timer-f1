import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timmer/models/flight_history.dart';

String filePath;

Future<String> get _localPath async {
  final directory = await getApplicationSupportDirectory();
  return directory.absolute.path;
}

Future<File> getFile(String name) async {
  final path = await _localPath;
  filePath = '$path/$name.csv';
  return File('$path/$name.csv').create();
}

Future<void> exportFlight2Csv(FlightHistory flightHistory) async {
  List<List<dynamic>> rows = List<List<dynamic>>();
  rows.add([
    "id",
    "timestamp",
    "plain latitude",
    "plain longitude",
    "height",
    "temperature",
    "pressure",
    "voltage"
  ]);

  for (int i = 0; i < flightHistory.flightData.length; i++) {
    List<dynamic> row = List<dynamic>();
    row.add(flightHistory.flightData[i].id);
    row.add(flightHistory.flightData[i].timestamp);
    row.add(flightHistory.flightData[i].planeCoordinates.latitude);
    row.add(flightHistory.flightData[i].planeCoordinates.longitude);
    row.add(flightHistory.flightData[i].height);
    row.add(flightHistory.flightData[i].temperature);
    row.add(flightHistory.flightData[i].pressure);
    row.add(flightHistory.flightData[i].voltage);
    rows.add(row);
  }

  String fileName =
      flightHistory.planeId + flightHistory.endTimestamp.toString();
  File f = await getFile(fileName);

  String csv = const ListToCsvConverter().convert(rows);
  f.writeAsString(csv);
}
