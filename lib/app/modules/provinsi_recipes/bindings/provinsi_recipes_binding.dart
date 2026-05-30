import 'package:get/get.dart';
import '../controllers/provinsi_recipes_controller.dart';

class ProvinsiRecipesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProvinsiRecipesController>(
      () => ProvinsiRecipesController(),
    );
  }
}
