import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/services/notification_service.dart';

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
      if (uid == null || uid.trim().isEmpty) {
        favoritList.clear();
        return;
      }

      DocumentSnapshot doc = await _firestore
          .collection('favorit')
          .doc(uid)
          .get();

      if (doc.exists) {
        final raw = doc['resep_ids'];
        final resepIds = (raw is List ? raw : <dynamic>[])
            .map((e) => e?.toString() ?? '')
            .where((id) => id.trim().isNotEmpty)
            .toList();

        List<ResepModel> list = [];
        for (String id in resepIds) {
          if (id.trim().isEmpty) continue;

          DocumentSnapshot resepDoc = await _firestore
              .collection('resep')
              .doc(id.trim())
              .get();
          if (resepDoc.exists) {
            final data = resepDoc.data();
            if (data != null) {
              list.add(
                ResepModel.fromJson(data as Map<String, dynamic>, resepDoc.id),
              );
            }
          }
        }
        favoritList.value = list;
      } else {
        favoritList.clear();
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
      if (uid == null || uid.trim().isEmpty) return;
      if (resepId.trim().isEmpty) return;

      DocumentReference ref = _firestore.collection('favorit').doc(uid);
      DocumentSnapshot doc = await ref.get();

      bool isSaving = false;

      if (doc.exists) {
        List<String> ids = List<String>.from(doc['resep_ids'] ?? []);
        if (ids.contains(resepId)) {
          ids.remove(resepId);
          Get.snackbar('Info', 'Resep dihapus dari favorit');
        } else {
          ids.add(resepId);
          isSaving = true;
          Get.snackbar('Info', 'Resep ditambahkan ke favorit');
        }
        await ref.update({'resep_ids': ids});
      } else {
        await ref.set({
          'resep_ids': [resepId],
        });
        isSaving = true;
        Get.snackbar('Info', 'Resep ditambahkan ke favorit');
      }

      // Send save_recipe notification only when user saves (not unsave)
      if (isSaving) {
        final resepDoc = await _firestore
            .collection('resep')
            .doc(resepId)
            .get();
        if (resepDoc.exists) {
   
          final resepData = resepDoc.data() as Map<String, dynamic>?;

          final ownerUid = (resepData?['author_uid'] as String?) ?? '';
          final recipeName = (resepData?['nama_resep'] as String?) ?? 'Resep';

          if (ownerUid.trim().isNotEmpty && ownerUid.trim() != uid.trim()) {
            final senderDoc = await _firestore
                .collection('users')
                .doc(uid)
                .get();
            final senderData = senderDoc.data() as Map<String, dynamic>?;

            final senderName = senderData?['nama']?.toString() ?? 'Pengguna';
            final senderPhoto = senderData?['foto_profil']?.toString() ?? '';

            final notifId = 'save_recipe_${resepId}_$uid';

            await NotificationService.sendSaveRecipeNotification(
              ownerUid: ownerUid,
              senderUid: uid,
              senderName: senderName,
              senderPhoto: senderPhoto,
              recipeId: resepId,
              recipeName: recipeName,
              notifId: notifId,
            );
          }
        }
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
