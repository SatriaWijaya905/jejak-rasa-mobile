import 'package:get/get.dart';

import '../controllers/edit_resep_controller.dart';

class EditResepBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditResepController>(
      () => EditResepController(),
    );
  }
}