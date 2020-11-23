import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timmer/bluetooth-connection/bluetooth_connection_page.dart';
import 'package:timmer/models/flight_data.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/providers/bluetooth_provider.dart';
import 'package:timmer/providers/history_provider.dart';
import 'package:timmer/tracking/widgets/bottom_bar.dart';
import 'package:timmer/tracking/widgets/map.dart';
import 'package:timmer/tracking/widgets/map_info.dart';
import 'package:timmer/tracking/widgets/no_data_dialog.dart';
import 'package:timmer/tracking/widgets/voltage_indicator.dart';
import 'package:timmer/tracking/widgets/waiting_for_data_dialog.dart';
import 'package:timmer/widgets/plain_starting_point_marker.dart';
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
  Timer checkLocationServiceTimer;

  Location location = Location();
  FlightHistory currentFlightHistory;
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  FixedLocation focusOn = FixedLocation.UserLocation;

  bool locationServiceEnabled = true;
  bool startMarkerSet = false;

  bool moreInfoIsExpanded = false;
  bool timerDataAvailable = false;

  FlightData flightData;
  BluetoothProvider bluetoothProvider;
  StreamSubscription<List<String>> bluetoothDataSubscription;

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

  void _onReceiveBluetoothData(List<String> data) {
    setState(() {
      flightData.parseTimmerData(data);

      if (flightData.planeId != null && timerDataAvailable == false) {
        Navigator.of(context).pop();
        timerDataAvailable = true;
      }

      currentFlightHistory.addData(flightData);

      if (!startMarkerSet) {
        markers.add(buildPlainStartingPointMarker(flightData.planeCoordinates));
        startMarkerSet = true;
      }

      if (focusOn == FixedLocation.PlaneLocation) {
        mapController.move(flightData.planeCoordinates, 15.0);
      }
    });
  }

  void _watchLocationEnabled() async {
    PermissionStatus status = await location.hasPermission();

    if (status == PermissionStatus.granted) {
      checkLocationServiceTimer =
          Timer.periodic(Duration(seconds: 3), (_) async {
        bool enabled = await location.serviceEnabled();
        setState(() {
          locationServiceEnabled = enabled;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => buildWaitingForDataDialog(context));
    });
    Future.delayed(Duration(seconds: 10), () {
      if (timerDataAvailable == false) {
        Navigator.of(context).pop();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => buildNoDataDialog(context));
      }
    });

    // No info
    setState(() {
      flightData = new FlightData();
      currentFlightHistory = new FlightHistory();
      currentFlightHistory.start();

      _watchLocationEnabled();

      // Listen bluetooth events
      bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);
      // Start the bluetooth sniffer
      bluetoothProvider.getGenericServiceDataStream().then((stream) {
        bluetoothDataSubscription = stream.listen(_onReceiveBluetoothData);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    bluetoothDataSubscription?.cancel();
    bluetoothProvider.stopListening();
    checkLocationServiceTimer?.cancel();
  }

  Future<void> _saveFlight(FlightHistory flightHistory) async {
    await Provider.of<HistoryProvider>(context, listen: false)
        .addFlightHistory(flightHistory);
    Navigator.pop(context);
  }

  void _onExit() {
    if (currentFlightHistory.flightStartCoordinates == null) {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.BOTTOMSLIDE,
          tittle: 'No data to save',
          desc: 'No data will be saved because there is no plane coordinates.',
          btnOkText: 'Exit',
          btnCancelOnPress: () async {
            Navigator.pop(context);
          },
          btnOkOnPress: () async {
            Navigator.pop(context);
          }).show();
    } else {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.INFO,
          animType: AnimType.BOTTOMSLIDE,
          tittle: 'Do you want to end the fly?',
          desc: 'The fly will be saved on your history',
          btnCancelOnPress: () {},
          btnOkOnPress: () async {
            int durationInMs = currentFlightHistory.end();
            if (durationInMs > 30000) {
              await _saveFlight(currentFlightHistory);
            } else {
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.WARNING,
                  animType: AnimType.BOTTOMSLIDE,
                  tittle: 'Flight is to short',
                  desc: 'Do you still want to save it?',
                  btnCancelText: 'No',
                  btnOkText: 'Yes',
                  btnCancelOnPress: () async {
                    Navigator.pop(context);
                  },
                  btnOkOnPress: () async {
                    await _saveFlight(currentFlightHistory);
                  }).show();
            }
          }).show();
    }
  }

  void _onMoreInfo() {
    setState(() {
      if (!moreInfoIsExpanded) {
        moreInfoIsExpanded = true;
        expandibleController.currentState.expand();
      } else {
        moreInfoIsExpanded = false;
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
    // Do not allow rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    void _updatePoints(LatLng postion) {
      setState(() {
        flightData.addUserCoordinates(postion);
        if (focusOn == FixedLocation.UserLocation) {
          mapController.move(flightData.userCoordinates, 15.0);
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

    return Scaffold(
        body: ExpandableBottomSheet(
      key: expandibleController,
      expandableContent: MapInfo(flightData: flightData),
      persistentHeader: BottomBar(
        flightData: flightData,
        onExit: _onExit,
        onFixPlane: _onFixPlane,
        onZoom: _onZoom,
        onMoreInfo: _onMoreInfo,
        focusOn: focusOn,
        expanded: moreInfoIsExpanded,
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
          Padding(
              padding: EdgeInsetsDirectional.only(top: 30, end: 5, start: 5),
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blue[400],
                  elevation: 10,
                  child: SizedBox(
                      height: 60,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(end: 10, start: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Text('ID'),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  flightData.planeId,
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                VoltageIndicator(
                                    voltageAlert: flightData.voltageAlert,
                                    voltage: flightData.voltage),
                                SizedBox(
                                  width: 10,
                                ),
                                Selector<BluetoothProvider, ConnectionStatus>(
                                    selector: (_, bluetoothProvider) =>
                                        bluetoothProvider.connectionStatus,
                                    builder:
                                        (context, connectionStatus, child) {
                                      if (connectionStatus ==
                                          ConnectionStatus.CONNECTED) {
                                        return CircleAvatar(
                                          child: Icon(Icons.bluetooth_connected,
                                              color: Colors.white),
                                        );
                                      }

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .downToUp,
                                                  child:
                                                      BluetoothConnectionPage()));
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.orangeAccent,
                                          child: Icon(
                                            Icons.bluetooth_searching,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    })
                              ],
                            )
                          ],
                        ),
                      ))))
        ],
      ),
    ));
  }
}
