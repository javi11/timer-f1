import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/flight_history/controllers/flight_history_controller.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/empty_history.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/core/utils/date_title_formater.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';

class History extends ConsumerWidget {
  final Function onStartFlight;
  final DateFormat hourFormatter = DateFormat('HH:mm');

  History({Key? key, required this.onStartFlight}) : super(key: key);

  Widget _buildBox(String text, IconData icon, String data) {
    return Container(
      height: 80,
      width: 60,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.indigo,
            ),
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            Text(
              data,
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ]),
    );
  }

  Widget _listItem(Flight flight, BuildContext context) {
    String startHour = hourFormatter
        .format(DateTime.fromMillisecondsSinceEpoch(flight.startTimestamp!));
    String endHour = hourFormatter
        .format(DateTime.fromMillisecondsSinceEpoch(flight.endTimestamp!));

    return Container(
        child: InkWell(
      onTap: () {
        GoRouter.of(context)
            .push(Routes.HOME + Routes.FLIGHT_DETAILS, extra: flight);
      },
      // inkwell color
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 5,
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: <Widget>[
                  Text(
                    'Plain ${flight.planeId}',
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  Wrap(spacing: 7, children: [
                    Text(startHour,
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 20)),
                    Icon(Icons.arrow_right_alt, color: Colors.grey[600]),
                    Text(endHour,
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 20))
                  ]),
                  Text(
                    flight.flightAddress!,
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildBox('Distance', Icons.transfer_within_a_station,
                      distanceToString(flight.maxPlaneDistanceFromUser!)),
                  _buildBox('Height', Icons.line_weight,
                      distanceToString(flight.maxHeight!)),
                ],
              )
            ],
          ))),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var provider = ref.watch(flightHistoryControllerProvider);

    if (provider.flightHistory.isEmpty) {
      return EmptyHistory(
        onStartFlight: onStartFlight,
      );
    }

    return GroupedListView(
        itemComparator: (Flight element1, Flight element2) =>
            element1.startTimestamp! > element2.startTimestamp! ? -1 : 1,
        elements: provider.flightHistory.toList(),
        groupBy: (Flight flight) {
          DateTime date =
              DateTime.fromMillisecondsSinceEpoch(flight.startTimestamp!);

          return dateTitleFormatter(date);
        },
        useStickyGroupSeparators: true,
        stickyHeaderBackgroundColor: Colors.white,
        groupSeparatorBuilder: (String title) => Wrap(children: [
              Divider(
                thickness: 8,
                color: Colors.grey[100],
              ),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )),
            ]),
        separator: Divider(
          thickness: 2,
          color: Colors.grey[100],
        ),
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext ctx, Flight flight) =>
            _listItem(flight, context));
  }
}
