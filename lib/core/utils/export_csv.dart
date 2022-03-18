import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:share_extend/share_extend.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';

String? filePath;

Future<String> get _localPath async {
  final directory = await getApplicationSupportDirectory();
  return directory.absolute.path;
}

Future<File> getFile(String name) async {
  final path = await _localPath;
  filePath = '$path/$name.csv';
  return File('$path/$name.csv').create();
}

Future<String> generateCsv(Flight flight) async {
  List<List<dynamic>> rows = [[]];
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

  for (int i = 0; i < flight.flightData.length; i++) {
    List<dynamic> row = [];
    Map<dynamic, dynamic> flightData = flight.flightData[i].toRaw();
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

  String fileName =
      'timerf1_' + flight.planeId! + '_' + flight.endTimestamp.toString();
  File f = await getFile(fileName);

  String csv = const ListToCsvConverter().convert(rows);
  f.writeAsString(csv);

  return f.path;
}

Future<void> exportFlight2Csv(Flight flight) async {
  String filePath = await generateCsv(flight);
  final params = SaveFileDialogParams(sourceFilePath: filePath);
  await FlutterFileDialog.saveFile(params: params);
}

Future<void> shareFligth(Flight flight) async {
  String filePath = await generateCsv(flight);
  await ShareExtend.share(filePath, "timerf1c flight");
}
