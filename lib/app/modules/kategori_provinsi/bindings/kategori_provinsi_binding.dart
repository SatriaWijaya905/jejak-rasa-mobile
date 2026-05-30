import 'package:get/get.dart';

import '../controllers/kategori_provinsi_controller.dart';

class KategoriProvinsiBinding
    extends Bindings {

  @override
  void dependencies() {

    Get.lazyPut<
        KategoriProvinsiController>(

      () =>
          KategoriProvinsiController(),
    );
  }
}