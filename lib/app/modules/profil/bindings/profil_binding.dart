import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/modules/profil/controllers/profil_controller.dart';

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProfilController>(ProfilController());
  }
}