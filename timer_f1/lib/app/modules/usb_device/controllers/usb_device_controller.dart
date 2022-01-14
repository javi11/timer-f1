import 'package:get/get.dart';
import 'package:timer_f1/app/data/device_model.dart';
import 'package:timer_f1/app/data/services/usb_service.dart';

class UsbDeviceController extends GetxController {
  final USBService _usbService = Get.find<USBService>();
  Rx<Device?> connectedDevice = Rx<Device?>(null);
  RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    isConnected.bindStream(_usbService.isConnected);
    connectedDevice = _usbService.getConnectedDevice;
  }

  @override
  void onClose() {
    connectedDevice.value = null;
    isConnected.close();
    super.onClose();
  }
}
