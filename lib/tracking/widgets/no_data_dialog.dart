import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget buildNoDataDialog(context) {
  return WillPopScope(
      onWillPop: () {
        Navigator.popUntil(context, (route) {
          return route.isFirst;
        });

        return Future.value(false);
      },
      child: SimpleDialog(
        title: Text('Is the timer turned ON?'),
        children: [
          Lottie.asset("assets/animations/turn-on-timerf1c.json", repeat: true),
          Container(
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  Text(
                    'Turn ON the timer by pressing twice the action button.',
                    style: TextStyle(color: Colors.blueGrey[600], fontSize: 17),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
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
