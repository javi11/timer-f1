// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:objectbox/flatbuffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'app/data/flight_data_model.dart';
import 'app/data/flight_model.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 3061457304180658995),
      name: 'FlightData',
      lastPropertyId: const IdUid(14, 4326614712316840562),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 7788544680319598218),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 1037460028669781188),
            name: 'flightHistoryId',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 457563556241348715),
            name: 'planeId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 6389126714829006112),
            name: 'timestamp',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 2008351662907154908),
            name: 'planeLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 6067844526768714051),
            name: 'planeLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 6612662928149180055),
            name: 'height',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 7668979215162425320),
            name: 'temperature',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 624350220032852171),
            name: 'pressure',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 6335546391063036538),
            name: 'voltage',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(11, 765403417265279720),
            name: 'userLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 2317994971154758884),
            name: 'userLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(13, 8614861252981847458),
            name: 'planeDistanceFromUser',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(14, 4326614712316840562),
            name: 'flightId',
            type: 11,
            flags: 520,
            indexId: const IdUid(1, 7534613698694348631),
            relationTarget: 'Flight')
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(2, 5990792546984347760),
      name: 'Flight',
      lastPropertyId: const IdUid(15, 1263282345018303407),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5098378351077815534),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 6255126910667171662),
            name: 'durationInMs',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 8169177614705301634),
            name: 'startTimestamp',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 7243718363641949341),
            name: 'endTimestamp',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 3958763700820368182),
            name: 'planeId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 6265413215552501088),
            name: 'maxPressure',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 249743174848569499),
            name: 'maxHeight',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 8710093475539641505),
            name: 'maxTemperature',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 4954274504031420380),
            name: 'farPlaneDistanceLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 4360618641032162524),
            name: 'farPlaneDistanceLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(11, 2215697120880735053),
            name: 'startFlightLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 8301834090352184866),
            name: 'startFlightLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(13, 5768673946564020647),
            name: 'endFlightLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(14, 5376494315693434721),
            name: 'endFlightLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(15, 1263282345018303407),
            name: 'maxPlaneDistanceFromStart',
            type: 8,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[
        ModelBacklink(
            name: 'flightData', srcEntity: 'FlightData', srcField: 'flight')
      ])
];

/// Open an ObjectBox store with the model declared in this file.
Future<Store> openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) async =>
    Store(getObjectBoxModel(),
        directory: directory ?? (await defaultStoreDirectory()).path,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// ObjectBox model definition, pass it to [Store] - Store(getObjectBoxModel())
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(2, 5990792546984347760),
      lastIndexId: const IdUid(1, 7534613698694348631),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    FlightData: EntityDefinition<FlightData>(
        model: _entities[0],
        toOneRelations: (FlightData object) => [object.flight],
        toManyRelations: (FlightData object) => {},
        getId: (FlightData object) => object.id,
        setId: (FlightData object, int id) {
          object.id = id;
        },
        objectToFB: (FlightData object, fb.Builder fbb) {
          final planeIdOffset =
              object.planeId == null ? null : fbb.writeString(object.planeId!);
          fbb.startTable(15);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.flightHistoryId);
          fbb.addOffset(2, planeIdOffset);
          fbb.addInt64(3, object.timestamp);
          fbb.addFloat64(4, object.planeLat);
          fbb.addFloat64(5, object.planeLng);
          fbb.addFloat64(6, object.height);
          fbb.addFloat64(7, object.temperature);
          fbb.addFloat64(8, object.pressure);
          fbb.addFloat64(9, object.voltage);
          fbb.addFloat64(10, object.userLng);
          fbb.addFloat64(11, object.userLat);
          fbb.addFloat64(12, object.planeDistanceFromUser);
          fbb.addInt64(13, object.flight.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = FlightData(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              flightHistoryId: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 6),
              planeId: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 8),
              timestamp: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 10),
              planeLat: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 12),
              planeLng: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 14),
              height: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 16),
              temperature: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 18),
              pressure: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 20),
              voltage: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 22),
              userLng: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 24),
              userLat: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 26))
            ..planeDistanceFromUser =
                const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 28);
          object.flight.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 30, 0);
          object.flight.attach(store);
          return object;
        }),
    Flight: EntityDefinition<Flight>(
        model: _entities[1],
        toOneRelations: (Flight object) => [],
        toManyRelations: (Flight object) => {
              RelInfo<FlightData>.toOneBacklink(14, object.id,
                  (FlightData srcObject) => srcObject.flight): object.flightData
            },
        getId: (Flight object) => object.id,
        setId: (Flight object, int id) {
          object.id = id;
        },
        objectToFB: (Flight object, fb.Builder fbb) {
          final planeIdOffset =
              object.planeId == null ? null : fbb.writeString(object.planeId!);
          fbb.startTable(16);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.durationInMs);
          fbb.addInt64(2, object.startTimestamp);
          fbb.addInt64(3, object.endTimestamp);
          fbb.addOffset(4, planeIdOffset);
          fbb.addFloat64(5, object.maxPressure);
          fbb.addFloat64(6, object.maxHeight);
          fbb.addFloat64(7, object.maxTemperature);
          fbb.addFloat64(8, object.farPlaneDistanceLat);
          fbb.addFloat64(9, object.farPlaneDistanceLng);
          fbb.addFloat64(10, object.startFlightLng);
          fbb.addFloat64(11, object.startFlightLat);
          fbb.addFloat64(12, object.endFlightLng);
          fbb.addFloat64(13, object.endFlightLat);
          fbb.addFloat64(14, object.maxPlaneDistanceFromStart);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Flight(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              durationInMs: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 6),
              startTimestamp: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 8),
              endTimestamp: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 10),
              planeId: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 12),
              maxPressure: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 14),
              maxHeight: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 16),
              maxTemperature: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 18),
              farPlaneDistanceLat: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 20),
              farPlaneDistanceLng: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 22),
              startFlightLng: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 24),
              startFlightLat: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 26),
              endFlightLng: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 28),
              endFlightLat: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 30),
              maxPlaneDistanceFromStart: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 32));
          InternalToManyAccess.setRelInfo(
              object.flightData,
              store,
              RelInfo<FlightData>.toOneBacklink(
                  14, object.id, (FlightData srcObject) => srcObject.flight),
              store.box<Flight>());
          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [FlightData] entity fields to define ObjectBox queries.
