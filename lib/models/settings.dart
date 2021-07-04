import 'package:shared_preferences/shared_preferences.dart';
import 'package:timmer/models/bluetooth_device.dart';

final String _pairedDeviceMACKey = 'pairedDeviceMACKey';
final String _pairedDeviceNameKey = 'pairedDeviceNameKey';

class Settings {
  static Future<BluetoothDevice> get pairedBTDevice async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var name = prefs.getString(_pairedDeviceNameKey);
    var id = prefs.getString(_pairedDeviceMACKey);

    if (name != null && id != null) {
      return BluetoothDevice.createBluetoothDevice(
          deviceName: prefs.getString(_pairedDeviceNameKey),
          deviceIdentifier: prefs.getString(_pairedDeviceMACKey));
    }

    return null;
  }

  static Future<void> savePairedBTDevice(BluetoothDevice btDevice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_pairedDeviceNameKey, btDevice.name);
    prefs.setString(_pairedDeviceMACKey, btDevice.id);
  }
}
