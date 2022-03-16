import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/device_model.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/ble_controller.dart';
import 'package:timer_f1/core/pepe_timer/pepe_timer_commands.dart';
import 'package:timer_f1/core/vicent_timer/vicent_get_firmware.dart';
import 'package:timer_f1/core/vicent_timer/vicent_timer_commands.dart';
import 'package:usb_serial/usb_serial.dart';

const maxTimerDataLength = 20;
final usbControllerProvider = ChangeNotifierProvider<USBController>((ref) =>
    USBSerialController(bleController: ref.watch(bleControllerProvider)));

abstract class USBController extends ChangeNotifier {
  bool isConnected = false;
  Future<void> connect(Device device);
  Device? get connectedDevice;
  Stream<String> subscribeToDeviceDataStream();
  void disconnect();
}

class USBSerialController extends ChangeNotifier implements USBController {
  final BLEController bleController;
  UsbPort? _connectedPort;
  Device? _connectedDevice;
  late StreamSubscription<UsbEvent> _usbSubscription;
  Stream<String>? _usbDataStream;
  int _dataSubscribers = 0;
  CancelableOperation<void>? _connectionFuture;
  bool _isConnecting = false;
  bool _disposed = false;

  @override
  bool isConnected = false;

  @override
  Device? get connectedDevice => _connectedDevice;

