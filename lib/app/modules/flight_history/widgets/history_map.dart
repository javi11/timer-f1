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

ValueNotifier<List<Marker>> useMarkers({required Flight flight}) {
  var markers = useState<List<Marker>>([]);
  useEffect(() {
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
    return null;
  }, [flight.flightStartCoordinates, flight.flightEndCoordinates]);

  return markers;
}

ValueNotifier<LatLng?> useCentroid({required Flight flight}) {
  var centroid = useState<LatLng?>(null);
  useEffect(() {
    if (flight.flightStartCoordinates == null) {
      centroid.value = flight.flightEndCoordinates;
    } else if (flight.flightEndCoordinates == null) {
      centroid.value = flight.flightStartCoordinates;
    } else {
      centroid.value = computeCentroid(
          [flight.flightStartCoordinates, flight.flightEndCoordinates]);
    }

    return null;
  }, [flight.flightStartCoordinates, flight.flightEndCoordinates]);

  return centroid;
}

MapController useMapController({required Flight flight}) {
  final controller = useMemoized(() => MapController());
  useEffect(() {
    controller.onReady.then((_) {
      LatLng? flightStartCoordinates = flight.flightStartCoordinates;
      LatLng? farPlaneDistanceCoordinates = flight.farPlaneDistanceCoordinates;

      if (flightStartCoordinates != null &&
          farPlaneDistanceCoordinates != null &&
          (!controller.bounds!.contains(flightStartCoordinates) ||
              !controller.bounds!.contains(farPlaneDistanceCoordinates))) {
        controller.bounds!.extend(flightStartCoordinates);
        controller.bounds!.extend(farPlaneDistanceCoordinates);
        controller.fitBounds(controller.bounds!,
            options: FitBoundsOptions(padding: EdgeInsets.all(100)));
      } else {
        controller.fitBounds(controller.bounds!,
            options: FitBoundsOptions(padding: EdgeInsets.all(100)));
      }
    });

    return null;
  }, [flight, controller]);

  return controller;
}

class HistoryMap extends HookConsumerWidget {
  final Flight flight;

  HistoryMap({required this.flight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mapController = useMapController(flight: flight);
    var route = useState<List<LatLng>>(flight.flightData
        .where((element) => element.planeCoordinates != null)
        .map((e) => e.planeCoordinates!)
        .toList());
    var markers = useMarkers(flight: flight);
    var centroid = useCentroid(flight: flight);

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
