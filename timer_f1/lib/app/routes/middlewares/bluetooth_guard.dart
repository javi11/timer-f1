import 'package:get/get.dart';
import 'package:timer_f1/app/data/bluetooth_model.dart';
import 'package:timer_f1/app/data/services/ble_service.dart';
import 'package:timer_f1/app/data/services/usb_service.dart';

class BluetoothGuard extends GetMiddleware {
//   Get the auth service
  final bleService = Get.find<BLEService>();
  final usbService = Get.find<USBService>();

//   The default is 0 but you can update it to any number. Please ensure you match the priority based
//   on the number of guards you have.
  @override
  int? get priority => 2;

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (bleService.getPairedDevice.value != null) {
      bleService.connect(bleService.getPairedDevice.value!);
    } else if (bleService.getBluetoothState.value != BluetoothState.scanning) {
      bleService.startScan();
    }
    return super.onPageCalled(page);
  }
}
