import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timerf1c/bluetooth-connection/bluetooth_connection_page.dart';
import 'package:timerf1c/home/widgets/paired_device_list_item.dart';
import 'package:timerf1c/offline_maps/offline_maps_list.dart';
import 'package:timerf1c/providers/connection_provider.dart';
import 'package:timerf1c/widgets/app_title.dart';

Widget buildDrawer(BuildContext context) {
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
          leading: Icon(Icons.cloud_off),
          title: Text('Offline maps'),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.downToUp,
                    child: OfflineMapsPage()));
          },
        ),
        Consumer<ConnectionProvider>(
            builder: (context, connectionProvider, child) {
          var onDisconnectionPress = () async {
            await connectionProvider.deletePairedDevice();
          };
          var onConnectionPress = () {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.downToUp,
                    child: BluetoothConnectionPage()));
          };

          return PairedDeviceListItem(
              connectionProvider.connectionStatus,
              connectionProvider.connectedDevice,
              connectionProvider.pariedBTDevice,
              onConnectionPress,
              onDisconnectionPress);
        }),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
      ],
    ),
  );
}
