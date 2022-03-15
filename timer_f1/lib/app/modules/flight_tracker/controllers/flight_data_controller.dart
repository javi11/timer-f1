import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
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
  var usbController = ref.watch(usbControllerProvider);
  var bleController = ref.watch(bleControllerProvider);
  var flight = ref.watch(flightProvider);
  LocationMarkerPosition? currentUserPosition;
  // We only care of the last known user position to add it to the flight data.
  var userPositionSub = userPositionStream.listen((event) {
    currentUserPosition = event;
  });

  FlightData mapFlightData(FlightData flightData) {
    if (currentUserPosition != null) {
      flightData.userLat = currentUserPosition!.latitude;
      flightData.userLng = currentUserPosition!.longitude;
    }
    // Start the flight on receive first data.
    if (flight.startTimestamp == null) {
      flightData.isInitial = true;
      flight.start();
    }
    flight.addData(flightData);
    return flightData;
  }

  ref.onDispose(() {
    userPositionSub.cancel();
  });

  if (usbController.isConnected == false &&
      bleController.bluetoothState != BluetoothState.connected) {
    return Stream.value(flight.flightData.last);
  }

  if (usbController.isConnected == true) {
    return usbController
        .subscribeToDeviceDataStream()
        .transform(VicentTimerFlightDataParser())
        .takeWhile((element) => element.planeCoordinates != null)
        .map(mapFlightData)
        .handleError((error) {
      // Ignore this kind of errors.
      print('Error on getting the stream $error');
    });
  }

  return bleController
      .subscribeToDeviceDataStream()
      .transform(VicentTimerFlightDataParser())
      .takeWhile((element) => element.planeCoordinates != null)
      .map(mapFlightData)
      .handleError((error) {
    // Ignore this kind of errors.
    print('Error on getting the stream $error');
  });
});
