import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timer_f1/app/data/bluetooth_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/bluetooth_controller.dart';
import 'package:timer_f1/app/routes/app_pages.dart';

class BluetoothStatus extends Container {
  final BluetoothController btController = Get.find<BluetoothController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (btController.bluetoothState.value == BluetoothState.connected &&
          btController.connectedDevice.value != null) {
        return Container(
            decoration: BoxDecoration(color: Colors.green[50]),
            child: ListTile(
              leading: Icon(Icons.bluetooth_connected),
              title: Text(btController.connectedDevice.value!.name),
              onTap: () {
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.INFO,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Do you want to delete this device?',
                    desc: 'The device will be unpair from the phone',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async => await btController.onDisconnect(
                        btController.connectedDevice.value!)).show();
              },
            ));
      }
      if (btController.bluetoothState.value == BluetoothState.connecting) {
        return Container(
            decoration: BoxDecoration(color: Colors.lightBlue[50]),
            child: ListTile(
              leading: Icon(Icons.bluetooth_searching),
              title: Text(
                  'Connecting to ${btController.pairedDevice.value?.name}...'),
              trailing: CircularProgressIndicator(),
              onTap: () {
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.INFO,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Do you want to delete this device?',
                    desc: 'The device will be unpair from the phone',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () async => await btController.onDisconnect(
                        btController.connectedDevice.value!)).show();
              },
            ));
      }

      if (btController.bluetoothState.value ==
          BluetoothState.connectionTimeout) {
        return Container(
            decoration: BoxDecoration(color: Colors.amber[50]),
            child: ListTile(
              leading: Icon(Icons.bluetooth_disabled),
              title:
                  Text('${btController.pairedDevice.value?.name} out of range'),
              onTap: () {
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.INFO,
                    animType: AnimType.BOTTOMSLIDE,
                    title:
                        'What do you want to do with ${btController.pairedDevice.value?.name}?',
                    desc:
                        'Get closer to ${btController.pairedDevice.value?.name} and push reconnect',
                    btnCancelText: 'Remove device',
                    btnCancelOnPress: () async => await btController
                        .onRemoveDevice(btController.pairedDevice.value!),
                    btnOkText: 'Reconnect',
                    btnOkOnPress: () => btController
                        .onConnect(btController.pairedDevice.value!)).show();
              },
            ));
      }
      return ListTile(
        leading: Icon(Icons.bluetooth),
        title: Text('Pair a device'),
        onTap: () => Get.toNamed(Routes.BLUETOOTH),
      );
    });
  }
}
