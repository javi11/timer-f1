import 'dart:math';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history.dart';
import 'package:timer_f1/app/modules/program/widgets/program-list.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/app_name.dart';
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
    var zoomDrawerController = useMemoized(() => ZoomDrawerController(), []);

    return Material(
        child: ZoomDrawer(
      controller: zoomDrawerController,
      menuScreen: CustomDrawer(
        deviceStatusWidget: DeviceStatus(),
      ),
      mainScreen: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              color: Colors.indigo,
              onPressed: () => zoomDrawerController.toggle?.call(),
              icon: Icon(Icons.menu)),
          actions: [
            IconButton(
              color: Colors.indigo,
              icon: Icon(Icons.filter_alt_outlined),
              onPressed: () {},
            )
          ],
          title: AppName(),
        ),
        bottomNavigationBar: ConvexAppBar(
          color: Colors.indigo[100],
          backgroundColor: Colors.indigo,
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
            History(onStartFlight: startFlight),
            SizedBox(
              width: 10,
            ),
            ProgramList()
          ],
        ),
      ),
      borderRadius: 24.0,
      showShadow: true,
      angle: 0.0,
      mainScreenScale: 0.15,
      style: DrawerStyle.Style1,
      backgroundColor: Colors.grey[300]!,
      openCurve: Curves.fastOutSlowIn,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
    ));
  }
}
