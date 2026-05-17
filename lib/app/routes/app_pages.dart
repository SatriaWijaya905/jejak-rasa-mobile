import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/modules/auth/bindings/auth_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/auth/views/auth_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/buat_resep/bindings/buat_resep_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/buat_resep/views/buat_resep_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/detail_resep/bindings/detail_resep_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/detail_resep/views/detail_resep_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/bindings/home_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/views/home_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/onboarding/views/onboarding_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/splash/bindings/splash_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/splash/views/splash_view.dart';

part 'app_routes.dart';

abstract class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_RESEP,
      page: () => const DetailResepView(),
      binding: DetailResepBinding(),
    ),
    GetPage(
      name: Routes.BUAT_RESEP,
      page: () => const BuatResepView(),
      binding: BuatResepBinding(),
    ),
  ];
}