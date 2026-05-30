import 'package:get/get.dart';

import '../controllers/all_provinces_controller.dart';

class AllProvincesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllProvincesController>(() => AllProvincesController());
  }
}
