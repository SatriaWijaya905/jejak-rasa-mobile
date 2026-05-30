import 'package:get/get.dart';

import '../controllers/help_controller.dart';

class HelpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HelpController>(HelpController());
  }
}
