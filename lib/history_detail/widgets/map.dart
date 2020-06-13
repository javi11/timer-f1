import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/util/compute_centroid.dart';
import 'package:timmer/widgets/plain_end_point_marker.dart';
import 'package:timmer/widgets/plain_starting_point_marker.dart';

class HistoryMap extends StatefulWidget {
  final FlightHistory flightHistory;

  HistoryMap({Key key, @required this.flightHistory}) : super(key: key);
  @override
  _HistoryMapState createState() => _HistoryMapState();
}

class _HistoryMapState extends State<HistoryMap> {
  MapController mapController;
  List<LatLng> route;

  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LatLng planeStartCoordinates =
          widget.flightHistory.flightData.first.planeCoordinates;
      LatLng planeFarCoordinates = widget.flightHistory.farCoordinates;

      if (!mapController.bounds.contains(planeStartCoordinates) |
          !mapController.bounds.contains(planeFarCoordinates)) {
        setState(() {
          mapController.bounds.extend(planeStartCoordinates);
          mapController.bounds.extend(planeFarCoordinates);
          mapController.fitBounds(mapController.bounds,
              options: FitBoundsOptions(padding: EdgeInsets.all(100)));
        });
      }
    });

    setState(() {
      route = widget.flightHistory.flightData
          .map((e) => e.planeCoordinates)
          .toList();
    });
  }

  Widget build(BuildContext context) {
    List<Marker> markers = [
      buildPlainStartingPointMarker(
          widget.flightHistory.flightData.first.planeCoordinates),
      buildPlainEndPointMarker(
          widget.flightHistory.flightData.last.planeCoordinates)
    ];

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
                zoom: 30.0,
                interactive: true,
                center: computeCentroid([
                  widget.flightHistory.flightData.first.planeCoordinates,
                  widget.flightHistory.flightData.last.planeCoordinates
                ])),
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
              PolylineLayerOptions(
                polylines: [
                  Polyline(
                      points: route,
                      strokeWidth: 6.0,
                      color: Colors.blue,
                      isDotted: true),
                ],
              ),
            ]));
  }
}
