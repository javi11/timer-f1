// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'app/data/models/flight_data_model.dart';
import 'app/data/models/flight_model.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 3617741553367741416),
      name: 'Flight',
      lastPropertyId: const IdUid(16, 757837763565641298),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 8197531307069830182),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 3119362607594110509),
            name: 'startTimestamp',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 7065487454957984963),
            name: 'durationInMs',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 7000256746130150781),
            name: 'endTimestamp',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 3820573597573610140),
            name: 'planeId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 5286937463019224857),
            name: 'maxPressure',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 5281464452431523957),
            name: 'maxHeight',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 6349820843352883293),
            name: 'maxTemperature',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 1707142063431928861),
            name: 'farPlaneDistanceLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 2557690390243076247),
            name: 'farPlaneDistanceLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(11, 260385017123311303),
            name: 'startFlightLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 3021449412803215971),
            name: 'startFlightLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(13, 4986105825531599917),
            name: 'endFlightLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(14, 8577958606838120936),
            name: 'endFlightLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(15, 3708300250080366842),
            name: 'maxPlaneDistanceFromStart',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(16, 757837763565641298),
            name: 'maxPlaneDistanceFromUser',
            type: 8,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[
        ModelBacklink(
            name: 'flightData', srcEntity: 'FlightData', srcField: 'flight')
      ]),
  ModelEntity(
      id: const IdUid(2, 1996917656354719130),
      name: 'FlightData',
      lastPropertyId: const IdUid(15, 3085372596932118392),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5761424148726819047),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 955355203143129608),
            name: 'isConnectedToPlane',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 3034893611289659868),
            name: 'flightHistoryId',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 3796642959493733523),
            name: 'planeId',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 7728617168268401784),
            name: 'timestamp',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 4043674209865252467),
            name: 'planeLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 5130337363462404811),
            name: 'planeLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 675320341134320462),
            name: 'height',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 6048122397642438921),
            name: 'temperature',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 697926613373307829),
            name: 'pressure',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(11, 3924585362923200929),
            name: 'voltage',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 5447326414969738812),
            name: 'userLng',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(13, 5622336359712150334),
            name: 'userLat',
            type: 8,
            flags: 0),
        ModelProperty(
            id: const IdUid(14, 5009816197382593742),
            name: 'isInitial',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(15, 3085372596932118392),
            name: 'flightId',
            type: 11,
            flags: 520,
            indexId: const IdUid(1, 5182127689446183035),
            relationTarget: 'Flight')
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
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
      lastEntityId: const IdUid(2, 1996917656354719130),
      lastIndexId: const IdUid(1, 5182127689446183035),
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
    Flight: EntityDefinition<Flight>(
        model: _entities[0],
        toOneRelations: (Flight object) => [],
        toManyRelations: (Flight object) => {
              RelInfo<FlightData>.toOneBacklink(15, object.id,
                  (FlightData srcObject) => srcObject.flight): object.flightData
            },
        getId: (Flight object) => object.id,
        setId: (Flight object, int id) {
          object.id = id;
        },
        objectToFB: (Flight object, fb.Builder fbb) {
          final planeIdOffset =
              object.planeId == null ? null : fbb.writeString(object.planeId!);
          fbb.startTable(17);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.startTimestamp);
          fbb.addInt64(2, object.durationInMs);
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
          fbb.addFloat64(15, object.maxPlaneDistanceFromUser);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Flight(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              durationInMs: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 8),
              startTimestamp: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 6),
              endTimestamp: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 10),
              planeId: const fb.StringReader(asciiOptimization: true)
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
              startFlightLat: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 26),
              endFlightLng: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 28),
              endFlightLat: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 30),
              maxPlaneDistanceFromStart: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 32),
              maxPlaneDistanceFromUser: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 34));
          InternalToManyAccess.setRelInfo(
              object.flightData,
              store,
              RelInfo<FlightData>.toOneBacklink(
                  15, object.id, (FlightData srcObject) => srcObject.flight),
              store.box<Flight>());
          return object;
        }),
    FlightData: EntityDefinition<FlightData>(
        model: _entities[1],
        toOneRelations: (FlightData object) => [object.flight],
        toManyRelations: (FlightData object) => {},
        getId: (FlightData object) => object.id,
        setId: (FlightData object, int id) {
          object.id = id;
        },
        objectToFB: (FlightData object, fb.Builder fbb) {
          final planeIdOffset =
              object.planeId == null ? null : fbb.writeString(object.planeId!);
          fbb.startTable(16);
          fbb.addInt64(0, object.id);
          fbb.addBool(1, object.isConnectedToPlane);
          fbb.addInt64(2, object.flightHistoryId);
          fbb.addOffset(3, planeIdOffset);
          fbb.addInt64(4, object.timestamp);
          fbb.addFloat64(5, object.planeLat);
          fbb.addFloat64(6, object.planeLng);
          fbb.addFloat64(7, object.height);
          fbb.addFloat64(8, object.temperature);
          fbb.addFloat64(9, object.pressure);
          fbb.addFloat64(10, object.voltage);
          fbb.addFloat64(11, object.userLng);
          fbb.addFloat64(12, object.userLat);
          fbb.addBool(13, object.isInitial);
          fbb.addInt64(14, object.flight.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = FlightData(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              isConnectedToPlane:
                  const fb.BoolReader().vTableGet(buffer, rootOffset, 6, false),
              flightHistoryId: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 8),
              planeId: const fb.StringReader(asciiOptimization: true)
                  .vTableGetNullable(buffer, rootOffset, 10),
              timestamp: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 12),
              planeLat: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 14),
              planeLng: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 16),
              height: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 18),
              temperature: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 20),
              pressure: const fb.Float64Reader()
                  .vTableGetNullable(buffer, rootOffset, 22),
              voltage:
                  const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 24),
              userLng: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 26),
              userLat: const fb.Float64Reader().vTableGetNullable(buffer, rootOffset, 28),
              isInitial: const fb.BoolReader().vTableGetNullable(buffer, rootOffset, 30));
          object.flight.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 32, 0);
          object.flight.attach(store);
          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [Flight] entity fields to define ObjectBox queries.
