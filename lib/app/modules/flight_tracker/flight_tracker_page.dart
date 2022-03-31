import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/enums/fixed_location.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_tracker_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/hooks/waiting_for_data_hook.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/bottom_bar.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/connection_status.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/flight_expandible_content.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/tracking_map.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/voltage_indicator.dart';

class FlightTrackerPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var controller = ref.watch(flightControllerProvider);
    useWaitingForData(ref: ref);

    return Scaffold(
        body: ExpandableBottomSheet(
      key: controller.expandibleKey,
      expandableContent: FlightExpandibleContent(),
      persistentHeader: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    direction: Axis.vertical,
                    children: [
                      FloatingActionButton(
                        heroTag: 'planeLocation',
                        onPressed: () => controller.onFixPlane(ref
                            .read(flightDataStreamProvider)
                            .value
                            ?.planeCoordinates),
                        child: Icon(
                          Icons.airplanemode_active,
                          color: ref.watch(focusedOnSelector) ==
                                  FixedLocation.planeLocation
                              ? Colors.indigo
                              : Colors.black45,
                        ),
                        backgroundColor: Colors.white,
                      ),
                      FloatingActionButton(
                        heroTag: 'userLocation',
                        onPressed: () async => await ref
                            .read(flightControllerProvider)
                            .onPressUserLocation(ref
                                .read(flightDataStreamProvider)
                                .value
                                ?.userCoordinates),
                        child: Icon(
                          ref.watch(locationServiceEnabledSelector)
                              ? Icons.my_location
                              : Icons.location_disabled,
                          color: ref.watch(focusedOnSelector) ==
                                      FixedLocation.userLocation &&
                                  ref.watch(locationServiceEnabledSelector)
                              ? Colors.indigo
                              : Colors.black45,
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ],
                  )
                ]),
                SizedBox(
                  height: 20,
                ),
                BottomBar(
                  onExit: () => controller.onExit(context),
                  onZoom: () => controller.onZoom(
                      ref
                          .read(flightDataStreamProvider)
                          .value
                          ?.planeCoordinates,
                      ref
                          .read(flightDataStreamProvider)
                          .value
                          ?.userCoordinates),
                  onMoreInfo: controller.onMoreInfo,
                  expanded: ref.watch(expandibleToggleSelector) ==
                      ExpansionStatus.expanded,
                )
              ])),
      background: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          TrackingMap(),
          Padding(
              padding: EdgeInsetsDirectional.only(top: 30, end: 5, start: 5),
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
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
                                  backgroundColor: Colors.indigo,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  ref.watch(flightDataStreamProvider.select(
                                          (value) => value.value?.planeId)) ??
                                      '?',
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                VoltageIndicator(
                                    voltageAlert: ref.watch(
                                            flightDataStreamProvider.select(
                                                (value) => value
                                                    .value?.voltageAlert)) ??
                                        false,
                                    voltage: ref.watch(
                                        flightDataStreamProvider.select(
                                            (value) => value.value?.voltage))),
                                SizedBox(
                                  width: 10,
                                ),
                                ConnectionStatusCircle()
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
