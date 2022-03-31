import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_duration_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/flight_info_box.dart';

class DurationBox extends ConsumerWidget {
  const DurationBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var duration = ref.watch(flightDurationProvider).duration;
    return FlightInfoBox(
      data: duration,
      type: 'Duration',
      icon: Icon(
        Icons.timelapse,
        color: Colors.indigo.shade300,
      ),
    );
  }
}
