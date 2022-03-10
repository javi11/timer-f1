import 'dart:async';
import 'dart:convert';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/core/vicent_timer/vicent_timer_flight_data_parser.dart';

final userPositionStreamProvider =
    StreamProvider.autoDispose<LocationMarkerPosition>((ref) {
  var streamSubscription =
      const LocationMarkerDataStreamFactory().geolocatorPositionStream(
    stream: Geolocator.getPositionStream(
      locationSettings: LocationSettings(),
    ),
  );

  return streamSubscription;
});

final flightProvider = Provider.autoDispose<Flight>((ref) => Flight());

final flightDataStreamProvider = StreamProvider.autoDispose<FlightData>((ref) {
  var userPositionStream = ref.watch(userPositionStreamProvider.stream);
  var bleController = ref.watch(bleControllerProvider);
  var flight = ref.watch(flightProvider);
  LocationMarkerPosition? currentUserPosition;
  // We only care of the last known user position to add it to the flight data.
  var userPositionSub = userPositionStream.listen((event) {
    currentUserPosition = event;
  });

  ref.onDispose(() {
    userPositionSub.cancel();
  });

  if (bleController.bluetoothState != BluetoothState.connected) {
    return Stream.value(flight.flightData.last);
  }

  return bleController
      .subscribeToDeviceDataStream()
      .transform(VicentTimerFlightDataParser())
      .takeWhile((element) => element.planeCoordinates != null)
      .map((flightData) {
    if (currentUserPosition != null) {
      flightData.userLat = currentUserPosition!.latitude;
      flightData.userLng = currentUserPosition!.longitude;
    }
    // Start the flight on receive first data.
    if (flight.startTimestamp == null) {
      flight.start();
    }
    flight.addData(flightData);
    return flightData;
  }).handleError((error) {
    // Ignore this kind of errors.
    print('Error on getting the stream $error');
  });
});
