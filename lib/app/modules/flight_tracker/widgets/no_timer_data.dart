import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/data/models/device_model.dart';

class NoTimerData extends StatelessWidget {
  final Device? device;
  NoTimerData({required this.device});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.popUntil(context, (route) {
            return route.isFirst;
          });

          return Future.value(false);
        },
        child: SimpleDialog(
          title: Text(device?.brand != Brand.vicent
              ? 'Invalid timer brand'
              : 'Is the timer turned ON?'),
          children: [
            Lottie.asset(
                device?.brand != Brand.vicent
                    ? "assets/animations/invalid-timer-brand.json"
                    : "assets/animations/turn-on-timerf1c.json",
                repeat: true),
            Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Text(
                      device?.brand != Brand.vicent
                          ? 'The device timer brand is "${device?.brand}" but the only allowed GPS timer brand is "Vicent"'
                          : 'Turn ON the timer by pressing twice the action button.',
                      style:
                          TextStyle(color: Colors.blueGrey[600], fontSize: 17),
                    ),
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
