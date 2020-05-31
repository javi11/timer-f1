import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timmer/widgets/app_title.dart';

Widget buildDrawer() {
  final Widget logo = SvgPicture.asset(
    'assets/images/logo.svg',
    semanticsLabel: 'Logo',
    width: 50,
    height: 50,
  );

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
                // 1st use Expanded
                child:
                    Center(child: appTitle()), // 2nd wrap your widget in Center
              )
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.bluetooth_searching),
          title: Text('Pair device'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
      ],
    ),
  );
}
