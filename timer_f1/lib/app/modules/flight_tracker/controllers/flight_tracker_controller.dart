import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/data/models/enums/fixed_location.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/data/repositories/flight_repository.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/core/utils/compute_centroid.dart';

final mapControllerProvider =
    Provider.autoDispose<MapController>((ref) => MapController());
final flightControllerProvider =
    ChangeNotifierProvider.autoDispose<FlightTrackerController>((ref) =>
        FlightTrackerController(
            bleController: ref.read(bleControllerProvider),
            flightRepository: ref.watch(flightRepositoryProvider),
            mapController: ref.watch(mapControllerProvider),
            flightProvider: ref.watch(flightProvider)));
final expandibleToggleSelector =
    flightControllerProvider.select((value) => value.expandibleToggle);
final centerOnLocationUpdateSelector =
    flightControllerProvider.select((value) => value.centerOnLocationUpdate);
final focusedOnSelector =
    flightControllerProvider.select((value) => value.focusedOn);
final locationServiceEnabledSelector =
    flightControllerProvider.select((value) => value.locationServiceEnabled);

class FlightTrackerController extends ChangeNotifier {
  GlobalKey<ExpandableBottomSheetState> expandibleKey = GlobalKey();
  final BLEController bleController;
  final FlightRepository flightRepository;
  final Flight flightProvider;
  Timer? checkLocationServiceTimer;
  ExpansionStatus expandibleToggle = ExpansionStatus.contracted;
  FixedLocation focusedOn = FixedLocation.userLocation;
  CenterOnLocationUpdate centerOnLocationUpdate = CenterOnLocationUpdate.always;
  bool locationServiceEnabled = true;

  final MapController mapController;

  FlightTrackerController(
      {required this.bleController,
      required this.flightRepository,
      required this.mapController,
      required this.flightProvider}) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _watchLocationEnabled();
    });
  }

  void _saveFlight() {
    flightProvider.finish();
    flightRepository.saveFlight(flightProvider);
  }

  void _focusOnUser() {
    if (focusedOn == FixedLocation.userLocation) {
      focusedOn = FixedLocation.none;
      centerOnLocationUpdate = CenterOnLocationUpdate.never;
    } else {
      focusedOn = FixedLocation.userLocation;
      centerOnLocationUpdate = CenterOnLocationUpdate.always;
    }
  }

  void _focusOnPlane() {
    if (focusedOn == FixedLocation.planeLocation) {
      focusedOn = FixedLocation.none;
    } else {
      focusedOn = FixedLocation.planeLocation;
      centerOnLocationUpdate = CenterOnLocationUpdate.never;
    }
  }

  Future<void> _watchLocationEnabled() async {
    PermissionStatus status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      checkLocationServiceTimer =
          Timer.periodic(Duration(seconds: 3), (_) async {
        var isGranted = await Permission.location.isGranted;
        if (isGranted != locationServiceEnabled) {
          locationServiceEnabled = isGranted;
          notifyListeners();
        }
      });
    }
  }

  void onExit(BuildContext context) {
    if (flightProvider.flightStartCoordinates == null) {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.BOTTOMSLIDE,
          title: 'No data to save',
          desc: 'No data will be saved because there is no plane coordinates.',
          btnOkText: 'Exit',
          btnOkOnPress: () {
            GoRouter.of(context).go(Routes.HOME);
          }).show();
    } else {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.INFO,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Do you want to end the fly?',
          desc: 'The fly will be saved on your history',
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            int durationInMs = flightProvider.elapsedTime;
            if (durationInMs > 30000) {
              _saveFlight();
              GoRouter.of(context).go(Routes.HOME);
            } else {
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.WARNING,
                  animType: AnimType.BOTTOMSLIDE,
                  title: 'Flight is to short',
                  desc: 'Do you still want to save it?',
                  btnCancelText: 'No',
                  btnOkText: 'Yes',
                  btnCancelOnPress: () {
                    GoRouter.of(context).go(Routes.HOME);
                  },
                  btnOkOnPress: () {
                    _saveFlight();
                    GoRouter.of(context).go(Routes.HOME);
                  }).show();
            }
          }).show();
    }
  }

  void onZoom(LatLng? planeCoordinates, LatLng? userCoordinates) {
    if (planeCoordinates != null && userCoordinates != null) {
      mapController.move(computeCentroid([planeCoordinates, userCoordinates]),
          mapController.zoom);
      if (!mapController.bounds!.contains(planeCoordinates) |
          !mapController.bounds!.contains(userCoordinates)) {
        mapController.bounds!.extend(planeCoordinates);
        mapController.bounds!.extend(userCoordinates);
        mapController.fitBounds(mapController.bounds!);
      }
      focusedOn = FixedLocation.none;
      notifyListeners();
    }
  }

  void onMoreInfo() {
    if (expandibleToggle != ExpansionStatus.expanded) {
      expandibleKey.currentState?.expand();
      expandibleToggle = ExpansionStatus.expanded;
    } else {
      expandibleKey.currentState?.contract();
      expandibleToggle = ExpansionStatus.contracted;
    }
    notifyListeners();
  }

  void onFixPlane(LatLng? planeCoordinates) {
    if (planeCoordinates != null) {
      _focusOnPlane();
      mapController.move(planeCoordinates, 15.0);
      centerOnLocationUpdate = CenterOnLocationUpdate.never;
      notifyListeners();
    }
  }

  Future<void> onPressUserLocation(LatLng? userCoordinates) async {
    if (userCoordinates != null) {
      if (locationServiceEnabled) {
        _focusOnUser();
        mapController.move(userCoordinates, 15.0);
      } else {
        await Permission.location.request();
      }
      notifyListeners();
    }
  }

  Future<void> onReConnect(Device pairedDevice) async {
    bleController.connect(pairedDevice);
    await bleController.pairDevice(pairedDevice);
  }
}
