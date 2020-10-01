import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timmer/bluetooth-connection/bluetooth_connection_page.dart';
import 'package:timmer/offline_maps/offline_maps_list.dart';
import 'package:timmer/providers/bluetooth_provider.dart';
import 'package:timmer/types.dart';
import 'package:timmer/widgets/app_title.dart';

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
        Consumer<BluetoothProvider>(
            builder: (context, bluetoothProvider, child) {
          if (bluetoothProvider.connectionStatus ==
              ConnectionStatus.CONNECTED) {
            return Container(
                decoration: BoxDecoration(color: Colors.green[50]),
                child: ListTile(
                  leading: Icon(Icons.bluetooth_connected),
                  title: Text(bluetoothProvider.pairedDevice.name != null
                      ? bluetoothProvider.pairedDevice.name
                      : bluetoothProvider.pairedDevice.id.id),
                  onTap: () {},
                ));
          }

          if (bluetoothProvider.pairedDevice != null &&
              bluetoothProvider.connectionStatus ==
                  ConnectionStatus.DISSCONNECTED) {
            return Container(
                decoration: BoxDecoration(color: Colors.red[50]),
                child: ListTile(
                  leading: Icon(Icons.bluetooth_disabled),
                  title: Text(bluetoothProvider.pairedDevice.name != null
                      ? bluetoothProvider.pairedDevice.name
                      : bluetoothProvider.pairedDevice.id.id + ' disconnected'),
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.downToUp,
                            child: BluetoothConnectionPage()));
                  },
                ));
          }

          return ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text('Pair a device'),
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.downToUp,
                      child: BluetoothConnectionPage()));
            },
          );
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
