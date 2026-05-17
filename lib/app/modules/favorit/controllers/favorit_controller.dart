import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';

class FavoritController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var favoritList = <ResepModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorit();
  }

  Future<void> fetchFavorit() async {
    isLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot doc = await _firestore
            .collection('favorit')
            .doc(uid)
            .get();

        if (doc.exists) {
          List<String> resepIds =
              List<String>.from(doc['resep_ids'] ?? []);

          List<ResepModel> list = [];
          for (String id in resepIds) {
            DocumentSnapshot resepDoc =
                await _firestore.collection('resep').doc(id).get();
            if (resepDoc.exists) {
              list.add(ResepModel.fromJson(
                  resepDoc.data() as Map<String, dynamic>, resepDoc.id));
            }
          }
          favoritList.value = list;
        }
      }
    } catch (e) {
      print('Error fetchFavorit: $e');
      Get.snackbar('Error', e.toString());
    }
    isLoading.value = false;
  }

  Future<void> toggleFavorit(String resepId) async {
    print('toggleFavorit dipanggil dengan id: $resepId');
    try {
      final uid = _auth.currentUser?.uid;
      print('uid: $uid');
      if (uid == null) return;

      DocumentReference ref = _firestore.collection('favorit').doc(uid);
      DocumentSnapshot doc = await ref.get();

      if (doc.exists) {
        List<String> ids = List<String>.from(doc['resep_ids'] ?? []);
        if (ids.contains(resepId)) {
          ids.remove(resepId);
          Get.snackbar('Info', 'Resep dihapus dari favorit');
        } else {
          ids.add(resepId);
          Get.snackbar('Info', 'Resep ditambahkan ke favorit');
        }
        await ref.update({'resep_ids': ids});
      } else {
        await ref.set({'resep_ids': [resepId]});
        Get.snackbar('Info', 'Resep ditambahkan ke favorit');
      }
      print('toggleFavorit selesai!');
      fetchFavorit();
    } catch (e) {
      print('Error toggleFavorit: $e');
      Get.snackbar('Error', e.toString());
    }
  }

  bool isFavorit(String resepId) {
    return favoritList.any((r) => r.id == resepId);
  }
}