import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:timer_f1/app/routes/app_pages.dart';
import 'package:timer_f1/global_widgets/drawer/drawer_items.dart';

class CustomDrawer extends Container {
  final Widget logo = SvgPicture.asset(
    'assets/images/logo.svg',
    semanticsLabel: 'Logo',
    width: 50,
    height: 50,
  );
  final Widget deviceStatusWidget;
  final void Function()? onNavigate;

  CustomDrawer({Key? key, required this.deviceStatusWidget, this.onNavigate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue[400]!,
            Colors.indigo[800]!,
          ],
        )),
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    padding: EdgeInsets.all(40),
                    child: logo,
                  ),
                  DrawerItem(
                    leading: Icon(Icons.cloud_off),
                    title: 'Offline maps',
                    onTap: () {},
                  ),
                  deviceStatusWidget,
                  DrawerItem(
                    leading: Icon(Icons.settings),
                    title: 'Settings',
                    onTap: () {
                      onNavigate?.call();
                      GoRouter.of(context)
                          .push('${Routes.HOME}${Routes.SETTINGS}');
                    },
                  ),
                ],
              ),
            )));
  }
}
