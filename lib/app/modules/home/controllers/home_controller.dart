import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/data/services/resep_service.dart';

class HomeController extends GetxController {
  final ResepService _resepService = ResepService();

  var currentIndex = 0.obs;
  var isLoading = false.obs;
  var resepPopuler = <ResepModel>[].obs;
  var resepTerbaru = <ResepModel>[].obs;
  var resepFeatured = <ResepModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    resepPopuler.value = await _resepService.getResepPopuler();
    resepTerbaru.value = await _resepService.getResepTerbaru();
    resepFeatured.value = await _resepService.getResepFeatured();
    isLoading.value = false;
  }
}