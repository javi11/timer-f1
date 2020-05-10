import 'package:flutter/material.dart';
import 'package:timmer/tracking/widgets/map.dart';
import 'package:timmer/tracking/timmer_bluetooth_provider.dart';

class TrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // user defined function

    return Scaffold(
        body: TimmerBluetoothProvider(childBuilder: (BuildContext context) {
      return MapComponent();
    }));
  }
}
