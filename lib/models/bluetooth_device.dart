import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart' as bt;
import 'package:flutter_blue/gen/flutterblue.pb.dart' as proto;
import 'package:timmer/models/device.dart';
import 'package:timmer/util/timer_data_transformer.dart';

enum DeviceBtType { LE, CLASSIC, DUAL, UNKNOWN }
const CUSTOM_SERVICE_UUID = '0000ffe0-0000-1000-8000-00805f9b34fb';
const CUSTOM_CHARACTERISTIC_UUID = '0000ffe1-0000-1000-8000-00805f9b34fb';

class BluetoothDevice implements Device {
  final DeviceType type = DeviceType.Bluetooth;
  bt.BluetoothDevice _btDevice;
  bt.BluetoothCharacteristic _characteristic;

  static bt.BluetoothDevice createBluetoothDevice(
      {String deviceName, String deviceIdentifier, DeviceBtType deviceType}) {
    proto.BluetoothDevice p = proto.BluetoothDevice.create();
    p.name = deviceName != null ? deviceName : '';
    p.remoteId = deviceIdentifier;
    if (deviceType == DeviceBtType.LE) {
      p.type = proto.BluetoothDevice_Type.LE;
    } else if (deviceType == DeviceBtType.CLASSIC) {
      p.type = proto.BluetoothDevice_Type.CLASSIC;
    } else if (deviceType == DeviceBtType.DUAL) {
      p.type = proto.BluetoothDevice_Type.DUAL;
    } else {
      p.type = proto.BluetoothDevice_Type.UNKNOWN;
    }

    return bt.BluetoothDevice.fromProto(p);
  }

  BluetoothDevice(bt.BluetoothDevice _btDevice);

  String get name {
    return _btDevice.name;
  }

  String get id {
    return _btDevice.id.id;
  }

  Future<void> connect(onTimeout) async {
    await _btDevice
        .connect()
        .timeout(Duration(seconds: 20), onTimeout: onTimeout);
  }

  Future<Stream<List<String>>> getDataStream() async {
    Stream<List<String>> stream;
    List<bt.BluetoothService> services = await _btDevice.discoverServices();
    bt.BluetoothService service = services.firstWhere(
        (service) => service.uuid.toString() == CUSTOM_SERVICE_UUID);
    if (service != null) {
      _characteristic = service.characteristics.firstWhere(
          (element) => element.uuid.toString() == CUSTOM_CHARACTERISTIC_UUID);
      if (_characteristic != null) {
        await _characteristic.setNotifyValue(true);
        stream = _characteristic.value
            .map<String>((val) => Utf8Decoder().convert(val))
            .transform(TimerDataTransformer());
      }
    }

    return stream;
  }

  Future<void> disconnect() async {
    bt.BluetoothDeviceState lastState = await _btDevice.state.last;
    if (lastState == bt.BluetoothDeviceState.connected) {
      _btDevice.disconnect();
    }
  }
}
