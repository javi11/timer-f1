import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timmer/history_detail/widgets/history_map.dart';
import 'package:timmer/models/flight_history.dart';
import 'package:timmer/util/display_distance.dart';
import 'package:timmer/util/export_csv.dart';

class HistoryDetailPage extends StatefulWidget {
  final FlightHistory flightHistory;
  HistoryDetailPage({Key key, @required this.flightHistory}) : super(key: key);
  @override
  _HistoryDetailPageState createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Do not allow rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    String duration =
        ((widget.flightHistory.durationInMs / 1000) / 60).toStringAsFixed(2);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Align(
          child: FloatingActionButton(
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.7),
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          alignment: Alignment(-1, 0.17)),
      body: Column(
        children: <Widget>[
          HistoryMap(
            flightHistory: widget.flightHistory,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Plain Id ' + widget.flightHistory.planeId,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.black26,
            height: 3,
            indent: 15,
            endIndent: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width / 2 - 5,
                  height: 50,
                  child: OutlineButton.icon(
                    borderSide: BorderSide.none,
                    icon: Icon(Icons.import_export),
                    onPressed: () async {
                      await exportFlight2Csv(widget.flightHistory);
                    },
                    label: Text(
                      "Export",
                    ),
                  )),
              VerticalDivider(
                color: Colors.black26,
                width: 3,
                thickness: 2,
              ),
              ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width / 2 - 5,
                  height: 50,
                  child: OutlineButton.icon(
                    icon: Icon(Icons.share),
                    borderSide: BorderSide.none,
                    onPressed: () async {
                      await shareFligth(widget.flightHistory);
                    },
                    label: Text(
                      "Share",
                    ),
                  ))
            ],
          ),
          Divider(
            color: Colors.black26,
            height: 3,
            indent: 15,
            endIndent: 15,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              child: ListView(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.timelapse),
                      title: RichText(
                          text: TextSpan(
                        text: 'Duration: ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: duration + ' minutes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.pink[700],
                              ))
                        ],
                      ))),
                  ListTile(
                      leading: Icon(Icons.transfer_within_a_station),
                      title: RichText(
                          text: TextSpan(
                        text: 'Max distance from user: ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: distanceToString(
                                  widget.flightHistory.maxDistanceFromUser),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.pink[700],
                              ))
                        ],
                      ))),
                  ListTile(
                      leading: Icon(Icons.line_weight),
                      title: RichText(
                          text: TextSpan(
                        text: 'Max height: ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: distanceToString(
                                  widget.flightHistory.maxHeight),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.pink[700],
                              ))
                        ],
                      ))),
                  ListTile(
                      leading: Icon(Icons.ac_unit),
                      title: RichText(
                          text: TextSpan(
                        text: 'Max temperature: ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              text: widget.flightHistory.maxTemperature
                                      .toStringAsFixed(2) +
                                  ' º',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.pink[700],
                              ))
                        ],
                      )))
                ],
              ))
        ],
      ),
    );
  }
}
