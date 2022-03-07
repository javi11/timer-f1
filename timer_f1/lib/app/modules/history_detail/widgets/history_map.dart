import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/data/providers/tile_provider.dart';
import 'package:timer_f1/core/utils/compute_centroid.dart';
import 'package:timer_f1/global_widgets/plain_finish_point_marker.dart';
import 'package:timer_f1/global_widgets/plane_starting_flag_marker.dart';

void useConfigureMap(
    BuildContext context, MapController mapController, Flight flight) {
  useEffect(() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      LatLng? flightStartCoordinates = flight.flightStartCoordinates;
      LatLng? farPlaneDistanceCoordinates = flight.farPlaneDistanceCoordinates;

      if (flightStartCoordinates != null &&
          farPlaneDistanceCoordinates != null &&
          (!mapController.bounds!.contains(flightStartCoordinates) ||
              !mapController.bounds!.contains(farPlaneDistanceCoordinates))) {
        mapController.bounds!.extend(flightStartCoordinates);
        mapController.bounds!.extend(farPlaneDistanceCoordinates);
        mapController.fitBounds(mapController!.bounds!,
            options: FitBoundsOptions(padding: EdgeInsets.all(100)));
      } else {
        mapController.fitBounds(mapController.bounds!,
            options: FitBoundsOptions(padding: EdgeInsets.all(100)));
      }
    });
  }, [flight]);
}

ValueNotifier<List<Marker>> useMarkers(BuildContext context, Flight flight) {
  var markers = useState<List<Marker>>([]);
  if (flight.flightStartCoordinates == null) {
    markers.value = [
      ...markers.value,
      buildPlainFinishPointMarker(flight.flightEndCoordinates!)
    ];
  } else if (flight.flightEndCoordinates == null) {
    markers.value = [
      ...markers.value,
      buildPlaneStartingFlagMarker(flight.flightStartCoordinates!)
    ];
  } else {
    markers.value = [
      ...markers.value,
      buildPlaneStartingFlagMarker(flight.flightStartCoordinates!),
      buildPlainFinishPointMarker(flight.flightEndCoordinates!)
    ];
  }

  return markers;
}

ValueNotifier<LatLng?> useCentroid(BuildContext context, Flight flight) {
  var centroid = useState<LatLng?>(null);
  if (flight.flightStartCoordinates == null) {
    centroid.value = flight.flightEndCoordinates;
  } else if (flight.flightEndCoordinates == null) {
    centroid.value = flight.flightStartCoordinates;
  } else {
    centroid.value = computeCentroid(
        [flight.flightStartCoordinates, flight.flightEndCoordinates]);
  }

  return centroid;
}

class HistoryMap extends HookConsumerWidget {
  final Flight flight;
  final MapController mapController = MapController();
  late List<LatLng?> route;

  HistoryMap({required this.flight});

  Widget build(BuildContext context, WidgetRef ref) {
    useConfigureMap(context, mapController, flight);
    var route = useState<List<LatLng>>(flight.flightData
        .where((element) => element.planeCoordinates != null)
        .map((e) => e.planeCoordinates!)
        .toList());
    var markers = useMarkers(context, flight);
    var centroid = useCentroid(context, flight);

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
                zoom: 30,
                interactiveFlags: InteractiveFlag.all,
                center: centroid.value),
            children: [
              TileLayerWidget(
                  options: TileLayerOptions(
                      tileProvider: ref.watch(tileProvider),
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'])),
            ],
            layers: [
              MarkerLayerOptions(markers: markers.value),
              if (route.value.isNotEmpty)
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: route.value,
                        strokeWidth: 6.0,
                        color: Colors.blue,
                        isDotted: true),
                  ],
                ),
            ]));
  }
}
