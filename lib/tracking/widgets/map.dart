import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/models/timmer.dart';
import 'package:timmer/models/timmer_data.dart';
import 'package:timmer/tracking/widgets/map-info.dart';
import 'package:timmer/tracking/widgets/voltage_warning.dart';
import 'package:timmer/util/compute_centroid.dart';
import 'package:timmer/util/distance_calculator.dart';
import 'package:user_location/user_location.dart';
import 'package:latlong/latlong.dart';

class MapComponent extends StatefulWidget {
  @override
  _MapComponentState createState() {
    return _MapComponentState();
  }
}

Future<Iterable<String>> _loadMock() async {
  String data =
      await rootBundle.loadString('assets/res/bluetooth_receiver_data.txt');

  return LineSplitter.split(data);
}

Marker _buildPlainMarker(LatLng latLng) {
  return new Marker(
    point: latLng,
    width: 60.0,
    height: 55.0,
    anchorPos: AnchorPos.align(AnchorAlign.center),
    builder: (BuildContext context) => const Icon(
      Icons.airplanemode_active,
      size: 60.0,
      color: Colors.red,
    ),
  );
}

Marker _buildStartPointMarker(LatLng latLng) {
  return new Marker(
    point: latLng,
    width: 60.0,
    height: 55.0,
    anchorPos: AnchorPos.align(AnchorAlign.bottom),
    builder: (BuildContext context) => const Icon(
      Icons.flag,
      size: 60.0,
      color: Colors.blue,
    ),
  );
}

