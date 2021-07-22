import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:timerf1c/models/flight_history.dart';
import 'package:timerf1c/util/compute_centroid.dart';
import 'package:timerf1c/providers/map_provider.dart';
import 'package:timerf1c/widgets/plain_end_point_marker.dart';
import 'package:timerf1c/widgets/plain_starting_point_marker.dart';

class HistoryMap extends StatefulWidget {
  final FlightHistory flightHistory;

  HistoryMap({Key? key, required this.flightHistory}) : super(key: key);
  @override
  _HistoryMapState createState() => _HistoryMapState();
}

class _HistoryMapState extends State<HistoryMap> {
  MapController? mapController;
  late List<LatLng?> route;

  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      LatLng? flightStartCoordinates =
          widget.flightHistory.flightStartCoordinates;
      LatLng? farPlaneDistanceCoordinates =
          widget.flightHistory.farPlaneDistanceCoordinates;

      if (flightStartCoordinates != null &&
          farPlaneDistanceCoordinates != null &&
          (!mapController!.bounds!.contains(flightStartCoordinates) ||
              !mapController!.bounds!.contains(farPlaneDistanceCoordinates))) {
        setState(() {
          mapController!.bounds!.extend(flightStartCoordinates);
          mapController!.bounds!.extend(farPlaneDistanceCoordinates);
          mapController!.fitBounds(mapController!.bounds!,
              options: FitBoundsOptions(padding: EdgeInsets.all(100)));
        });
      } else {
        setState(() {
          mapController!.fitBounds(mapController!.bounds!,
              options: FitBoundsOptions(padding: EdgeInsets.all(100)));
        });
      }
    });

    setState(() {
      route = widget.flightHistory.flightData
          .where((element) => element.planeCoordinates != null)
          .map((e) => e.planeCoordinates)
          .toList();
    });
  }

  Widget build(BuildContext context) {
    LatLng? centroid;
    LatLng? flightStartCoordinates =
        widget.flightHistory.flightStartCoordinates;
    LatLng? flightEndCoordinates = widget.flightHistory.flightEndCoordinates;
    List<Marker> markers = [];

    if (flightStartCoordinates == null && flightEndCoordinates == null) {
      return Container(
          child: Center(
        child: Text(
          'No plain data',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ));
    }

    if (flightStartCoordinates == null) {
      markers.add(buildPlainEndPointMarker(flightEndCoordinates!));
      centroid = flightEndCoordinates;
    } else if (flightEndCoordinates == null) {
      markers.add(buildPlainStartingPointMarker(flightStartCoordinates));
      centroid = flightStartCoordinates;
    } else {
      markers.add(buildPlainStartingPointMarker(flightStartCoordinates));
      markers.add(buildPlainEndPointMarker(flightEndCoordinates));
      centroid =
          computeCentroid([flightStartCoordinates, flightEndCoordinates]);
    }

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
                zoom: 30,
                interactiveFlags: InteractiveFlag.all,
                center: centroid),
            children: [
              mapProvider
            ],
            layers: [
              MarkerLayerOptions(markers: markers),
              PolylineLayerOptions(
                polylines: [
                  Polyline(
                      points: route as List<LatLng>,
                      strokeWidth: 6.0,
                      color: Colors.blue,
                      isDotted: true),
                ],
              ),
            ]));
  }
}
