import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:timmer/models/bluetooth.dart';
import 'package:timmer/models/flight_data.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/models/timmer.dart';
import 'package:timmer/tracking/widgets/bottom_bar.dart';
import 'package:timmer/tracking/widgets/map.dart';
import 'package:timmer/tracking/widgets/map_info.dart';
import 'package:timmer/tracking/widgets/marker.dart';
import 'package:timmer/tracking/widgets/voltage_warning.dart';
import 'package:timmer/types.dart';
import 'package:timmer/util/compute_centroid.dart';
import 'package:user_location/user_location.dart';
import 'package:latlong/latlong.dart';

class TrackingPage extends StatefulWidget {
  @override
  _TrackingPageState createState() {
    return _TrackingPageState();
  }
}

class _TrackingPageState extends State<TrackingPage> {
  final GlobalKey<ExpandableBottomSheetState> expandibleController =
      new GlobalKey();
  final GlobalKey<AnimatorWidgetState> plainIdController =
      GlobalKey<AnimatorWidgetState>();
  Timer checkLocationServiceTimer;

  Location location = Location();
  FlightHistory currentFlightHistory;
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  FixedLocation focusOn = FixedLocation.UserLocation;

  bool locationServiceEnabled = true;
  bool startMarkerSet = false;

  bool voltageWarningIsShowing = false;
  Flushbar voltageWarningPopUp = buildVoltageWarningPopup();
  bool isExpanded = false;

  FlightData flightData;
  Bluetooth bluetoothProvider;

  _focusOnUser() {
    if (focusOn == FixedLocation.UserLocation) {
      focusOn = null;
    } else {
      focusOn = FixedLocation.UserLocation;
    }
  }

  _focusOnPlane() {
    if (focusOn == FixedLocation.PlaneLocation) {
      focusOn = null;
    } else {
      focusOn = FixedLocation.PlaneLocation;
    }
  }

  void _checkBatteryWarning() {
    if (flightData.voltageAlert == true && voltageWarningIsShowing == false) {
      voltageWarningIsShowing = true;
      voltageWarningPopUp.show(context);
    } else if (flightData.voltageAlert == false &&
        voltageWarningPopUp.isShowing()) {
      voltageWarningIsShowing = false;
      voltageWarningPopUp.dismiss();
    }
  }

  void _onReceiveBluetoothData() {
    setState(() {
      flightData.parseTimmerData(bluetoothProvider.chunk);
      _checkBatteryWarning();

      if (!startMarkerSet) {
        markers.add(buildMarker(
            flightData.planeCoordinates, AnchorAlign.top, Icons.location_on));
        startMarkerSet = true;
      }
      currentFlightHistory.addData(flightData);
      if (!plainIdController.currentState.mounted && flightData.id.length > 0) {
        plainIdController.currentState.forward();
      } else if (plainIdController.currentState.mounted &&
          flightData.id.length == 0) {
        plainIdController.currentState.stop();
      }
    });
  }

