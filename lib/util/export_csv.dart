import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:share_extend/share_extend.dart';
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

Future<String> generateCsv(FlightHistory flightHistory) async {
  List<List<dynamic>> rows = List<dynamic>();
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
    Map<dynamic, dynamic> flightData = flightHistory.flightData[i].toRAW();
    row.add(flightData['planeId']);
    row.add(flightData['timestamp']);
    row.add(flightData['planeLat']);
    row.add(flightData['planeLng']);
    row.add(flightData['height']);
    row.add(flightData['temperature']);
    row.add(flightData['pressure']);
    row.add(flightData['voltage']);
    rows.add(row);
  }

  String fileName = 'timmer_' +
      flightHistory.planeId +
      '_' +
      flightHistory.endTimestamp.toString();
  File f = await getFile(fileName);

  String csv = const ListToCsvConverter().convert(rows);
  f.writeAsString(csv);

  return f.path;
}

Future<void> exportFlight2Csv(FlightHistory flightHistory) async {
  String filePath = await generateCsv(flightHistory);
  final params = SaveFileDialogParams(sourceFilePath: filePath);
  await FlutterFileDialog.saveFile(params: params);
}

Future<void> shareFligth(FlightHistory flightHistory) async {
  String filePath = await generateCsv(flightHistory);
  await ShareExtend.share(filePath, "Timmer flight");
}
