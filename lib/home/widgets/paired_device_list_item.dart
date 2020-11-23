import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:timmer/providers/bluetooth_provider.dart';
import 'package:timmer/types.dart';

class PairedDeviceListItem extends StatelessWidget {
  final ConnectionType _connectionType;
  final ConnectionStatus _connectionStatus;
  final BluetoothDevice _pairedDevice;
  final Function _onConnectedPress;
  final Function _onDisconnectedPress;

  PairedDeviceListItem(this._connectionType, this._connectionStatus,
      this._pairedDevice, this._onConnectedPress, this._onDisconnectedPress);

  @override
  Widget build(BuildContext context) {
    if (_connectionType == ConnectionType.USB) {
      return Container(
          decoration: BoxDecoration(color: Colors.green[50]),
          child: ListTile(
            leading: Icon(Icons.usb),
            title: Text('USB device'),
            onTap: () {},
          ));
    }

    if (_connectionStatus == ConnectionStatus.CONNECTED) {
      return Container(
          decoration: BoxDecoration(color: Colors.green[50]),
          child: ListTile(
            leading: Icon(Icons.bluetooth_connected),
            title: Text(_pairedDevice.name != null
                ? _pairedDevice.name
                : _pairedDevice.id.id),
            onTap: () {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.INFO,
                      animType: AnimType.BOTTOMSLIDE,
                      tittle: 'Do you want to delete this device?',
                      desc: 'The device will be unpair from the phone',
                      btnCancelOnPress: () {},
                      btnOkOnPress: _onConnectedPress)
                  .show();
            },
          ));
    }

    if (_pairedDevice != null &&
        _connectionStatus != ConnectionStatus.CONNECTED) {
      return Container(
          decoration: BoxDecoration(color: Colors.red[50]),
          child: ListTile(
            leading: Icon(Icons.bluetooth_disabled),
            title: Text(_pairedDevice.name != null
                ? _pairedDevice.name
                : _pairedDevice.id.id + ' disconnected'),
            onTap: _onDisconnectedPress,
          ));
    }

    return ListTile(
      leading: Icon(Icons.bluetooth),
      title: Text('Pair a device'),
      onTap: _onDisconnectedPress,
    );
  }
}
