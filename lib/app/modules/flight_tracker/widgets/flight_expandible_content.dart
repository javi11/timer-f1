import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:timer_f1/app/data/models/flight_data_model.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';

Widget _buildBox(String text, IconData icon, String data,
    {Color? bgColor = const Color(0x33C8C8C8)}) {
  return Container(
    height: 120,
    child:
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Icon(icon),
      Text(text),
      Text(data),
    ]),
    decoration: BoxDecoration(
      color: bgColor,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
  );
}

class EmptyFlightData extends Container {
  @override
  Widget build(BuildContext context) {
    return ResponsiveGridList(
      desiredItemWidth: 120,
      minSpacing: 10,
      children: [
        _buildBox('Voltage', Icons.battery_unknown, 'Waiting for data...',
            bgColor: Colors.orange[300]),
        _buildBox('Temperature', Icons.ac_unit, '?'),
        _buildBox('Pressure', Icons.av_timer, '?'),
        _buildBox('Height', Icons.line_weight, '?'),
      ],
    );
  }
}

class FlightExpandibleContent extends ConsumerWidget {
  FlightExpandibleContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: EdgeInsetsDirectional.only(bottom: 10),
        child: Card(
            elevation: 10,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                constraints: BoxConstraints(maxHeight: 400),
                padding: EdgeInsets.all(10),
                child: StreamBuilder<FlightData>(
                    stream: ref.watch(flightDataStreamProvider.stream),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        var flightData = snapshot.data!;
                        Widget voltageWidget = _buildBox(
                            'Voltage',
                            Icons.battery_full,
                            flightData.voltage!.toStringAsFixed(2) + ' V');

                        if (flightData.isConnectedToPlane &&
                            flightData.voltageAlert == true) {
                          voltageWidget = _buildBox(
                              'Voltage',
                              Icons.battery_alert,
                              flightData.voltage!.toStringAsFixed(2) + ' V',
                              bgColor: const Color(0x8Cba122b));
                        }
                        return ResponsiveGridList(
                          desiredItemWidth: 120,
                          minSpacing: 10,
                          children: [
                            voltageWidget,
                            _buildBox(
                                'Temperature',
                                Icons.ac_unit,
                                flightData.temperature != null
                                    ? flightData.temperature!
                                            .toStringAsFixed(2) +
                                        ' º'
                                    : '?'),
                            _buildBox(
                                'Pressure',
                                Icons.av_timer,
                                flightData.pressure != null
                                    ? flightData.pressure!.toStringAsFixed(2) +
                                        ' PA'
                                    : '?'),
                            _buildBox(
                                'Height',
                                Icons.line_weight,
                                flightData.height != null
                                    ? distanceToString(flightData.height!)
                                    : '?'),
                          ],
                        );
                      } else {
                        return EmptyFlightData();
                      }
                    }))));
  }
}
