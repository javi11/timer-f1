import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';
import 'package:timer_f1/app/data/providers/tile_provider.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_tracker_controller.dart';
import 'package:timer_f1/global_widgets/plane_marker.dart';
import 'package:timer_f1/global_widgets/plane_starting_flag_marker.dart';

class EmptyMarker extends Container {
  @override
  Widget build(BuildContext context) {
    return MarkerLayerWidget(
      options: MarkerLayerOptions(
        markers: [],
      ),
    );
  }
}

class TrackingMap extends ConsumerWidget {
  final List<Polygon> polylines = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlutterMap(
      options: MapOptions(
          interactiveFlags: InteractiveFlag.all,
          center: LatLng(0, 0),
          zoom: 15.0),
      children: [
        TileLayerWidget(
            options: TileLayerOptions(
                tileProvider: ref.watch(tileProvider),
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'])),
        StreamBuilder<FlightData>(
            stream: ref.watch(flightDataStreamProvider.stream),
            builder: (context, snapshot) => snapshot.hasData
                ? MarkerLayerWidget(
                    options: MarkerLayerOptions(
                      markers: [
                        if (snapshot.data!.planeCoordinates != null)
                          buildPlaneMarker(snapshot.data!.planeCoordinates!),
                        if (snapshot.data!.isInitial == true)
                          buildPlaneStartingFlagMarker(
                              snapshot.data!.planeCoordinates!)
                      ],
                    ),
                  )
                : EmptyMarker()),
        StreamBuilder<FlightData>(
            stream: ref.watch(flightDataStreamProvider.stream),
            builder: (context, snapshot) =>
                snapshot.hasData && snapshot.data!.route != null
                    ? PolygonLayerWidget(
                        options: PolygonLayerOptions(
                          polygons: [
                            Polygon(
                                points: snapshot.data!.route!,
                                borderStrokeWidth: 4.0,
                                color: Colors.blue)
                          ],
                        ),
                      )
                    : EmptyMarker()),
        LocationMarkerLayerWidget(
          plugin: LocationMarkerPlugin(
              centerOnLocationUpdate:
                  ref.watch(centerOnLocationUpdateSelector)),
          options: LocationMarkerLayerOptions(
              showAccuracyCircle: true, showHeadingSector: true),
        ),
      ],
      mapController: ref.watch(
          flightControllerProvider.select((value) => value.mapController)),
    );
  }
}
