import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:timmer/models/timmer.dart';
import 'package:timmer/tracking/tracking_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<Timmer>(
        model: Timmer(),
        child: MaterialApp(
            title: 'Timmer',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
            ),
            home: TrackingPage()));
  }
}