class _MapComponentState extends State<MapComponent> {
  Timer mockTimer;
  Timer checkLocationServiceTimer;
  Location location = Location();
  FlightHistory currentFlightHistory;

  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];

  LatLng currentLocation;
  List<LatLng> route;
  double planeDistance = 0;

  bool fixedUserLocation = true;
  bool fixedPlaneLocation = false;
  bool locationServiceEnabled = true;
  bool startMarkerSet = false;

  final double _initFabHeight = 120.0;
  double _fabHeight;
  double _panelHeightOpen;
  double _panelHeightClosed = 95.0;

  bool voltageWarningIsShowing = false;
  Flushbar voltageWarningPopUp = buildVoltageWarningPopup();

  // remove on bluethoot
  TimmerData timmerData;

  PanelController _panelController = new PanelController();

  @override
  void initState() {
    super.initState();
    _fabHeight = _initFabHeight;
    // No info
    currentLocation = LatLng(0, 0);
    route = <LatLng>[LatLng(0, 0), LatLng(0, 0)];
    timmerData = new TimmerData('');
    currentFlightHistory = new FlightHistory();
    currentFlightHistory.start();

    watchLocationEnabled();
    //Mock
    _loadMock().then((data) {
      List<String> lines = data.toList();
      int mockIndex = 0;

      mockTimer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() {
          if (mockIndex == lines.length) {
            mockIndex = 0;
          }
          timmerData = new TimmerData(lines[mockIndex]);
          currentFlightHistory.addData(timmerData);

          if (!startMarkerSet) {
            markers.add(_buildStartPointMarker(timmerData.planePosition));
            startMarkerSet = true;
          }

          route = <LatLng>[timmerData.planePosition, currentLocation];
          planeDistance =
              calculateDistance(timmerData.planePosition, currentLocation);
          mockIndex++;
        });
      });
    });
  }

  void watchLocationEnabled() {
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
  void dispose() {
    super.dispose();
    mockTimer.cancel();
    checkLocationServiceTimer.cancel();
  }

  void batteryWarning(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timmerData.voltageAlert == true && voltageWarningIsShowing == false) {
        voltageWarningIsShowing = true;
        voltageWarningPopUp.show(context);
      } else if (timmerData.voltageAlert == false &&
          voltageWarningPopUp.isShowing()) {
        voltageWarningIsShowing = false;
        voltageWarningPopUp.dismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .5;

    batteryWarning(context);

    void _updatePoints(LatLng postion) {
      setState(() {
        currentLocation = postion;
        route = <LatLng>[timmerData.planePosition, currentLocation];
        if (fixedUserLocation == true) {
          mapController.move(currentLocation, 15.0);
        } else if (fixedPlaneLocation == true) {
          mapController.move(timmerData.planePosition, 15.0);
        }
      });
    }

    userLocationOptions = UserLocationOptions(
        context: context,
        mapController: mapController,
        markers: markers,
        updateMapLocationOnPositionChange: false,
        zoomToCurrentLocationOnLoad: true,
        fabWidth: 70,
        fabHeight: 70,
        fabBottom: _fabHeight,
        moveToCurrentLocationFloatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (locationServiceEnabled) {
              setState(() {
                fixedUserLocation = !fixedUserLocation;
                fixedPlaneLocation = false;
                mapController.move(currentLocation, 15.0);
              });
            } else {
              await location.requestService();
            }
          },
          child: Icon(
            locationServiceEnabled
                ? Icons.my_location
                : Icons.location_disabled,
            color: fixedUserLocation && locationServiceEnabled
                ? Colors.blue
                : Colors.black45,
          ),
          backgroundColor: Colors.white,
        ),
        onLocationUpdate: _updatePoints);

    return ScopedModel<Timmer>(
        model: Timmer(),
        child: ScopedModelDescendant<Timmer>(
            builder: (context, child, model) => Material(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      SlidingUpPanel(
                        controller: _panelController,
                        maxHeight: _panelHeightOpen,
                        minHeight: _panelHeightClosed,
                        parallaxEnabled: true,
                        parallaxOffset: .5,
                        body: _body(),
                        panelBuilder: (sc) => _panel(sc, model),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0)),
                        onPanelSlide: (double pos) => setState(() {
                          _fabHeight = pos *
                                  (_panelHeightOpen -
                                      150 -
                                      _panelHeightClosed) +
                              _initFabHeight;
                        }),
                      ),
                      Positioned(
                          top: 0,
                          child: ClipRRect(
                              child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).padding.top,
                                    color: Colors.transparent,
                                  )))),
                    ],
                  ),
                )));
  }

  Widget _panel(ScrollController sc, Timmer timmer) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 24,
                      width: 10,
                    ),
                    _button(Icons.clear, Colors.black, () {
                      AwesomeDialog(
                          context: context,
                          dialogType: DialogType.INFO,
                          animType: AnimType.BOTTOMSLIDE,
                          tittle: 'Do you want to end the fly?',
                          desc: 'The fly will be saved on your history',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            currentFlightHistory.end();
                            timmer.addFlightHistory(currentFlightHistory);
                            Navigator.pop(context);
                          }).show();
                    }),
                    SizedBox(
                      height: 24,
                      width: 10,
                    ),
                    Text(
                      planeDistance > 1000
                          ? (planeDistance / 1000).toStringAsFixed(2) + ' Km'
                          : planeDistance.toStringAsFixed(2) + ' m',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 25.5,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 24,
                      width: 10,
                    ),
                    new Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _button(Icons.zoom_out_map, Colors.black, () {
                          setState(() {
                            mapController.move(
                                computeCentroid([
                                  timmerData.planePosition,
                                  currentLocation
                                ]),
                                mapController.zoom);
                            if (!mapController.bounds
                                    .contains(timmerData.planePosition) |
                                !mapController.bounds
                                    .contains(currentLocation)) {
                              mapController.bounds
                                  .extend(timmerData.planePosition);
                              mapController.bounds.extend(currentLocation);
                              mapController.fitBounds(mapController.bounds);
                            }
                            fixedPlaneLocation = false;
                            fixedUserLocation = false;
                          });
                        }),
                        SizedBox(
                          height: 24,
                          width: 10,
                        ),
                        _button(Icons.airplanemode_active,
                            fixedPlaneLocation ? Colors.blue : Colors.black45,
                            () {
                          setState(() {
                            fixedUserLocation = false;
                            fixedPlaneLocation = !fixedPlaneLocation;
                            mapController.move(timmerData.planePosition, 15.0);
                          });
                        }),
                        SizedBox(
                          height: 24,
                          width: 10,
                        ),
                      ],
                    ))
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
            MapInfo(timmerData: timmerData)
          ],
        ));
  }

  Widget _button(IconData icon, Color iconColor, onPressed) {
    return ClipOval(
      child: Material(
        shape: CircleBorder(side: BorderSide(color: Colors.black26)),
        color: Colors.white, // button color
        child: InkWell(
          splashColor: Colors.grey, // inkwell color
          child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                icon,
                color: iconColor,
              )),
          onTap: onPressed,
        ),
      ),
    );
  }

  Widget _body() {
    return FlutterMap(
      options: MapOptions(
        interactive: true,
        center: LatLng(0, 0),
        zoom: 15.0,
        plugins: [
          UserLocationPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoibGFyaXMxMiIsImEiOiJjazgzNHBtajcxNWRyM2twZ3NyeTFndDZuIn0.8-PMlKszRh8ixNyP3u2jrA',
            'id': 'mapbox.streets',
          },
        ),
        MarkerLayerOptions(markers: markers),
        new MarkerLayerOptions(
          markers: [_buildPlainMarker(timmerData.planePosition)],
        ),
        PolylineLayerOptions(
          polylines: [
            Polyline(points: route, strokeWidth: 4.0, color: Colors.blue),
          ],
        ),
        userLocationOptions,
      ],
      // ADD THIS
      mapController: mapController,
    );
  }
}
