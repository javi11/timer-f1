import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:user_location/user_location.dart';
import 'package:latlong/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timmer',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  double lat = 41.4017;
  Timer _timer;
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  LatLng plainPosition;
  LatLng currentLocation;
  List<LatLng> route;

  @override
  void initState() {
    super.initState();
    plainPosition = LatLng(41.4078, 2.0219);
    currentLocation = LatLng(0, 0);
    route = <LatLng>[plainPosition, currentLocation];
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        lat += 0.0005;
        plainPosition = LatLng(lat, 2.0318);
        route = <LatLng>[plainPosition, currentLocation];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void _updatePoints(LatLng postion) {
      setState(() {
        currentLocation = postion;
        route = <LatLng>[plainPosition, currentLocation];
      });
    }

    Marker _buildMarker(LatLng latLng) {
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

    // You can use the userLocationOptions object to change the properties
    // of UserLocationOptions in runtime
    userLocationOptions = UserLocationOptions(
        context: context,
        mapController: mapController,
        markers: markers,
        updateMapLocationOnPositionChange: true,
        zoomToCurrentLocationOnLoad: true,
        onLocationUpdate: _updatePoints);

    return Scaffold(
        appBar: AppBar(title: Text("GPS Location")),
        body: FlutterMap(
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
            userLocationOptions,
            new MarkerLayerOptions(
              markers: [_buildMarker(plainPosition)],
            ),
            PolylineLayerOptions(
              polylines: [
                Polyline(points: route, strokeWidth: 4.0, color: Colors.blue),
              ],
            ),
          ],
          // ADD THIS
          mapController: mapController,
        ));
  }
}
