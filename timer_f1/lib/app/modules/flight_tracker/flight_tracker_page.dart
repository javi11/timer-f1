import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/data/models/enums/fixed_location.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_tracker_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/bottom_bar.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/flight_expandible_content.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/tracking_map.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/voltage_indicator.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/waiting_for_timer_data.dart';

void useNoDataPopup(BuildContext context, WidgetRef ref) {
  var flightHasStarted = ref.watch<bool>(
      flightProvider.select((value) => value.startTimestamp != null));
  var device = ref.watch<Device?>(
      bleControllerProvider.select((value) => value.connectedDevice));
  var isNoDataDialogDisplayed = useState(true);
  useEffect(() {
    if (flightHasStarted == false && isNoDataDialogDisplayed.value == true) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        isNoDataDialogDisplayed.value = false;
        await showDialog(
            context: context,
            builder: (ctx) => WaitingForData(
                hasFlightStarted: flightHasStarted, device: device),
            barrierDismissible: false);
      });
    } else if (flightHasStarted == true &&
        isNoDataDialogDisplayed.value == false) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        Navigator.of(context, rootNavigator: true).pop();
      });
    }
  }, [flightHasStarted, device]);
}

class FlightTrackerPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(flightControllerProvider);
    useNoDataPopup(context, ref);
    return Scaffold(
        body: ExpandableBottomSheet(
      key: controller.expandibleKey,
      expandableContent: FlightExpandibleContent(),
      persistentHeader: BottomBar(
        onExit: () => controller.onExit(context),
        onZoom: () => controller.onZoom(
            ref.read(flightDataStreamProvider).value?.planeCoordinates,
            ref.read(flightDataStreamProvider).value?.userCoordinates),
        onMoreInfo: controller.onMoreInfo,
        expanded:
            ref.watch(expandibleToggleSelector) == ExpansionStatus.expanded,
      ),
      background: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          TrackingMap(),
          Positioned(
              height: 60,
              width: 60,
              bottom: 210,
              right: 8,
              child: FloatingActionButton(
                heroTag: 'planeLocation',
                onPressed: () => controller.onFixPlane(
                    ref.read(flightDataStreamProvider).value?.planeCoordinates),
                child: Icon(
                  Icons.airplanemode_active,
                  color: ref.watch(focusedOnSelector) ==
                          FixedLocation.planeLocation
                      ? Colors.blue
                      : Colors.black45,
                ),
                backgroundColor: Colors.white,
              )),
          Positioned(
              height: 60,
              width: 60,
              bottom: 140,
              right: 8,
              child: FloatingActionButton(
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
                      ? Colors.blue
                      : Colors.black45,
                ),
                backgroundColor: Colors.white,
              )),
          Padding(
              padding: EdgeInsetsDirectional.only(top: 30, end: 5, start: 5),
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blue[400],
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
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  ref.watch(flightDataStreamProvider.select(
                                          (value) => value.value?.planeId)) ??
                                      '?',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
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
                                Consumer(builder: (context, ref, child) {
                                  var bluetoothState = ref.watch(
                                      bleControllerProvider.select(
                                          (value) => value.bluetoothState));
                                  if (bluetoothState ==
                                      BluetoothState.connected) {
                                    return CircleAvatar(
                                      child: Icon(Icons.bluetooth_connected,
                                          color: Colors.white),
                                    );
                                  }

                                  if (bluetoothState ==
                                      BluetoothState.connecting) {
                                    return CircleAvatar(
                                      backgroundColor: Colors.orangeAccent,
                                      child: Icon(Icons.bluetooth_searching,
                                          color: Colors.white),
                                    );
                                  }

                                  return InkWell(
                                    onTap: () async {
                                      await ref
                                          .read(flightControllerProvider)
                                          .onReConnect(ref
                                              .read(bleControllerProvider)
                                              .pairedDevice!);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.redAccent,
                                      child: Icon(
                                        Icons.bluetooth_disabled,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                })
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
