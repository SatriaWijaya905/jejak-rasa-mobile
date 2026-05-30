import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/controllers/home_controller.dart';

class DetailResepController extends GetxController {
  var resep = Rxn<ResepModel>();
  var creator = Rxn<UserModel>();
  var resepCreator = <ResepModel>[].obs;
  var isLoadingCreator = false.obs;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments as ResepModel?;
    resep.value = arg;

    final authorUid = resep.value?.authorUid;
    if (authorUid != null && authorUid.trim().isNotEmpty) {
      fetchCreator(authorUid);
    }

    // pastikan resep yang ditampilkan benar sesuai id arguments
    final id = resep.value?.id;
    if (id != null && id.trim().isNotEmpty) {
      fetchResepById(id);
    }
  }

  Future<void> fetchResepById(String id) async {
    try {
      final doc = await firestore.collection('resep').doc(id).get();
      if (doc.exists) {
        resep.value = ResepModel.fromFirestore(doc);
        if (resep.value?.authorUid != null) {
          fetchCreator(resep.value!.authorUid!);
        }
      }
    } catch (_) {}
  }

  Future<void> fetchCreator(String uid) async {
    try {
      final safeUid = uid.trim();
      if (safeUid.isEmpty) {
        creator.value = null;
        return;
      }

      isLoadingCreator.value = true;
      final doc = await firestore.collection('users').doc(safeUid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          creator.value = UserModel.fromJson(data);
        }
      }

      // fetch resep creator
      final snap = await firestore
          .collection('resep')
          .where('author_uid', isEqualTo: safeUid)
          .limit(6)
          .get();
      resepCreator.value = snap.docs
          .map((d) => ResepModel.fromJson(d.data(), d.id))
          .where((r) => r.id != resep.value?.id)
          .toList();
    } catch (_) {
    } finally {
      isLoadingCreator.value = false;
    }
  }

  Future<void> hapusResep(String id) async {
    try {
      await firestore.collection('resep').doc(id).delete();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchData();
        Get.find<HomeController>().fetchResepSaya();
      }
      Get.back();
      Get.back();
      Get.snackbar('Berhasil', 'Resep berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
