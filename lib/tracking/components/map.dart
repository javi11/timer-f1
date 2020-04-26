import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart';
import 'package:timmer/models/timmer.dart';
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
    anchorPos: AnchorPos.align(AnchorAlign.top),
    builder: (BuildContext context) => const Icon(
      Icons.airplanemode_active,
      size: 60.0,
      color: Colors.red,
    ),
  );
}

class _MapComponentState extends State<MapComponent> {
  Timer mockTimer;
  Timer checkLocationServiceTimer;
  Location location = Location();

  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  LatLng currentLocation;
  LatLng plainPosition;
  List<LatLng> route;
  double planeDistance = 0;
  double planeTemperature = 0;
  double planeHeight = 0;
  double planePressure = 0;
  bool fixedLocation = true;
  bool locationServiceEnabled = true;

  @override
  void initState() {
    super.initState();

    plainPosition = LatLng(0, 0);
    currentLocation = LatLng(0, 0);
    route = <LatLng>[plainPosition, currentLocation];
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
          TimmerParser line = new TimmerParser(lines[mockIndex]);
          plainPosition = line.position;
          route = <LatLng>[plainPosition, currentLocation];
          planeTemperature = line.temperature;
          planePressure = line.pressure;
          planeHeight = line.height;
          planeDistance = calculateDistance(plainPosition, currentLocation);
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

  @override
  Widget build(BuildContext context) {
    void _updatePoints(LatLng postion) {
      setState(() {
        currentLocation = postion;
        route = <LatLng>[plainPosition, currentLocation];
        if (fixedLocation == true) {
          mapController.move(currentLocation, 15.0);
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
        moveToCurrentLocationFloatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (locationServiceEnabled) {
              setState(() {
                fixedLocation = !fixedLocation;
              });
            } else {
              await location.requestService();
            }
          },
          child: Icon(
            locationServiceEnabled
                ? Icons.my_location
                : Icons.location_disabled,
            color: fixedLocation && locationServiceEnabled
                ? Colors.blue
                : Colors.black45,
          ),
          backgroundColor: Colors.white,
        ),
        onLocationUpdate: _updatePoints);

    return Stack(
      children: <Widget>[
        FlutterMap(
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
              markers: [_buildPlainMarker(plainPosition)],
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
        ),
        Positioned(
          bottom: 22,
          left: 22,
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180.0),
              child: new Opacity(
                  opacity: 0.8,
                  child: Card(
                    child: ListTile(
                      title: Text(planeDistance > 1000
                          ? (planeDistance / 1000).toStringAsFixed(2) + ' Km'
                          : planeDistance.toStringAsFixed(2) + ' m'),
                      trailing: Icon(Icons.near_me),
                    ),
                  ))),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: DropdownButton<String>(
    icon: Icon(Icons.arrow_downward),
    iconSize: 24,
    elevation: 16,
    style: TextStyle(
      color: Colors.deepPurple
    ),
    underline: Container(
      height: 2,
      color: Colors.deepPurpleAccent,
    ),
    items: <Widget>[new ListTile(
                            title: Text(planeTemperature.toString() + ' ºC'),
                            trailing: Icon(Icons.ac_unit),
                          ), new ListTile(
                            title: Text(planeHeight.toString() + ' m'),
                            trailing: Icon(Icons.line_weight),
                          ), new ListTile(
                            title: Text(planePressure.toString() + ' Pa'),
                            trailing: Icon(Icons.trending_up),
                          ),
                        )],
  );
            
            ),
      ],
    );
  }
}
