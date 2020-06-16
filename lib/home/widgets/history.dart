import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timmer/history_detail/history_detail_page.dart';
import 'package:timmer/home/widgets/day_avatar.dart';
import 'package:timmer/home/widgets/empty_list.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/providers/history_provider.dart';
import 'package:timmer/util/display_distance.dart';

class History extends StatelessWidget {
  final bool Function(ScrollNotification) handleScrollNotification;
  final Function onStartFlight;

  History(
      {Key key,
      @required this.handleScrollNotification,
      @required this.onStartFlight})
      : super(key: key);

  Widget _buildBox(String text, IconData icon, String data,
      {Color bgColor = const Color(0x33C8C8C8)}) {
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

  Widget _listItem(FlightHistory history, BuildContext context) {
    String duration = ((history.durationInMs / 1000) / 60).toStringAsFixed(2);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.downToUp,
                child: HistoryDetailPage(flightHistory: history)));
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
                    getDayAvatar(DateTime.fromMillisecondsSinceEpoch(
                            history.startTimestamp)
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
                          'Plane Id: ' + history.planeId,
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(DateFormat('dd-MM-yyyy kk:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                history.startTimestamp)))
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
                        distanceToString(history.maxDistanceFromUser)),
                    SizedBox(
                      height: 24,
                      width: 5,
                    ),
                    _buildBox('Height', Icons.line_weight,
                        distanceToString(history.maxHeight)),
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
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
      Widget view;
      if (historyProvider.isLoading && historyProvider.total == 0) {
        view = Center(
          child: CircularProgressIndicator(),
        );
      } else if (historyProvider.flightHistory.length == 0) {
        view = EmptyList(
          onStartFlight: onStartFlight,
        );
      } else {
        view = ListView.builder(
            physics: BouncingScrollPhysics(),
            itemExtent: 160,
            itemCount: historyProvider.flightHistory.length + 1,
            padding: EdgeInsetsDirectional.only(
                top: MediaQuery.of(context).size.height / 10),
            itemBuilder: (BuildContext ctxt, int index) {
              if (index == historyProvider.flightHistory.length &&
                  historyProvider.isLoading == true) {
                return Center(
                    child: Container(
                  child: CircularProgressIndicator(),
                ));
              }

              if (index == historyProvider.flightHistory.length) {
                return SizedBox(
                  width: 0,
                  height: 0,
                );
              }
              return _listItem(historyProvider.flightHistory[index], context);
            });
      }

      return NotificationListener<ScrollNotification>(
          onNotification: handleScrollNotification, child: view);
    });
  }
}
