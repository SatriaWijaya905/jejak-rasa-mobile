import 'package:get/get.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;

  void nextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
    } else {
      Get.offAllNamed('/auth');
    }
  }

  void skip() {
    Get.offAllNamed('/auth');
  }

  void mulaiEksplorasi() {
    Get.offAllNamed('/auth');
  }
}