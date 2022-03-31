import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/flight_info_box.dart';
import 'package:timer_f1/core/utils/distance_to_string.dart';
import 'package:timer_f1/global_widgets/buttons/round_button.dart';

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
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        elevation: 10,
        child: Center(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RoundButton(
                            child: Icon(
                              Icons.clear,
                              color: Colors.black54,
                            ),
                            onPressed: onExit),
                        Expanded(
                            child: Consumer(builder: (context, ref, child) {
                          var planeDistanceFromUser = ref.watch(
                              flightDataStreamProvider.select((value) =>
                                  value.value?.planeDistanceFromUser));
                          return planeDistanceFromUser != null
                              ? FlightInfoBox(
                                  data: distanceToString(planeDistanceFromUser)
                                      .replaceAll(' ', ''),
                                  type: 'Distance',
                                  icon: Icon(
                                    Icons.straighten,
                                    color: Colors.orange.shade300,
                                  ),
                                )
                              : FlightInfoBox(
                                  data: 'Recalculating...',
                                  type: 'Distance',
                                  icon: Icon(
                                    Icons.straighten,
                                    color: Colors.orange.shade300,
                                  ),
                                );
                        })),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            RoundButton(
                                child: Icon(
                                  Icons.zoom_out_map,
                                  color: Colors.black54,
                                ),
                                onPressed: onZoom),
                            SizedBox(
                              height: 24,
                              width: 5,
                            ),
                            RoundButton(
                                child: Icon(
                                  Icons.info,
                                  color:
                                      expanded ? Colors.indigo : Colors.black54,
                                ),
                                onPressed: onMoreInfo),
                          ],
                        ))
                      ],
                    ),
                  ],
                ))),
      ),
    );
  }
}
