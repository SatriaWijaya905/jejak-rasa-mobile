import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/data/services/resep_service.dart';

class HomeController extends GetxController {
  final ResepService _resepService = ResepService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var currentIndex = 0.obs;
  var isLoading = false.obs;
  var resepPopuler = <ResepModel>[].obs;
  var resepTerbaru = <ResepModel>[].obs;
  var resepFeatured = <ResepModel>[].obs;
  var resepSaya = <ResepModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchResepSaya();
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

  Future<void> fetchResepSaya() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        QuerySnapshot snapshot = await _firestore
            .collection('resep')
            .where('author_uid', isEqualTo: uid)
            .get();

        resepSaya.value = snapshot.docs
            .map((doc) => ResepModel.fromJson(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}