class FlightData_ {
  /// see [FlightData.id]
  static final id =
      QueryIntegerProperty<FlightData>(_entities[0].properties[0]);

  /// see [FlightData.flightHistoryId]
  static final flightHistoryId =
      QueryIntegerProperty<FlightData>(_entities[0].properties[1]);

  /// see [FlightData.planeId]
  static final planeId =
      QueryStringProperty<FlightData>(_entities[0].properties[2]);

  /// see [FlightData.timestamp]
  static final timestamp =
      QueryIntegerProperty<FlightData>(_entities[0].properties[3]);

  /// see [FlightData.planeLat]
  static final planeLat =
      QueryDoubleProperty<FlightData>(_entities[0].properties[4]);

  /// see [FlightData.planeLng]
  static final planeLng =
      QueryDoubleProperty<FlightData>(_entities[0].properties[5]);

  /// see [FlightData.height]
  static final height =
      QueryDoubleProperty<FlightData>(_entities[0].properties[6]);

  /// see [FlightData.temperature]
  static final temperature =
      QueryDoubleProperty<FlightData>(_entities[0].properties[7]);

  /// see [FlightData.pressure]
  static final pressure =
      QueryDoubleProperty<FlightData>(_entities[0].properties[8]);

  /// see [FlightData.voltage]
  static final voltage =
      QueryDoubleProperty<FlightData>(_entities[0].properties[9]);

  /// see [FlightData.userLng]
  static final userLng =
      QueryDoubleProperty<FlightData>(_entities[0].properties[10]);

  /// see [FlightData.userLat]
  static final userLat =
      QueryDoubleProperty<FlightData>(_entities[0].properties[11]);

  /// see [FlightData.planeDistanceFromUser]
  static final planeDistanceFromUser =
      QueryDoubleProperty<FlightData>(_entities[0].properties[12]);

  /// see [FlightData.flight]
  static final flight =
      QueryRelationToOne<FlightData, Flight>(_entities[0].properties[13]);
}

/// [Flight] entity fields to define ObjectBox queries.
class Flight_ {
  /// see [Flight.id]
  static final id = QueryIntegerProperty<Flight>(_entities[1].properties[0]);

  /// see [Flight.durationInMs]
  static final durationInMs =
      QueryIntegerProperty<Flight>(_entities[1].properties[1]);

  /// see [Flight.startTimestamp]
  static final startTimestamp =
      QueryIntegerProperty<Flight>(_entities[1].properties[2]);

  /// see [Flight.endTimestamp]
  static final endTimestamp =
      QueryIntegerProperty<Flight>(_entities[1].properties[3]);

  /// see [Flight.planeId]
  static final planeId =
      QueryStringProperty<Flight>(_entities[1].properties[4]);

  /// see [Flight.maxPressure]
  static final maxPressure =
      QueryDoubleProperty<Flight>(_entities[1].properties[5]);

  /// see [Flight.maxHeight]
  static final maxHeight =
      QueryDoubleProperty<Flight>(_entities[1].properties[6]);

  /// see [Flight.maxTemperature]
  static final maxTemperature =
      QueryDoubleProperty<Flight>(_entities[1].properties[7]);

  /// see [Flight.farPlaneDistanceLat]
  static final farPlaneDistanceLat =
      QueryDoubleProperty<Flight>(_entities[1].properties[8]);

  /// see [Flight.farPlaneDistanceLng]
  static final farPlaneDistanceLng =
      QueryDoubleProperty<Flight>(_entities[1].properties[9]);

  /// see [Flight.startFlightLng]
  static final startFlightLng =
      QueryDoubleProperty<Flight>(_entities[1].properties[10]);

  /// see [Flight.startFlightLat]
  static final startFlightLat =
      QueryDoubleProperty<Flight>(_entities[1].properties[11]);

  /// see [Flight.endFlightLng]
  static final endFlightLng =
      QueryDoubleProperty<Flight>(_entities[1].properties[12]);

  /// see [Flight.endFlightLat]
  static final endFlightLat =
      QueryDoubleProperty<Flight>(_entities[1].properties[13]);

  /// see [Flight.maxPlaneDistanceFromStart]
  static final maxPlaneDistanceFromStart =
      QueryDoubleProperty<Flight>(_entities[1].properties[14]);
}
