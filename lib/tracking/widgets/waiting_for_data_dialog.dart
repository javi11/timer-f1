import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget buildWaitingForDataDialog(context) {
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
