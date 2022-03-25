import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:timer_f1/app/data/models/flight_model.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history_detail_button.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history_detail_glass_box.dart';
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
                splashColor: Color.fromRGBO(255, 255, 255, 0),
                backgroundColor: Color.fromRGBO(255, 255, 255, 0),
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
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HistoryDetailGlassBox(
                        text: 'Distance',
                        data:
                            distanceToString(flight.maxPlaneDistanceFromUser!)),
                    HistoryDetailGlassBox(
                        text: 'Height',
                        data: distanceToString(flight.maxHeight!)),
                    HistoryDetailGlassBox(
                        text: 'Temp',
                        data: flight.maxTemperature!.toStringAsFixed(2) +
                            ' Degrees'),
                    HistoryDetailGlassBox(
                        text: 'Duration', data: duration.value + ' minutes'),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 190,
                        child: Card(
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              ListTile(
                                contentPadding: EdgeInsets.all(18),
                                title: Text('Plane ${flight.planeId}'),
                                subtitle: Text(flight.flightAddress!),
                                leading: Icon(
                                  Icons.location_on_sharp,
                                  color: Colors.red[300],
                                ),
                              ),
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
