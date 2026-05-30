import 'package:get/get.dart';

import '../controllers/popular_recipes_controller.dart';

class PopularRecipesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PopularRecipesController>(
      () => PopularRecipesController(),
      fenix: true,
    );
  }
}
