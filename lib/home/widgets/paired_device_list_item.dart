import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:timerf1c/models/bluetooth_device.dart';
import 'package:timerf1c/models/device.dart';
import 'package:timerf1c/types.dart';

class PairedDeviceListItem extends StatelessWidget {
  final ConnectionStatus _connectionStatus;
  final Device _connectedDevice;
  final BluetoothDevice _pairedDevice;
  final Function _onConnectionPress;
  final Function _onDisconnectionPress;

  PairedDeviceListItem(this._connectionStatus, this._connectedDevice,
      this._pairedDevice, this._onConnectionPress, this._onDisconnectionPress);

  @override
  Widget build(BuildContext context) {
    if (_connectedDevice != null && _connectedDevice.type == DeviceType.USB) {
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
                : _pairedDevice.id),
            onTap: () {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.INFO,
                      animType: AnimType.BOTTOMSLIDE,
                      tittle: 'Do you want to delete this device?',
                      desc: 'The device will be unpair from the phone',
                      btnCancelOnPress: () {},
                      btnOkOnPress: _onDisconnectionPress)
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
                : _pairedDevice.id + ' disconnected'),
            onTap: _onConnectionPress,
          ));
    }

    return ListTile(
      leading: Icon(Icons.bluetooth),
      title: Text('Pair a device'),
      onTap: _onConnectionPress,
    );
  }
}
