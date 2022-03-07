import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';
import 'package:timer_f1/core/utils/timer_flight_data_transformer.dart';

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

final flightDataStreamProvider = StreamProvider.autoDispose<FlightData>((ref) {
  var userPositionStream = ref.watch(userPositionStreamProvider.stream);
  LocationMarkerPosition? currentUserPosition;
  // We only care of the last known user position to add it to the flight data.
  var userPositionSub = userPositionStream.listen((event) {
    currentUserPosition = event;
  });

  ref.onDispose(() {
    userPositionSub.cancel();
  });
  // ref.read(bleControllerProvider).subscribeToDeviceDataStream()
  return Stream.periodic(Duration(seconds: 1), (computation) {
    return '55,10,1,2020,10,11,12,6,47,139479167,-458041866,1232668,27.73,1014.77,369\n';
  })
      .transform(TimerFlightDataTransformer())
      .takeWhile((element) => element.planeCoordinates != null)
      .map((flightData) {
    if (currentUserPosition != null) {
      flightData.userLat = currentUserPosition!.latitude;
      flightData.userLng = currentUserPosition!.longitude;
    }
    return flightData;
  });
});

final flighHasStartedControllerProvider = Provider.autoDispose<bool>((ref) {
  var flighData = ref.watch(flightDataStreamProvider);

  return flighData != null;
});