  void _watchLocationEnabled() {
    location.hasPermission().then((status) async {
      if (status == PermissionStatus.GRANTED) {
        checkLocationServiceTimer = Timer.periodic(Duration(seconds: 3), (_) {
          location.serviceEnabled().then((enabled) async {
            setState(() {
              locationServiceEnabled = enabled;
            });
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // No info
    flightData = new FlightData();
    currentFlightHistory = new FlightHistory();
    currentFlightHistory.start();

    _watchLocationEnabled();

    // Listen bluetooth events
    bluetoothProvider = Provider.of<Bluetooth>(context, listen: false);
    bluetoothProvider.addListener(_onReceiveBluetoothData);
    // Start the bluetooth sniffer
    bluetoothProvider.start();
  }

  @override
  void dispose() {
    super.dispose();
    bluetoothProvider.stop(_onReceiveBluetoothData);
    checkLocationServiceTimer.cancel();
  }

  void _onExit() {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO,
        animType: AnimType.BOTTOMSLIDE,
        tittle: 'Do you want to end the fly?',
        desc: 'The fly will be saved on your history',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          currentFlightHistory.end();
          Provider.of<Timmer>(context, listen: false)
              .addFlightHistory(currentFlightHistory);
          Navigator.pop(context);
        }).show();
  }

  void _onMoreInfo() {
    setState(() {
      if (!isExpanded) {
        isExpanded = true;
        expandibleController.currentState.expand();
      } else {
        isExpanded = false;
        expandibleController.currentState.contract();
      }
    });
  }

  void _onZoom() {
    setState(() {
      mapController.move(
          computeCentroid(
              [flightData.planeCoordinates, flightData.userCoordinates]),
          mapController.zoom);
      if (!mapController.bounds.contains(flightData.planeCoordinates) |
          !mapController.bounds.contains(flightData.userCoordinates)) {
        mapController.bounds.extend(flightData.planeCoordinates);
        mapController.bounds.extend(flightData.userCoordinates);
        mapController.fitBounds(mapController.bounds);
      }
      focusOn = null;
    });
  }

  void _onFixPlane() {
    setState(() {
      _focusOnPlane();
      mapController.move(flightData.planeCoordinates, 15.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    void _updatePoints(LatLng postion) {
      setState(() {
        flightData.addUserCoordinates(postion);
        currentFlightHistory.addData(flightData);
        if (focusOn == FixedLocation.UserLocation) {
          mapController.move(flightData.userCoordinates, 15.0);
        } else if (focusOn == FixedLocation.PlaneLocation) {
          mapController.move(flightData.planeCoordinates, 15.0);
        }
      });
    }

    userLocationOptions = UserLocationOptions(
        context: context,
        mapController: mapController,
        markers: markers,
        updateMapLocationOnPositionChange: false,
        zoomToCurrentLocationOnLoad: true,
        fabWidth: 60,
        fabHeight: 60,
        fabBottom: 140,
        fabRight: 8,
        moveToCurrentLocationFloatingActionButton: FloatingActionButton(
          heroTag: 'userLocation',
          onPressed: () async {
            if (locationServiceEnabled) {
              setState(() {
                _focusOnUser();
                mapController.move(flightData.userCoordinates, 15.0);
              });
            } else {
              await location.requestService();
            }
          },
          child: Icon(
            locationServiceEnabled
                ? Icons.my_location
                : Icons.location_disabled,
            color:
                focusOn == FixedLocation.UserLocation && locationServiceEnabled
                    ? Colors.blue
                    : Colors.black45,
          ),
          backgroundColor: Colors.white,
        ),
        onLocationUpdate: _updatePoints);

    return Material(
        child: ExpandableBottomSheet(
      key: expandibleController,
      expandableContent: MapInfo(flightData: flightData),
      persistentHeader: BottomBar(
        flightData: flightData,
        onExit: _onExit,
        onFixPlane: _onFixPlane,
        onZoom: _onZoom,
        onMoreInfo: _onMoreInfo,
        focusOn: focusOn,
        expanded: isExpanded,
      ),
      background: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          buildMap(markers, flightData, userLocationOptions, mapController),
          Positioned(
              height: 60,
              width: 60,
              bottom: 210,
              right: 8,
              child: FloatingActionButton(
                heroTag: 'planeLocation',
                onPressed: _onFixPlane,
                child: Icon(
                  Icons.airplanemode_active,
                  color: focusOn == FixedLocation.PlaneLocation
                      ? Colors.blue
                      : Colors.black45,
                ),
                backgroundColor: Colors.white,
              )),
          SlideInDown(
              key: plainIdController,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                    top: voltageWarningIsShowing == true ? 110 : 40),
                child: Chip(
                  backgroundColor: Colors.white,
                  avatar: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    child: Text('ID'),
                  ),
                  label: Text(
                    flightData.id,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )),
        ],
      ),
    ));
  }
}
