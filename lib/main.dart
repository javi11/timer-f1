import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timmer/home/home_page.dart';
import 'package:timmer/models/bluetooth.dart';
import 'package:timmer/providers/history_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HistoryProvider>(
            create: (_) => HistoryProvider()..loadHistoryItems(0)),
        ChangeNotifierProvider<Bluetooth>(create: (_) => Bluetooth()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        home: HomePage());
  }
}
