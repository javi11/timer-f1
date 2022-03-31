import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/no_timer_data.dart';
import 'package:timer_f1/global_widgets/buttons/cancel_button.dart';

void useNoTimerData({bool hasFlightStarted = false}) {
  var context = useContext();
  useEffect(() {
    Timer timeout = Timer(Duration(seconds: 10), () async {
      if (hasFlightStarted == false) {
        Navigator.of(context, rootNavigator: true).pop();
        await showDialog(
            context: context,
            builder: (ctx) => NoTimerData(),
            barrierDismissible: false);
      }
    });

    return timeout.cancel;
  }, [hasFlightStarted]);
}

class WaitingForData extends HookWidget {
  final bool hasFlightStarted;
  WaitingForData({required this.hasFlightStarted});

  @override
  Widget build(BuildContext context) {
    useNoTimerData(hasFlightStarted: hasFlightStarted);

    return WillPopScope(
        onWillPop: () {
          Navigator.popUntil(context, (route) {
            return route.isFirst;
          });

          return Future.value(false);
        },
        child: SimpleDialog(
          title: Text(
            'Waiting for timer data...',
            style: TextStyle(
                fontSize: 30,
                color: Colors.indigo,
                fontWeight: FontWeight.w400),
          ),
          children: [
            Lottie.asset("assets/animations/loading.json", repeat: true),
            Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    CancelButton(
                        text: 'Exit',
                        minimumSize: Size(60, 40),
                        onPressed: () {
                          Navigator.popUntil(context, (route) {
                            return route.isFirst;
                          });
                        })
                  ],
                ))
          ],
        ));
  }
}
