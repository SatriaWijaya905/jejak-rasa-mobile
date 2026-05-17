import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/modules/detail_resep/controllers/detail_resep_controller.dart';
import 'package:jejakrasa_mobile_database/app/modules/favorit/controllers/favorit_controller.dart';

class DetailResepBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DetailResepController>(DetailResepController());
    Get.put<FavoritController>(FavoritController());
  }
}