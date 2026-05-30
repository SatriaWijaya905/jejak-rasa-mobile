import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/buat_resep/bindings/buat_resep_binding.dart';
import '../modules/buat_resep/views/buat_resep_view.dart';
import '../modules/creator_profile/creator_profile_view.dart';
import '../modules/detail_resep/bindings/detail_resep_binding.dart';
import '../modules/detail_resep/views/detail_resep_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/edit_resep/bindings/edit_resep_binding.dart';
import '../modules/edit_resep/views/edit_resep_view.dart';
import '../modules/explore/bindings/explore_binding.dart';
import '../modules/explore/views/explore_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kategori_provinsi/bindings/kategori_provinsi_binding.dart';
import '../modules/kategori_provinsi/views/kategori_provinsi_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/all_provinces/bindings/all_provinces_binding.dart';
import '../modules/all_provinces/views/all_provinces_view.dart';
import '../modules/popular_recipes/bindings/popular_recipes_binding.dart';
import '../modules/popular_recipes/views/popular_recipes_view.dart';
import '../modules/newest_recipes/bindings/newest_recipes_binding.dart';
import '../modules/newest_recipes/views/newest_recipes_view.dart';
import '../modules/provinsi_recipes/bindings/provinsi_recipes_binding.dart';
import '../modules/provinsi_recipes/views/provinsi_recipes_view.dart';

import '../modules/privacy/bindings/privacy_binding.dart';
import '../modules/privacy/views/privacy_view.dart';
import '../modules/help/bindings/help_binding.dart';
import '../modules/help/views/help_view.dart';

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
      name: Routes.EXPLORE,
      page: () => const ExploreView(),
      binding: ExploreBinding(),
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
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.EDIT_RESEP,
      page: () => const EditResepView(),
      binding: EditResepBinding(),
    ),
    GetPage(
      name: Routes.KATEGORI_PROVINSI,
      page: () => const KategoriProvinsiView(),
      binding: KategoriProvinsiBinding(),
    ),
    GetPage(
      name: Routes.CREATOR_PROFILE,
      page: () => const CreatorProfileView(),
    ),
    GetPage(
      name: Routes.ALL_PROVINCES,
      page: () => const AllProvincesView(),
      binding: AllProvincesBinding(),
    ),
    GetPage(
      name: Routes.POPULAR_RECIPES,
      page: () => const PopularRecipesView(),
      binding: PopularRecipesBinding(),
    ),
    GetPage(
      name: Routes.NEWEST_RECIPES,
      page: () => const NewestRecipesView(),
      binding: NewestRecipesBinding(),
    ),
    GetPage(
      name: Routes.PROVINSI_RECIPES,
      page: () => const ProvinsiRecipesView(),
      binding: ProvinsiRecipesBinding(),
    ),
    // Privacy & Help
    GetPage(
      name: Routes.PRIVACY,
      page: () => const PrivacyView(),
      binding: PrivacyBinding(),
    ),
    GetPage(
      name: Routes.HELP,
      page: () => const HelpView(),
      binding: HelpBinding(),
    ),
  ];
}
