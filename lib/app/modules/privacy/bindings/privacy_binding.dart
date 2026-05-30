import 'package:get/get.dart';

import '../controllers/privacy_controller.dart';

class PrivacyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PrivacyController>(PrivacyController());
  }
}
