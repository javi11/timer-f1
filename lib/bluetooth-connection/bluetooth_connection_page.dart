import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:timmer/bluetooth-connection/widgets/bluetooth_scan.dart';
import 'package:timmer/bluetooth-connection/widgets/devices_list.dart';
import 'package:timmer/bluetooth-connection/widgets/connecting_device.dart';
import 'package:timmer/providers/bluetooth_provider.dart';

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
  BluetoothProvider _bluetoothProvider;
  BluetoothDevice selectedDevice;

  @override
  void initState() {
    super.initState();
    _bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _bluetoothProvider.stopScan();
    super.dispose();
  }

  void _startScan({Duration timeout}) {
    _bluetoothProvider.startScan(timeout: timeout);
  }

  void _onRetry() {
    _bluetoothProvider.startScan(timeout: Duration(seconds: 20));
  }

  void _onPair(BluetoothDevice device) {
    _bluetoothProvider.pairADevice(device);
  }

  void _onConnect() {
    _bluetoothProvider.connectToPairedDevice();
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
          child: Consumer<BluetoothProvider>(
              builder: (context, bluetoothProvider, child) {
            if (bluetoothProvider.connection != null) {
              return ConnectingDevice(
                  onConnected: widget.onConnected(context),
                  connectionStatus: bluetoothProvider.connectionStatus,
                  deviceName: bluetoothProvider.connection.name != null
                      ? bluetoothProvider.connection.name
                      : bluetoothProvider.connection.id.id,
                  onConnect: _onConnect);
            }

            if (bluetoothProvider.devicesList.length == 0) {
              return ScanView(
                connectionStatus: bluetoothProvider.connectionStatus,
                startScan: _startScan,
              );
            }

            return DeviceList(
              deviceList: bluetoothProvider.devicesList,
              connectionStatus: bluetoothProvider.connectionStatus,
              onPair: _onPair,
              onRetry: _onRetry,
            );
          }),
        ));
  }
}
