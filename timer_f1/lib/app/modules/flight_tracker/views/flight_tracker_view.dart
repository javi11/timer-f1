import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/flight_tracker_controller.dart';

class FlightTrackerView extends GetView<FlightTrackerController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlightTrackerView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'FlightTrackerView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
