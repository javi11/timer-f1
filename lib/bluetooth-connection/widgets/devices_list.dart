import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as bt;
import 'package:timerf1c/models/bluetooth_device.dart';
import 'package:timerf1c/types.dart';

class DeviceList extends StatelessWidget {
  final UnmodifiableListView<bt.DiscoveredDevice> deviceList;
  final ConnectionStatus connectionStatus;
  final Function onPair;
  final Function onRetry;

  DeviceList({
    Key? key,
    required this.deviceList,
    required this.connectionStatus,
    required this.onPair,
    required this.onRetry,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(color: Colors.blue[50]),
            child: ListTile(
              title: Text(
                '${deviceList.length} DEVICES FOUND.',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey[500]),
              ),
              subtitle: Text(
                'Select one of the devices to pair.',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              trailing: connectionStatus == ConnectionStatus.SCANNING
                  ? CircularProgressIndicator()
                  : FlatButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.blueAccent,
                      onPressed: onRetry as void Function()?,
                      child: Text(
                        "Scan",
                        style: TextStyle(fontSize: 20.0),
                      )),
            )),
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 200,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: deviceList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  bt.DiscoveredDevice device = deviceList[index];

                  return ListTile(
                    onTap: () {
                      onPair(BluetoothDevice(device.name, device.id));
                    },
                    leading: Icon(Icons.bluetooth),
                    isThreeLine: true,
                    subtitle:
                        Text('Signal: ${device.rssi} mDb \n Id: ${device.id}'),
                    title: Text(device.name.isEmpty ? device.id : device.name),
                  );
                })),
      ],
    );
  }
}
