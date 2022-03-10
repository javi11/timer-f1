import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/flight_history/controllers/flight_history_controller.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/day_avatar.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/empty_list.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';

class History extends ConsumerWidget {
  final Function onStartFlight;

  History({Key? key, required this.onStartFlight}) : super(key: key);

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

  Widget _listItem(Flight history, BuildContext context) {
    String duration = ((history.durationInMs! / 1000) / 60).toStringAsFixed(2);
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(Routes.FLIGHT_DETAIL, extra: history);
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
                    if (history.startTimestamp != null)
                      getDayAvatar(DateTime.fromMillisecondsSinceEpoch(
                              history.startTimestamp!)
                          .weekday),
                    SizedBox(
                      height: 24,
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Plane Id: ' + history.planeId!,
                          style: TextStyle(fontSize: 18),
                        ),
                        if (history.startTimestamp != null)
                          Text(DateFormat('dd-MM-yyyy kk:mm:ss').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  history.startTimestamp!)))
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
                        distanceToString(history.maxPlaneDistanceFromUser!)),
                    SizedBox(
                      height: 24,
                      width: 5,
                    ),
                    _buildBox('Height', Icons.line_weight,
                        distanceToString(history.maxHeight!)),
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

    if (provider.flightHistory.isEmpty) {
      return EmptyList(
        onStartFlight: onStartFlight,
      );
    }

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
