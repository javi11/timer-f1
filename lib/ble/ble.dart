import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:timerf1c/ble/ble_device_connector.dart';
import 'package:timerf1c/ble/ble_device_interactor.dart';
import 'package:timerf1c/ble/ble_logger.dart';
import 'package:timerf1c/ble/ble_scanner.dart';
import 'package:timerf1c/ble/ble_status_monitor.dart';

final _bleLogger = BleLogger();
final _ble = FlutterReactiveBle();
final scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
final monitor = BleStatusMonitor(_ble);
final connector = BleDeviceConnector(
  ble: _ble,
  logMessage: _bleLogger.addToLog,
);
final serviceDiscoverer = BleDeviceInteractor(
  bleDiscoverServices: _ble.discoverServices,
  readCharacteristic: _ble.readCharacteristic,
  writeWithResponse: _ble.writeCharacteristicWithResponse,
  writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
  subscribeToCharacteristic: _ble.subscribeToCharacteristic,
  logMessage: _bleLogger.addToLog,
);
