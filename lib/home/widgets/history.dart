import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/models/timmer.dart';

class History extends StatelessWidget {
  History({Key key}) : super(key: key);

  Widget _listItem(FlightHistory history) {
    return Card(
      child: Text(history.planeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Timmer>(
        model: Timmer(),
        child: ScopedModelDescendant<Timmer>(builder: (context, child, model) {
          if (model.flightHistory.length == 0) {
            return Container();
          }
          List<TimelineModel> items = model.flightHistory.map((e) =>
              TimelineModel(_listItem(e),
                  position: TimelineItemPosition.random,
                  iconBackground: Colors.redAccent,
                  icon: Icon(Icons.blur_circular)));

          return Timeline(children: items, position: TimelinePosition.Center);
        }));
  }
}
