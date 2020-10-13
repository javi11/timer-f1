import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:timmer/models/flight_data.dart';
import 'package:timmer/types.dart';
import 'package:timmer/util/display_distance.dart';
import 'package:timmer/widgets/round_button.dart';

class BottomBar extends StatelessWidget {
  final FlightData flightData;
  final Function onExit;
  final Function onFixPlane;
  final Function onZoom;
  final Function onMoreInfo;
  final FixedLocation focusOn;
  final bool expanded;

  BottomBar(
      {Key key,
      @required this.flightData,
      @required this.onExit,
      @required this.onFixPlane,
      @required this.onZoom,
      @required this.onMoreInfo,
      @required this.focusOn,
      @required this.expanded})
      : super(key: key);

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 10),
      child: Card(
          elevation: 10,
          child: SizedBox(
              height: 110,
              width: MediaQuery.of(context).size.width - 10,
              child: ListView(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 24,
                            width: 5,
                          ),
                          roundButton(
                              Icon(
                                Icons.clear,
                                color: Colors.black,
                              ),
                              onExit),
                          SizedBox(
                            height: 24,
                            width: 5,
                          ),
                          Expanded(
                              child: flightData.planeDistanceFromUser != null
                                  ? AutoSizeText(
                                      distanceToString(
                                          flightData.planeDistanceFromUser),
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 25.5,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                    )
                                  : AutoSizeText(
                                      'Getting plain GPS location...',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                    )),
                          SizedBox(
                            height: 24,
                            width: 5,
                          ),
                          new Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              roundButton(Icon(Icons.zoom_out_map), onZoom),
                              SizedBox(
                                height: 24,
                                width: 5,
                              ),
                              roundButton(
                                  Icon(
                                    Icons.info,
                                    color:
                                        expanded ? Colors.blue : Colors.black,
                                  ),
                                  onMoreInfo),
                              SizedBox(
                                height: 24,
                                width: 5,
                              ),
                            ],
                          ))
                        ],
                      ),
                    ],
                  )
                ],
              ))),
    );
  }
}
