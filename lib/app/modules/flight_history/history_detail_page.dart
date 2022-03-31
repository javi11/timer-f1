import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history_detail_button.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history_detail_info_box.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history_map.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';
import 'package:timer_f1/core/utils/export_csv.dart';

class FlightHistoryDetailPage extends HookWidget {
  final Flight flight;
  FlightHistoryDetailPage({required this.flight});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var duration = useState('0');
    useEffect(() {
      duration.value = ((flight.durationInMs! / 1000) / 60).toStringAsFixed(2);
      return null;
    }, [flight.durationInMs]);

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: Align(
            child: FloatingActionButton(
                elevation: 0,
                splashColor: const Color.fromRGBO(255, 255, 255, 0),
                backgroundColor: const Color.fromRGBO(255, 255, 255, 0),
                onPressed: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.indigo,
                )),
            alignment: Alignment(-1.1, -1)),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              HistoryMap(
                flight: flight,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: [
                          0.0,
                          1.0
                        ]),
                  )),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              ListTile(
                                contentPadding: const EdgeInsets.only(
                                    top: 18, left: 18, right: 18),
                                title: Text('Plane ${flight.planeId}'),
                                subtitle: Text(flight.flightAddress!),
                                leading: Icon(
                                  Icons.location_on_sharp,
                                  color: Colors.red[300],
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 18, left: 18, right: 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      HistoryDetailInfoBox(
                                          text: 'Distance',
                                          data: distanceToString(flight
                                              .maxPlaneDistanceFromUser!)),
                                      HistoryDetailInfoBox(
                                          text: 'Height',
                                          data: distanceToString(
                                              flight.maxHeight!)),
                                      HistoryDetailInfoBox(
                                          text: 'Temp',
                                          data: flight.maxTemperature!
                                                  .toStringAsFixed(2) +
                                              ' Degrees'),
                                      HistoryDetailInfoBox(
                                          text: 'Duration',
                                          data: duration.value + ' minutes'),
                                    ],
                                  )),
                              Align(
                                alignment: AlignmentDirectional.bottomCenter,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: HistoryDetailButton(
                                              backgroundColor:
                                                  Colors.indigo.shade400,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(40)),
                                              onPressed: () async {
                                                await shareFlight(flight);
                                              },
                                              text: 'Share')),
                                      Expanded(
                                          child: HistoryDetailButton(
                                              backgroundColor:
                                                  Colors.red.shade300,
                                              borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(40)),
                                              onPressed: () async {
                                                await exportFlight2Csv(flight);
                                              },
                                              text: 'Export'))
                                    ]),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
