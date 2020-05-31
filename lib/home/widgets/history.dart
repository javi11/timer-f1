import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timmer/home/widgets/empty_list.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/models/timmer.dart';

class History extends StatelessWidget {
  final bool Function(ScrollNotification) handleScrollNotification;
  final Function onStartFlight;
  final Timmer timmer;

  History(
      {Key key,
      @required this.timmer,
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

  Widget _listItem(FlightHistory history) {
    String duration = ((history.durationInMs / 1000) / 60).toStringAsFixed(2);
    return Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    child: Icon(Icons.airplanemode_active),
                  ),
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
                      Text(DateTime.fromMillisecondsSinceEpoch(
                              history.startTimestamp)
                          .toString())
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
                  _buildBox('Temperature', Icons.ac_unit,
                      history.maxTemperature.toStringAsFixed(2) + ' º'),
                  SizedBox(
                    height: 24,
                    width: 5,
                  ),
                  _buildBox(
                      'Height',
                      Icons.line_weight,
                      history.maxHeight > 1000
                          ? history.maxHeight.toString() + ' Km'
                          : history.maxHeight.toString() + ' m'),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    Widget view = new ListView.builder(
        itemCount: timmer.flightHistory.length,
        padding: EdgeInsetsDirectional.only(top: 100),
        itemBuilder: (BuildContext ctxt, int index) {
          return _listItem(timmer.flightHistory[index]);
        });

    if (timmer.flightHistory.length == 0) {
      view = EmptyList(
        onStartFlight: onStartFlight,
      );
    }

    return NotificationListener<ScrollNotification>(
        onNotification: handleScrollNotification, child: view);
  }
}
