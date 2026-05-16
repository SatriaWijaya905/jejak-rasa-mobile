import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';

class DetailResepController extends GetxController {
  var resep = Rxn<ResepModel>();

  @override
  void onInit() {
    super.onInit();
    // Ambil data resep yang dikirim dari halaman sebelumnya
    resep.value = Get.arguments as ResepModel?;
  }
}