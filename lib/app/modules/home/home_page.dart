import 'dart:math';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history.dart';
import 'package:timer_f1/app/modules/home/widgets/expandible_menu.dart';
import 'package:timer_f1/app/modules/program/widgets/program-list.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/device_status.dart';
import 'package:timer_f1/global_widgets/drawer.dart';

class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var isUsbConnected =
        ref.watch(usbControllerProvider.select((value) => value.isConnected));
    var startFlight = useCallback(
        () => isUsbConnected
            ? GoRouter.of(context).push('/${Routes.FLIGHT_TRACKER}')
            : GoRouter.of(context).push(
                '${Routes.BLUETOOTH}?redirectTo=/${Routes.FLIGHT_TRACKER}'),
        [isUsbConnected]);
    var tabController = useTabController(initialLength: 3, initialIndex: 0);
    var expandibleMenuController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

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
              if (expandibleMenuController.isCompleted) {
                expandibleMenuController.reverse();
              } else {
                expandibleMenuController.forward();
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
          Stack(children: <Widget>[
            Container(child: History(onStartFlight: startFlight)),
            ExpandibleMenu(
              actions: Container(),
              expandedActions: Container(),
              controller: expandibleMenuController,
            )
          ]),
          SizedBox(
            width: 10,
          ),
          ProgramList()
        ],
      ),
    );
  }
}
