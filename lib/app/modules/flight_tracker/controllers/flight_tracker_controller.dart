import 'dart:async';
import 'package:backdrop_modal_route/backdrop_modal_route.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/data/models/enums/fixed_location.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/modules/flight_history/controllers/flight_history_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_duration_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/core/utils/compute_centroid.dart';
import 'package:timer_f1/global_widgets/buttons/accept_button.dart';
import 'package:timer_f1/global_widgets/buttons/cancel_button.dart';
import 'package:timer_f1/global_widgets/modals/alert_modal.dart';

final flightControllerProvider =
    ChangeNotifierProvider.autoDispose<FlightTrackerController>((ref) =>
        FlightTrackerController(
            bleController: ref.read(bleControllerProvider),
            flightDurationController: ref.read(flightDurationProvider.notifier),
            flightHistoryController: ref.watch(flightHistoryControllerProvider),
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
  final FlightHistoryController flightHistoryController;
  final Flight flightProvider;
  final FlightDurationNotifier flightDurationController;
  Timer? checkLocationServiceTimer;
  ExpansionStatus expandibleToggle = ExpansionStatus.contracted;
  FixedLocation focusedOn = FixedLocation.userLocation;
  CenterOnLocationUpdate centerOnLocationUpdate = CenterOnLocationUpdate.always;
  bool locationServiceEnabled = true;

  final MapController mapController = MapController();

  FlightTrackerController(
      {required this.flightDurationController,
      required this.bleController,
      required this.flightHistoryController,
      required this.flightProvider}) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _watchLocationEnabled();
    });
  }

  Future<void> _saveFlight() async {
    String address = '';
    try {
      var userCoords = flightProvider.flightData.first.userCoordinates;
      var geo = await placemarkFromCoordinates(
          userCoords!.latitude, userCoords.longitude);
      if (geo.first.country != null) {
        address = '${geo.first.country}, ${geo.first.street}';
      }
    } catch (e) {
      print('Can not get geolocation. $e');
    }
    flightProvider.finish(address);
    flightHistoryController.saveFlight(flightProvider);
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
      Navigator.push(
          context,
          BackdropModalRoute(
            topPadding: MediaQuery.of(context).size.height - 200,
            canBarrierDismiss: true,
            safeAreaBottom: false,
            overlayContentBuilder: (context) => AlertModal(
              height: 200,
              title: 'No data to save',
              subtitle:
                  'No data will be saved because there is no plane coordinates.',
              buttons: [
                AcceptButton(
                    text: 'Exit',
                    minimumSize: Size(310, 45),
                    onPressed: () {
                      flightDurationController.reset();
                      GoRouter.of(context).go(Routes.HOME);
                    })
              ],
            ),
          ));
    } else {
      Navigator.push(
          context,
          BackdropModalRoute(
            topPadding: MediaQuery.of(context).size.height - 200,
            canBarrierDismiss: true,
            safeAreaBottom: false,
            overlayContentBuilder: (context) => AlertModal(
              height: 200,
              title: 'Do you want to end the fly?',
              subtitle: 'The fly will be saved on your history.',
              buttons: [
                CancelButton(
                    text: 'Cancel',
                    minimumSize: Size(150, 45),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    }),
                AcceptButton(
                    text: 'Yes',
                    onPressed: () async {
                      await _saveFlight();
                      GoRouter.of(context).go(Routes.HOME);
                    },
                    minimumSize: Size(150, 45)),
              ],
            ),
          ));
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