class Flight_ {
  /// see [Flight.id]
  static final id = QueryIntegerProperty<Flight>(_entities[0].properties[0]);

  /// see [Flight.startTimestamp]
  static final startTimestamp =
      QueryIntegerProperty<Flight>(_entities[0].properties[1]);

  /// see [Flight.durationInMs]
  static final durationInMs =
      QueryIntegerProperty<Flight>(_entities[0].properties[2]);

  /// see [Flight.endTimestamp]
  static final endTimestamp =
      QueryIntegerProperty<Flight>(_entities[0].properties[3]);

  /// see [Flight.planeId]
  static final planeId =
      QueryStringProperty<Flight>(_entities[0].properties[4]);

  /// see [Flight.maxPressure]
  static final maxPressure =
      QueryDoubleProperty<Flight>(_entities[0].properties[5]);

  /// see [Flight.maxHeight]
  static final maxHeight =
      QueryDoubleProperty<Flight>(_entities[0].properties[6]);

  /// see [Flight.maxTemperature]
  static final maxTemperature =
      QueryDoubleProperty<Flight>(_entities[0].properties[7]);

  /// see [Flight.farPlaneDistanceLat]
  static final farPlaneDistanceLat =
      QueryDoubleProperty<Flight>(_entities[0].properties[8]);

  /// see [Flight.farPlaneDistanceLng]
  static final farPlaneDistanceLng =
      QueryDoubleProperty<Flight>(_entities[0].properties[9]);

  /// see [Flight.startFlightLng]
  static final startFlightLng =
      QueryDoubleProperty<Flight>(_entities[0].properties[10]);

  /// see [Flight.startFlightLat]
  static final startFlightLat =
      QueryDoubleProperty<Flight>(_entities[0].properties[11]);

  /// see [Flight.endFlightLng]
  static final endFlightLng =
      QueryDoubleProperty<Flight>(_entities[0].properties[12]);

  /// see [Flight.endFlightLat]
  static final endFlightLat =
      QueryDoubleProperty<Flight>(_entities[0].properties[13]);

  /// see [Flight.maxPlaneDistanceFromStart]
  static final maxPlaneDistanceFromStart =
      QueryDoubleProperty<Flight>(_entities[0].properties[14]);

  /// see [Flight.maxPlaneDistanceFromUser]
  static final maxPlaneDistanceFromUser =
      QueryDoubleProperty<Flight>(_entities[0].properties[15]);
}

/// [FlightData] entity fields to define ObjectBox queries.
class FlightData_ {
  /// see [FlightData.id]
  static final id =
      QueryIntegerProperty<FlightData>(_entities[1].properties[0]);

  /// see [FlightData.isConnectedToPlane]
  static final isConnectedToPlane =
      QueryBooleanProperty<FlightData>(_entities[1].properties[1]);

  /// see [FlightData.flightHistoryId]
  static final flightHistoryId =
      QueryIntegerProperty<FlightData>(_entities[1].properties[2]);

  /// see [FlightData.planeId]
  static final planeId =
      QueryStringProperty<FlightData>(_entities[1].properties[3]);

  /// see [FlightData.timestamp]
  static final timestamp =
      QueryIntegerProperty<FlightData>(_entities[1].properties[4]);

  /// see [FlightData.planeLat]
  static final planeLat =
      QueryDoubleProperty<FlightData>(_entities[1].properties[5]);

  /// see [FlightData.planeLng]
  static final planeLng =
      QueryDoubleProperty<FlightData>(_entities[1].properties[6]);

  /// see [FlightData.height]
  static final height =
      QueryDoubleProperty<FlightData>(_entities[1].properties[7]);

  /// see [FlightData.temperature]
  static final temperature =
      QueryDoubleProperty<FlightData>(_entities[1].properties[8]);

  /// see [FlightData.pressure]
  static final pressure =
      QueryDoubleProperty<FlightData>(_entities[1].properties[9]);

  /// see [FlightData.voltage]
  static final voltage =
      QueryDoubleProperty<FlightData>(_entities[1].properties[10]);

  /// see [FlightData.userLng]
  static final userLng =
      QueryDoubleProperty<FlightData>(_entities[1].properties[11]);

  /// see [FlightData.userLat]
  static final userLat =
      QueryDoubleProperty<FlightData>(_entities[1].properties[12]);

  /// see [FlightData.isInitial]
  static final isInitial =
      QueryBooleanProperty<FlightData>(_entities[1].properties[13]);

  /// see [FlightData.flight]
  static final flight =
      QueryRelationToOne<FlightData, Flight>(_entities[1].properties[14]);
}
