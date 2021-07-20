import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timerf1c/models/bluetooth_device.dart';
import 'package:provider/provider.dart';
import 'package:timerf1c/bluetooth-connection/widgets/bluetooth_scan.dart';
import 'package:timerf1c/bluetooth-connection/widgets/devices_list.dart';
import 'package:timerf1c/bluetooth-connection/widgets/connecting_device.dart';
import 'package:timerf1c/providers/connection_provider.dart';

Function _defaultOnConnected(ctx) {
  return () {
    Navigator.of(ctx).pop();
  };
}

class BluetoothConnectionPage extends StatefulWidget {
  final Function onConnected;

  BluetoothConnectionPage({Key key, this.onConnected = _defaultOnConnected})
      : super(key: key);
  @override
  _BluetoothConnectionPageState createState() =>
      _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  ConnectionProvider _connectionProvider;
  BluetoothDevice selectedDevice;

  @override
  void initState() {
    super.initState();
    _connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _connectionProvider.stopScan();
    super.dispose();
  }

  void _startScan({Duration timeout}) {
    _connectionProvider.startScan(timeout: timeout);
  }

  void _onRetry() {
    _connectionProvider.startScan(timeout: Duration(seconds: 20));
  }

  void _onPair(BluetoothDevice device) {
    _connectionProvider.pairADevice(device);
  }

  void _onConnect() {
    _connectionProvider.connect(_connectionProvider.pariedBTDevice);
  }

  @override
  Widget build(BuildContext context) {
    // Do not allow rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            title: Text('Connecting...'),
            automaticallyImplyLeading: true,
            elevation: 0),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Consumer<ConnectionProvider>(
              builder: (context, connectionProvider, child) {
            if (connectionProvider.pariedBTDevice != null) {
              return ConnectingDevice(
                  onConnected: widget.onConnected(context),
                  connectionStatus: connectionProvider.connectionStatus,
                  deviceName: connectionProvider.pariedBTDevice.name != null
                      ? connectionProvider.pariedBTDevice.name
                      : connectionProvider.pariedBTDevice.id,
                  onConnect: _onConnect);
            }

            if (connectionProvider.devicesList.length == 0) {
              return ScanView(
                connectionStatus: connectionProvider.connectionStatus,
                startScan: _startScan,
              );
            }

            return DeviceList(
              deviceList: connectionProvider.devicesList,
              connectionStatus: connectionProvider.connectionStatus,
              onPair: _onPair,
              onRetry: _onRetry,
            );
          }),
        ));
  }
}
