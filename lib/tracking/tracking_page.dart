import 'package:flutter/material.dart';
import 'package:timmer/tracking/components/map.dart';
import 'package:timmer/tracking/timmer_bluetooth_provider.dart';

class TrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // user defined function

    return Scaffold(
        appBar: AppBar(title: Text("GPS Location")),
        body: TimmerBluetoothProvider(childBuilder: (BuildContext context) {
          return MapComponent();
        }));
  }
}
