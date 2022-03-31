import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/duration_box.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/flight_info_box.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';

class FlightExpandibleContent extends ConsumerWidget {
  FlightExpandibleContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                constraints: BoxConstraints(maxHeight: 400),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder<FlightData>(
                    stream: ref.watch(flightDataStreamProvider.stream),
                    builder: (BuildContext context, snapshot) {
                      var flightData = snapshot.data;
                      Widget voltageWidget = FlightInfoBox(
                        data: '?',
                        type: 'Voltage',
                        icon: Icon(
                          Icons.battery_unknown,
                          color: Colors.orangeAccent,
                        ),
                      );

                      if (flightData != null) {
                        voltageWidget = FlightInfoBox(
                          data: flightData.voltage!.toStringAsFixed(2) + 'V',
                          type: 'Voltage',
                          icon: Icon(
                            Icons.battery_full,
                            color: Colors.green.shade300,
                          ),
                        );

                        if (flightData.isConnectedToPlane &&
                            flightData.voltageAlert == true) {
                          voltageWidget = FlightInfoBox(
                            data: flightData.voltage!.toStringAsFixed(2) + 'V!',
                            type: 'Voltage',
                            icon: Icon(
                              Icons.battery_full,
                              color: Colors.red.shade900,
                            ),
                          );
                        }
                      }
                      return ResponsiveGridList(
                        rowMainAxisAlignment: MainAxisAlignment.center,
                        desiredItemWidth: 120,
                        minSpacing: 10,
                        children: [
                          voltageWidget,
                          FlightInfoBox(
                            data: flightData?.temperature != null
                                ? flightData!.temperature!.toStringAsFixed(2) +
                                    'º'
                                : '?',
                            type: 'Temperature',
                            icon: Icon(
                              Icons.ac_unit,
                              color: Colors.blue.shade300,
                            ),
                          ),
                          FlightInfoBox(
                            data: flightData?.pressure != null
                                ? flightData!.pressure!.toStringAsFixed(2) +
                                    'PA'
                                : '?',
                            type: 'Pressure',
                            icon: Icon(
                              Icons.compress,
                              color: Colors.purple.shade300,
                            ),
                          ),
                          FlightInfoBox(
                            data: flightData?.height != null
                                ? distanceToString(flightData!.height!)
                                    .replaceAll(' ', '')
                                : '?',
                            type: 'Height',
                            icon: Icon(
                              Icons.height,
                              color: Colors.lime.shade300,
                            ),
                          ),
                          DurationBox(),
                        ],
                      );
                    }))));
  }
}
