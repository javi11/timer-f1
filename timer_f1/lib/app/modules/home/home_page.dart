import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_history/controllers/flight_history_controller.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/device_status.dart';
import 'package:timer_f1/global_widgets/drawer.dart';
import 'package:timer_f1/global_widgets/clipped_parts.dart';

class HomePage extends HookConsumerWidget {
  final GlobalKey<InOutAnimationState> _fabAnimationController =
      GlobalKey<InOutAnimationState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var onStartFlight = useCallback(
        () => GoRouter.of(context)
            .push('${Routes.BLUETOOTH}?redirectTo=/${Routes.FLIGHT_TRACKER}'),
        []);

    return Scaffold(
        drawer: CustomDrawer(
          deviceStatusWidget: DeviceStatus(),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          elevation: 0,
          centerTitle: true,
          title: Text('Timer F1',
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w300)),
        ),
        body: ClippedPartsWidget(
          top: Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            color: Colors.blue[400],
          ),
          bottom: Stack(children: <Widget>[
            Container(
              height: 190,
              color: Colors.blue[100],
            ),
            Container(child: History(onStartFlight: onStartFlight))
          ]),
          splitFunction: (Size size, double x) {
            // normalizing x to make it exactly one wave
            final normalizedX = x / size.width * 3 * pi;
            final waveHeight = size.height / 40;
            final y = size.height / 14 - sin(cos(normalizedX)) * waveHeight;

            return y;
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: InOutAnimation(
          autoPlay: ref
                  .watch(flightHistoryControllerProvider
                      .select((value) => value.flightHistory))
                  .isEmpty
              ? InOutAnimationStatus.Out
              : InOutAnimationStatus.In,
          inDefinition: SlideInUpAnimation(
              preferences:
                  AnimationPreferences(duration: Duration(milliseconds: 500))),
          outDefinition: SlideOutDownAnimation(
              preferences:
                  AnimationPreferences(duration: Duration(milliseconds: 500))),
          key: _fabAnimationController,
          child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.green,
              icon: Icon(Icons.flight_takeoff),
              onPressed: onStartFlight,
              label: AutoSizeText(
                'Start a flight',
                maxFontSize: 30,
                style: TextStyle(fontSize: 20),
              )),
        ));
  }
}
