import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/no_timer_data.dart';

class WaitingForData extends HookWidget {
  final bool hasFlightStarted;
  WaitingForData(this.hasFlightStarted);

  Timer _startTimerDataTimeout(BuildContext context) {
    return Timer(Duration(seconds: 10), () async {
      if (hasFlightStarted == false) {
        await showDialog(
            context: context,
            builder: (ctx) => NoTimerData(),
            barrierDismissible: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Timer timeout = _startTimerDataTimeout(context);

      return timeout.cancel;
    }, [hasFlightStarted]);

    return WillPopScope(
        onWillPop: () {
          Navigator.popUntil(context, (route) {
            return route.isFirst;
          });

          return Future.value(false);
        },
        child: SimpleDialog(
          title: Text('Waiting for timer data...'),
          children: [
            Lottie.asset("assets/animations/loading.json", repeat: true),
            Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) {
                          return route.isFirst;
                        });
                      },
                      child: Text(
                        "Exit",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    )
                  ],
                ))
          ],
        ));
  }
}