  USBSerialController({required this.bleController}) {
    if (!Platform.isAndroid) {
      print(
          'USB_CONTROLLER: usb feature is only available for android phones.');
      return;
    }
    _usbSubscription =
        UsbSerial.usbEventStream!.listen(_handleConnectionStateUpdates);
    _connectionFuture = CancelableOperation.fromFuture(
        UsbSerial.listDevices().then((value) async {
      var device = value.firstWhere(
          (element) => element.serial == null || element.serial!.isEmpty);
      if (device.deviceId != null && !_disposed) {
        _connectionFuture = CancelableOperation.fromFuture(connect(
            Device(id: device.deviceId.toString(), name: device.deviceName)));
      }
    }).catchError((err) {
      print(
          'USB_CONTROLLER: usb is not connected, skipping usb controller. $err');
    }));
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  Future<void> connect(Device device) async {
    _isConnecting = true;
    String deviceId = device.id;

    print('USB_CONTROLLER: Adding connection port for $deviceId');
    try {
      _connectedPort = await UsbSerial.createFromDeviceId(int.parse(deviceId));

      bool openResult = await _connectedPort!.open();
      if (!openResult) {
        print('USB_CONTROLLER: Failed to open a the USB port.');
      }

      await _connectedPort?.setDTR(true);
      await _connectedPort?.setRTS(true);

      _connectedPort?.setPortParameters(
          9600, UsbPort.DATABITS_7, UsbPort.STOPBITS_1, UsbPort.PARITY_SPACE);
      _isConnecting = false;
      isConnected = true;
      _connectedDevice = device;
      _connectedDevice!.connectionState = DeviceConnection.handshaking;
    } catch (e) {
      print('USB_CONTROLLER: Could not connect to $deviceId. $e');
    }
    if (!_disposed) {
      notifyListeners();
      await _initialHandShake();
    }
  }

  @override
  void disconnect() {
    if (_connectedDevice != null) {
      clean();
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    await clean();
    await _usbSubscription.cancel();
    _disposed = true;
    super.dispose();
  }

  Future<void> clean() async {
    _usbDataStream = null;
    _connectedDevice = null;
    await _connectedPort?.close();
    _connectedPort = null;
    await _connectionFuture?.cancel();
  }

  Future<void> _sendData(String data, {String endOf = ''}) async {
    try {
      var toSend = data + endOf;
      while (toSend.length >= maxTimerDataLength) {
        //Prepare first message
        var message = toSend.substring(0, maxTimerDataLength);
        try {
          await _connectedPort?.write(Uint8List.fromList(utf8.encode(message)));
        } catch (e) {}

        //Update remaining data
        toSend = toSend.substring(maxTimerDataLength, toSend.length);

        //Wait 500 milliseconds before sending more data
        await Future.delayed(Duration(milliseconds: 1000));
      }
      //Send remaining data
      await _connectedPort?.write(Uint8List.fromList(utf8.encode(toSend)));
    } catch (ex) {
      print(
          'USB_CONTROLLER: Caught error when sending data to timer: $ex. Data: $data');
    }
  }

  Future<void> _initialHandShake() async {
    print('USB_CONTROLLER: Initial handshake for ${_connectedDevice!.id}');

    Brand brand = Brand.unknown;
    String firmware = 'unknown';
    var sub = subscribeToDeviceDataStream().handleError((error) {
      print('USB_CONTROLLER: Error on Initial handshake, $error.');
    }).listen((value) {
      var currentFirmware = getVicentFirmwareVersion(value);
      if (currentFirmware != null) {
        brand = Brand.vicent;
        firmware = currentFirmware;
      } else if (value.length == PepeTimerDataFrameLenght) {
        brand = Brand.pepe;
      }
    });

    await Future.doWhile(() async {
      print('USB_CONTROLLER: Retrying handshake.');
      await _sendData(VicentTimerCommands.getHelp, endOf: '\n');
      await Future.delayed(Duration(milliseconds: 1000));
      await _sendData(PepeTimerCommands.downloadConfiguration, endOf: '\n');

      if (brand != Brand.unknown || isConnected == false || _disposed) {
        await sub.cancel();
        return false;
      }

      //Wait two seconds before retrying again
      await Future.delayed(Duration(seconds: 10));

      return true;
    });
    if (_connectedDevice != null) {
      print(
          'USB_CONTROLLER: Device brand for ${_connectedDevice!.id} is $brand and has firmware $firmware.');
      _connectedDevice!.brand = brand;
      _connectedDevice!.firmware = firmware;
      _connectedDevice!.connectionState = DeviceConnection.connected;
      notifyListeners();
    } else {
      print('USB_CONTROLLER: Device disconnected before initial HandShake');
    }
  }

  /// Keep track of connected devices count and update the isConnected stream.
  void _handleConnectionStateUpdates(UsbEvent stateUpdate) {
    print('USB_CONTROLLER: connectedDeviceStream update: $stateUpdate');
    String? connectionState = stateUpdate.event;

    String? deviceId = stateUpdate.device?.deviceId.toString();
    String? deviceName = stateUpdate.device?.deviceName;
    // Device connected.
    if (connectionState == UsbEvent.ACTION_USB_ATTACHED &&
        deviceId != null &&
        !isConnected &&
        !_isConnecting) {
      bleController.autoReconnect = false;
      _connectionFuture = CancelableOperation.fromFuture(
          connect(Device(id: deviceId, name: deviceName!)));
      // Device disconnected.
    } else if (connectionState == UsbEvent.ACTION_USB_DETACHED &&
        _connectedDevice != null) {
      print('USB_CONTROLLER: Cleaning connectedDevice (after disconnected).');
      isConnected = false;
      disconnect();
      notifyListeners();
      bleController.autoReconnect = true;
    }
  }

  @override
  Stream<String> subscribeToDeviceDataStream() {
    _usbDataStream ??= _connectedPort?.inputStream
        ?.map((val) => String.fromCharCodes(val))
        .transform(LineSplitter())
        .asBroadcastStream(onCancel: ((subscription) {
      _dataSubscribers--;
      print(
          'USB_CONTROLLER: A subscriber leaved the data stream [$_dataSubscribers].');
    }), onListen: ((subscription) {
      _dataSubscribers++;
      print(
          'USB_CONTROLLER: A subscriber entered to the data stream [$_dataSubscribers].');
    }));

    return _usbDataStream!;
  }
}
