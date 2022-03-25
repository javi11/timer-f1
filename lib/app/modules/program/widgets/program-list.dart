import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/flight_history/controllers/flight_history_controller.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/empty_history.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';

class ProgramList extends ConsumerWidget {
  ProgramList({Key? key}) : super(key: key);

  Widget _buildBox(String text, IconData icon, String data) {
    return Container(
      height: 80,
      width: 90,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon),
            Text(text),
            Text(data),
          ]),
    );
  }

  Widget _listItem(Flight flight, BuildContext context) {
    String duration = ((flight.durationInMs! / 1000) / 60).toStringAsFixed(2);
    return InkWell(
      onTap: () {
        GoRouter.of(context)
            .push(Routes.HOME + Routes.FLIGHT_DETAILS, extra: flight);
      },
      // inkwell color
      child: Card(
          margin: EdgeInsets.all(10),
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      height: 24,
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Plane Id: ' + flight.planeId!,
                          style: TextStyle(fontSize: 18),
                        ),
                        if (flight.startTimestamp != null)
                          Text(DateFormat('dd-MM-yyyy kk:mm:ss').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  flight.startTimestamp!)))
                      ],
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 24,
                      width: 5,
                    ),
                    _buildBox('Distance', Icons.transfer_within_a_station,
                        distanceToString(flight.maxPlaneDistanceFromUser!)),
                    SizedBox(
                      height: 24,
                      width: 5,
                    ),
                    _buildBox('Height', Icons.line_weight,
                        distanceToString(flight.maxHeight!)),
                    SizedBox(
                      height: 24,
                      width: 5,
                    ),
                    _buildBox('Duration', Icons.timelapse, duration + '\''),
                    SizedBox(
                      height: 24,
                      width: 5,
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var provider = ref.watch(flightHistoryControllerProvider);

    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemExtent: 160,
        itemCount: provider.flightHistory.length,
        padding: EdgeInsetsDirectional.only(
            top: MediaQuery.of(context).size.height / 10),
        itemBuilder: (BuildContext ctx, int index) =>
            _listItem(provider.flightHistory[index], context));
  }
}
