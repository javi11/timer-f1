import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/bluetooth_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/app/modules/flight_history/widgets/history.dart';
import 'package:timer_f1/app/modules/program/widgets/program_list.dart';
import 'package:timer_f1/app/modules/usb_device/controllers/usb_serial_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/header/app_header_title.dart';
import 'package:timer_f1/global_widgets/drawer/device_status.dart';
import 'package:timer_f1/global_widgets/drawer/drawer.dart';

class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var isUsbConnected =
        ref.watch(usbControllerProvider.select((value) => value.isConnected));
    var isBLEConnected = ref.watch(bleControllerProvider
        .select((value) => value.bluetoothState == BluetoothState.connected));
    var startFlight = useCallback(
        () => isUsbConnected || isBLEConnected
            ? GoRouter.of(context).push('/${Routes.FLIGHT_TRACKER}')
            : GoRouter.of(context).push(
                '${Routes.BLUETOOTH}?redirectTo=/${Routes.FLIGHT_TRACKER}'),
        [isUsbConnected, isBLEConnected]);
    var tabController = useTabController(initialLength: 3, initialIndex: 0);
    var zoomDrawerController = useMemoized(() => ZoomDrawerController(), []);

    return Material(
        child: ZoomDrawer(
      controller: zoomDrawerController,
      menuScreen: CustomDrawer(
        onNavigate: (() => zoomDrawerController.close!()),
        deviceStatusWidget: DeviceStatus(),
      ),
      mainScreen: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              onPressed: () => zoomDrawerController.toggle?.call(),
              icon: Icon(Icons.menu)),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt_outlined),
              onPressed: () {},
            )
          ],
          title: AppHeaderTitle(
            title: 'TIMER',
            subtitle: 'F1',
          ),
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
          initialActiveIndex: 0,
          onTabNotify: (i) {
            var intercept = i == 1;
            if (intercept) {
              startFlight();
            }
            return !intercept;
          },
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
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
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor!,
      openCurve: Curves.fastOutSlowIn,
      slideWidth: MediaQuery.of(context).size.width * 0.75,
    ));
  }
}
