import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:timer_f1/app/routes/app_pages.dart';

class CustomDrawer extends Container {
  final Widget logo = SvgPicture.asset(
    'assets/images/logo.svg',
    semanticsLabel: 'Logo',
    width: 50,
    height: 50,
  );
  final Widget deviceStatusWidget;

  CustomDrawer({
    Key? key,
    required this.deviceStatusWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: <Widget>[
                logo,
                Expanded(
                  child: Center(
                      child: Text('Timer F1',
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w300))),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.cloud_off),
            title: Text('Offline maps'),
            onTap: () {},
          ),
          deviceStatusWidget,
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              GoRouter.of(context).push('${Routes.HOME}${Routes.SETTINGS}');
            },
          ),
        ],
      ),
    );
  }
}
