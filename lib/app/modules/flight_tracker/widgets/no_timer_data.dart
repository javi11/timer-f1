import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/global_widgets/buttons/cancel_button.dart';

class NoTimerData extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var device = ref.watch<Device?>(
        bleControllerProvider.select((value) => value.connectedDevice));

    return WillPopScope(
        onWillPop: () {
          Navigator.popUntil(context, (route) {
            return route.isFirst;
          });

          return Future.value(false);
        },
        child: SimpleDialog(
          title: Text(
            device?.brand != Brand.vicent
                ? 'Invalid timer brand'
                : 'Is the timer turned ON?',
            style: TextStyle(
                fontSize: 30,
                color: Colors.indigo,
                fontWeight: FontWeight.w400),
          ),
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
