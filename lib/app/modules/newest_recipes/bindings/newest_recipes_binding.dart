import 'package:get/get.dart';

import '../controllers/newest_recipes_controller.dart';

class NewestRecipesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewestRecipesController>(
      () => NewestRecipesController(),
      fenix: true,
    );
  }
}
