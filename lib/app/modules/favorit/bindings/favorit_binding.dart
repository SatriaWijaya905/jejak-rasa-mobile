import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/modules/favorit/controllers/favorit_controller.dart';

class FavoritBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FavoritController>(FavoritController());
  }
}