import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timerf1c/home/widgets/clipped_parts.dart';
import 'package:timerf1c/home/widgets/drawer.dart';
import 'package:timerf1c/home/widgets/history.dart';
import 'package:timerf1c/providers/history_provider.dart';
import 'package:timerf1c/tracking/tracking_page.dart';
import 'package:timerf1c/widgets/app_title.dart';
import 'package:timerf1c/widgets/map_provider.dart';
import 'package:latlong2/latlong.dart';

class DownloadMapRegionPage extends StatefulWidget {
  DownloadMapRegionPage({Key key}) : super(key: key);
  @override
  _DownloadMapRegionPageState createState() => _DownloadMapRegionPageState();
}

double squareNorthThreshold = 0.001;
double squareSouthThreshold = 0.0025;

class _DownloadMapRegionPageState extends State<DownloadMapRegionPage> {
  MapController mapController;
  StreamController<double> _centerCurrentLocationStreamController;
  CenterOnLocationUpdate _centerOnLocationUpdate;
  LatLngBounds _selectedBoundsSqr;
  StreamSubscription<MapEvent> _mapEventListener;

  _drawDownloadArea() {
    double south = mapController.bounds.south > 0
        ? mapController.bounds.south + squareSouthThreshold
        : mapController.bounds.south - squareSouthThreshold;
    double north = mapController.bounds.north > 0
        ? mapController.bounds.north - squareNorthThreshold
        : mapController.bounds.north + squareNorthThreshold;
    double west = mapController.bounds.west > 0
        ? mapController.bounds.west + squareNorthThreshold
        : mapController.bounds.west - squareNorthThreshold;
    double east = mapController.bounds.east > 0
        ? mapController.bounds.east - squareNorthThreshold
        : mapController.bounds.east + squareNorthThreshold;

    final sw = LatLng(south, west);
    final ne = LatLng(north, east);
    setState(() {
      _selectedBoundsSqr = LatLngBounds(sw, ne);
    });
  }

  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.first;
    _centerCurrentLocationStreamController = StreamController<double>();
    mapController = MapController();

    _mapEventListener = mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        _drawDownloadArea();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _mapEventListener.cancel();
    _centerCurrentLocationStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    // Do not allow rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    LocationMarkerPlugin locationMarkerPlugin = LocationMarkerPlugin(
      centerCurrentLocationStream:
          _centerCurrentLocationStreamController.stream,
      centerOnLocationUpdate: _centerOnLocationUpdate,
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          centerTitle: true,
          title: Text('Download map region'),
          automaticallyImplyLeading: true,
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 140,
            child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  zoom: 15.0,
                  interactiveFlags: InteractiveFlag.all,
                ),
                children: [
                  mapProvider,
                  LocationMarkerLayerWidget(
                    plugin: locationMarkerPlugin,
                    options: LocationMarkerLayerOptions(
                        showAccuracyCircle: true, showHeadingSector: true),
                  ),
                ],
                layers: [
                  _selectedBoundsSqr == null
                      ? PolygonLayerOptions()
                      : RectangleRegion(_selectedBoundsSqr).toDrawable(
                          Colors.green.withAlpha(128),
                          Colors.green,
                        )
                ])));
  }
}
