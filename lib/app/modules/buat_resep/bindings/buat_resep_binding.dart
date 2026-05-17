import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/modules/buat_resep/controllers/buat_resep_controller.dart';

class BuatResepBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BuatResepController>(BuatResepController());
  }
}