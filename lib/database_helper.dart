import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timerf1c/models/flight_data.dart';
import 'package:timerf1c/models/flight_history.dart';
import 'package:timerf1c/models/settings.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'timerf1cDB.db');
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE FlightHistory ('
          'id INTEGER PRIMARY KEY,'
          'durationInMs INTEGER,'
          'startTimestamp INTEGER,'
          'endTimestamp INTEGER,'
          'planeId TEXT,'
          'maxPressure REAL,'
          'maxHeight REAL,'
          'maxTemperature REAL,'
          'farPlaneDistanceLat TEXT,'
          'farPlaneDistanceLng TEXT,'
          'startFlightLng TEXT,'
          'startFlightLat TEXT,'
          'endFlightLng TEXT,'
          'endFlightLat TEXT,'
          'maxPlaneDistanceFromStart REAL'
          ')');

      await db.execute('CREATE TABLE FlightData ('
          'id INTEGER PRIMARY KEY,'
          'planeId TEXT,'
          'timestamp INTEGER,'
          'planeLat TEXT,'
          'planeLng TEXT,'
          'height REAL,'
          'temperature REAL,'
          'pressure REAL,'
          'voltage REAL,'
          'userLng TEXT,'
          'userLat TEXT,'
          'planeDistanceFromUser REAL,'
          'flightHistoryId INTEGER,'
          'FOREIGN KEY (flightHistoryId) REFERENCES FlightHistory (id) ON DELETE NO ACTION ON UPDATE NO ACTION'
          ')');
    });
  }

  newFlightHistory(FlightHistory flightHistory) async {
    final db = await database;
    // Prevent duplicate ID
    flightHistory.id = null;
    flightHistory.id = await db.insert('FlightHistory', flightHistory.toMap());
    flightHistory.flightData.forEach((element) async {
      element.flightHistoryId = flightHistory.id;
      // Prevent duplicate ID
      element.id = null;
      element.id = await db.insert('FlightData', element.toMap());
    });
    return flightHistory;
  }

  Future<List<FlightData>> getFlightDataFromId(int historyId) async {
    final db = await database;
    var res = await db.query('FlightData',
        columns: FlightData.columns,
        where: "flightHistoryId = ?",
        orderBy: "id ASC",
        whereArgs: [historyId]);

    List<FlightData> list =
        res.isNotEmpty ? res.map((c) => FlightData.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<FlightHistory>> getUserHistory(
      [int limit = 10, int offset = 0]) async {
    final db = await database;
    var res = await db.query('FlightHistory',
        columns: FlightHistory.columns,
        orderBy: 'endTimestamp DESC',
        limit: limit,
        offset: offset);

    List<FlightHistory> list = [];

    if (res.isNotEmpty) {
      Iterable<Future<FlightHistory>> populateData = res.map((c) async {
        FlightHistory history = FlightHistory.fromMap(c);
        history.addAll(await getFlightDataFromId(c['id']));
        return history;
      });
      Iterable<FlightHistory> flightDataList = await Future.wait(populateData);
      list = flightDataList.toList();
    }

    return list;
  }

  Future<int> getTotalCountHistory() async {
    final db = await database;
    int count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM FlightHistory'));

    return count;
  }
}
