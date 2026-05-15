import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('Splash onInit dipanggil');
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    print('Mulai delay...');
    await Future.delayed(const Duration(seconds: 3));
    print('Delay selesai, navigasi ke onboarding');
    Get.offAllNamed('/onboarding');
  }
}