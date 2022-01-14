import 'package:get/get.dart';
import 'package:timer_f1/app/modules/bluetooth/controllers/connecting_animation_controller.dart';

import '../controllers/bluetooth_controller.dart';

class BluetoothBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BluetoothController>(() => BluetoothController(), fenix: true);

    Get.lazyPut<ConnectingAnimationController>(
        () => ConnectingAnimationController());
  }
}
