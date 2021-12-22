import 'dart:async';
import 'package:get/get.dart';
import 'package:timer_f1/app/data/device_model.dart';
import 'package:timer_f1/app/data/services/usb_service.dart';
import 'package:usb_serial/usb_serial.dart';

class USBSerial extends USBService {
  final RxBool _isConnected = false.obs;
  final Rx<Device?> _connectedDevice = Rx(null);
  late StreamSubscription<UsbEvent> usbSubscription;
  UsbPort? _connectedPort;

  @override
  Future<void> onInit() async {
    usbSubscription =
        UsbSerial.usbEventStream!.listen(_handleConnectionStateUpdates);
    super.onInit();
  }

  @override
  Stream<bool> get isConnected => _isConnected.stream;

  @override
  Rx<Device?> get getConnectedDevice => _connectedDevice;

  @override
  Future<void> connect(Device device) async {
    String deviceId = device.id;
    _connectedDevice.value = device;

    print('SERVICE: Adding connection port for $deviceId');
    _connectedPort = await UsbSerial.createFromDeviceId(int.parse(deviceId));

    bool openResult = await _connectedPort!.open();
    if (!openResult) {
      print('SERVICE: Failed to open a the USB port -------');
    }

    await _connectedPort?.setDTR(true);
    await _connectedPort?.setRTS(true);

    _connectedPort?.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
  }

  @override
  void disconnect() {
    if (_connectedDevice.value != null) {
      _connectedDevice.close();
      _connectedDevice.value = null;
      _connectedPort = null;
    }
  }

  @override
  void onClose() {
    usbSubscription.cancel();
    super.onClose();
  }

  /// Keep track of connected devices count and update the isConnected stream.
  Future<void> _handleConnectionStateUpdates(UsbEvent stateUpdate) async {
    print('SERVICE: connectedDeviceStream update: $stateUpdate');
    String? connectionState = stateUpdate.event;

    String? deviceId = stateUpdate.device?.deviceId.toString();
    String? deviceName = stateUpdate.device?.deviceName;
    // Device connected.
    if (connectionState == UsbEvent.ACTION_USB_ATTACHED && deviceId != null) {
      await connect(Device(id: deviceId, name: deviceName!));
      // Device disconnected.
    } else if (connectionState == UsbEvent.ACTION_USB_DETACHED) {
      if (!_connectedDevice.isBlank!) {
        print(
            'SERVICE: Clearing _connectedDevice (after disconnected) -------');
        _connectedDevice.value = null;
        _isConnected.value = false;
      }
    }
  }
}