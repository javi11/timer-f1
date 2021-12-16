import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as bt;
import 'package:timerf1c/ble/ble.dart';
import 'package:timerf1c/models/device.dart';
import 'package:timerf1c/util/timer_data_transformer.dart';

enum DeviceBtType { LE, CLASSIC, DUAL, UNKNOWN }
const CUSTOM_SERVICE_UUID = '0000ffe0-0000-1000-8000-00805f9b34fb';
const CUSTOM_CHARACTERISTIC_UUID = '0000ffe1-0000-1000-8000-00805f9b34fb';

class BluetoothDevice implements Device {
  final DeviceType type = DeviceType.Bluetooth;
  bt.QualifiedCharacteristic? _characteristic;
  String name;
  String id;

  static BluetoothDevice createBluetoothDevice(
      {String? deviceName, required String deviceIdentifier}) {
    return BluetoothDevice(
        deviceName != null ? deviceName : 'unknown', deviceIdentifier);
  }

  BluetoothDevice(this.name, this.id);

  Stream<bt.ConnectionStateUpdate> get state {
    return connector.state;
  }

  Future<void> connect(
      {Duration? timeout: const Duration(seconds: 20),
      FutureOr<void> Function()? onTimeout}) async {
    await connector.connect(this.id);
  }

  Future<Stream<List<String>?>?> getDataStream() async {
    Stream<List<String>?>? stream;
    List<bt.DiscoveredService> services =
        await serviceDiscoverer.discoverServices(this.id);
    bt.DiscoveredService service = services.firstWhere(
        (service) => service.serviceId.toString() == CUSTOM_SERVICE_UUID);
    if (service != null) {
      var characteristicId = service.characteristicIds.firstWhere(
          (element) => element.toString() == CUSTOM_CHARACTERISTIC_UUID);
      if (characteristicId != null) {
        var characteristic = bt.QualifiedCharacteristic(
            characteristicId: characteristicId,
            serviceId: service.serviceId,
            deviceId: this.id);
        _characteristic = characteristic;

        stream = serviceDiscoverer
            .subScribeToCharacteristic(characteristic)
            .map<String>((val) => Utf8Decoder().convert(val))
            .transform(TimerDataTransformer());
      }
    }

    return stream;
  }

  Future<void> stopDataStream() async {}

  Future<void> disconnect() async {
    await connector.disconnect(this.id);
  }

  @override
  set type(DeviceType _type) {
    this.type = _type;
  }
}
