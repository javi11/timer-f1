import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';
import 'package:timer_f1/global_widgets/round_button.dart';

class BottomBar extends Container {
  final Function onExit;
  final Function onZoom;
  final Function onMoreInfo;
  final bool expanded;

  BottomBar(
      {Key? key,
      required this.onExit,
      required this.onZoom,
      required this.onMoreInfo,
      required this.expanded})
      : super(key: key);

  @override
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
                          RoundButton(
                              child: Icon(
                                Icons.clear,
                                color: Colors.black,
                              ),
                              onPressed: onExit),
                          SizedBox(
                            height: 24,
                            width: 5,
                          ),
                          Expanded(
                              child: Consumer(builder: (context, ref, child) {
                            var planeDistanceFromUser = ref.watch(
                                flightDataStreamProvider.select((value) =>
                                    value.value?.planeDistanceFromUser));
                            return planeDistanceFromUser != null
                                ? AutoSizeText(
                                    distanceToString(planeDistanceFromUser),
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
                                  );
                          })),
                          SizedBox(
                            height: 24,
                            width: 5,
                          ),
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              RoundButton(
                                  child: Icon(Icons.zoom_out_map),
                                  onPressed: onZoom),
                              SizedBox(
                                height: 24,
                                width: 5,
                              ),
                              RoundButton(
                                  child: Icon(
                                    Icons.info,
                                    color:
                                        expanded ? Colors.blue : Colors.black,
                                  ),
                                  onPressed: onMoreInfo),
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
