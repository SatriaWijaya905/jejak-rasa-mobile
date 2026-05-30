import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/resep_model.dart';
import '../../services/notification_service.dart';

class ResepService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil semua resep
  Future<List<ResepModel>> getAllResep() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('resep')
          .where('status', isEqualTo: 'approved')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                ResepModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  // Ambil resep populer
  Future<List<ResepModel>> getResepPopuler() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('resep')
          .where('status', isEqualTo: 'approved')
          .where('is_popular', isEqualTo: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                ResepModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  // Ambil resep featured (banner)
  Future<List<ResepModel>> getResepFeatured() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('resep')
          .where('status', isEqualTo: 'approved')
          .where('is_featured', isEqualTo: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                ResepModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  /// Stream resep terbaru (realtime)
  ///
  /// Requirement wajib:
  /// - where status == 'approved'
  /// - orderBy approved_at desc
  ///
  /// Fallback sorting dilakukan di sisi client untuk dokumen dengan approved_at == null.
  Stream<List<ResepModel>> streamResepTerbaru({int limit = 5}) {
    final query = _firestore
        .collection('resep')
        .where('status', isEqualTo: 'approved')
        .limit(limit)
        .snapshots();

    return query.map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
          .toList();

      // TEST 1: debug sementara audit tab "Terbaru"
      // (Tidak mempengaruhi UI)
      // ignore: avoid_print
      print(
        '[JejakRasa][TEST1][streamResepTerbaru] snapshot.docs.length=${snapshot.docs.length} size=${snapshot.size}',
      );
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final approvedAtRaw = d['approved_at'];
        final statusRaw = d['status'];
        // ignore: avoid_print
        print(
          '[JejakRasa][TEST1][streamResepTerbaru] docId=${doc.id} approved_at=$approvedAtRaw status=$statusRaw',
        );
      }

      // Fallback sorting aman ketika approved_at null
      list.sort((a, b) {
        final aDate = a.approvedAt ?? a.createdAt;
        final bDate = b.approvedAt ?? b.createdAt;
        final aSafe = aDate ?? DateTime(2000);
        final bSafe = bDate ?? DateTime(2000);
        return bSafe.compareTo(aSafe);
      });

      return list;
    });
  }

  // Tambah resep
  Future<bool> addResep(ResepModel resep) async {
    try {
      final docRef = await _firestore.collection('resep').add(resep.toJson());

      // Send notification to followers
      if (resep.authorUid != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(resep.authorUid)
            .get();
        final userData = userDoc.data();
        if (userData != null) {
          await NotificationService.sendRecipeNotification(
            authorUid: resep.authorUid!,
            authorName: userData['nama'] ?? 'Creator',
            authorPhoto: userData['foto_profil'] ?? '',
            resepId: docRef.id,
            resepName: resep.namaResep ?? 'Resep Baru',
          );
        }
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }

  // Edit resep
  Future<bool> updateResep(String id, ResepModel resep) async {
    try {
      await _firestore.collection('resep').doc(id).update(resep.toJson());
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }

  // Hapus resep
  Future<bool> deleteResep(String id) async {
    try {
      await _firestore.collection('resep').doc(id).delete();
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }
}
