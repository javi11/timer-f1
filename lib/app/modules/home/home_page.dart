import 'dart:math';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history.dart';
import 'package:timer_f1/app/modules/program/widgets/program-list.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/device_status.dart';
import 'package:timer_f1/global_widgets/drawer.dart';
import 'package:timer_f1/global_widgets/clipped_parts.dart';

const appBarWithFiltersSize = 350.0;

class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isUsbConnected =
        ref.watch(usbControllerProvider.select((value) => value.isConnected));
    var startFlight = useCallback(
        () => isUsbConnected
            ? GoRouter.of(context).push('/${Routes.FLIGHT_TRACKER}')
            : GoRouter.of(context).push(
                '${Routes.BLUETOOTH}?redirectTo=/${Routes.FLIGHT_TRACKER}'),
        [isUsbConnected]);
    var tabController = useTabController(initialLength: 3, initialIndex: 0);
    var openFilters = useState(true);
    var controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    var clipW = useListenable(Tween<double>(
      begin: 0,
      end: appBarWithFiltersSize,
    ).animate(
      controller,
    ));

    return Scaffold(
      drawer: CustomDrawer(
        deviceStatusWidget: DeviceStatus(),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined),
            onPressed: () {
              if (controller.isCompleted) {
                controller.reverse();
              } else {
                controller.forward();
              }
            },
          )
        ],
        title: Text('Timer F1',
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w300)),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.history, title: 'History'),
          TabItem(
            icon: Icons.airplane_ticket,
            title: 'Start Flight',
          ),
          TabItem(icon: Icons.build, title: 'program'),
        ],
        controller: tabController,
        initialActiveIndex: 0, //optional, default as 0
        onTap: (int i) {
          switch (i) {
            case 0:
              break;
            case 1:
              startFlight();
              tabController.index = 0;
              break;
            case 2:
              break;
          }
        },
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ClippedPartsWidget(
            top: Container(
              width: MediaQuery.of(context).size.width,
              height: 150 + clipW.value,
              color: Colors.blue[400],
            ),
            bottom: Stack(children: <Widget>[
              Container(
                height: 190 + clipW.value,
                color: clipW.value > 100
                    ? Colors.black.withOpacity(
                        0 + (clipW.value / (appBarWithFiltersSize - 500)))
                    : Colors.blue[100],
              ),
              Container(
                  color: Colors.black.withOpacity(
                      0 + (clipW.value / (appBarWithFiltersSize - 100))),
                  child: History(onStartFlight: startFlight))
            ]),
            splitFunction: (Size size, double x) {
              // normalizing x to make it exactly one wave
              final normalizedX = x / size.width * 3 * pi;
              final waveHeight = size.height / 40;
              final y = size.height / 14 - sin(cos(normalizedX)) * waveHeight;

              return y + clipW.value;
            },
          ),
          SizedBox(
            width: 10,
          ),
          ProgramList()
        ],
      ),
    );
  }
}
