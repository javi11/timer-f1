import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/flight_history_detail/widgets/history_map.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';
import 'package:timer_f1/core/utils/export_csv.dart';

class FligthHistoryDetailPage extends HookWidget {
  final Flight flight;
  FligthHistoryDetailPage({required this.flight});
  @override
  Widget build(BuildContext context) {
    var duration = useState('0');
    useEffect(() {
      duration.value = ((flight.durationInMs! / 1000) / 60).toStringAsFixed(2);
    }, [flight.durationInMs]);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Align(
          child: FloatingActionButton(
              elevation: 0,
              splashColor: Color.fromRGBO(255, 255, 255, 0),
              backgroundColor: Color.fromRGBO(255, 255, 255, 0),
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          alignment: Alignment(-1.1, -0.98)),
      body: Column(
        children: <Widget>[
          flight.flightStartCoordinates != null
              ? HistoryMap(
                  flight: flight,
                )
              : SizedBox(
                  height: 29,
                ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Plain Id ' + flight.planeId!,
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
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    icon: Icon(Icons.import_export),
                    onPressed: () async {
                      await exportFlight2Csv(flight);
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
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    icon: Icon(Icons.share),
                    onPressed: () async {
                      await shareFligth(flight);
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
                              text: duration.value + ' minutes',
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
                                  flight.maxPlaneDistanceFromUser!),
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
                              text: distanceToString(flight.maxHeight!),
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
                              text: flight.maxTemperature!.toStringAsFixed(2) +
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
