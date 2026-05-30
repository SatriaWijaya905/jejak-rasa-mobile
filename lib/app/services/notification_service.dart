import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendFollowNotification({
    required String targetUid,
    required String senderUid,
    required String senderName,
    required String senderPhoto,
  }) async {
    try {
      if (targetUid.trim().isEmpty) return;
      if (senderUid.trim().isEmpty) return;

      await _firestore
          .collection('notifications')
          .doc(targetUid.trim())
          .collection('items')
          .add({
            'type': 'follow',
            'title': 'Pengikut Baru',
            'message': '$senderName mulai mengikuti Anda',
            'sender_uid': senderUid.trim(),
            'sender_name': senderName,
            'sender_photo': senderPhoto,
            'is_read': false,
            'created_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error sending follow notification: $e');
    }
  }

  static Future<void> sendRecipeNotification({
    required String authorUid,
    required String authorName,
    required String authorPhoto,
    required String resepId,
    required String resepName,
  }) async {
    // Ambil data resep untuk kebutuhan UI large card
    String resepImage = '';
    String resepProvince = '';
    String resepWaktuMasak = '';
    double resepRating = 0.0;
    String resepDeskripsi = '';

    try {
      final resepDoc = await _firestore.collection('resep').doc(resepId).get();
      // ignore: avoid_print
      print('[new_recipe] resepDoc.exists=${resepDoc.exists} resepId=$resepId');
      if (resepDoc.exists) {
        final data = resepDoc.data() ?? <String, dynamic>{};
        print('[new_recipe] resep data keys=${data.keys.toList()}');
        print(
          '[new_recipe] foto_cover="${(data['foto_cover'] ?? '').toString()}"',
        );

        resepImage = (data['foto_cover'] ?? '').toString();
        resepProvince = (data['provinsi'] ?? data['kategori_provinsi'] ?? '')
            .toString();
        resepWaktuMasak = (data['waktu_masak'] ?? '').toString();
        resepRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        resepDeskripsi = (data['deskripsi'] ?? '').toString();
      }
    } catch (_) {
      // jika gagal ambil data resep, tetap jalan dengan default ''
    }

    try {
      if (authorUid.trim().isEmpty) return;
      if (resepId.trim().isEmpty) return;

      // Dapatkan semua follower dari author
      final followersSnapshot = await _firestore
          .collection('users')
          .doc(authorUid.trim())
          .collection('followers')
          .get();

      if (followersSnapshot.docs.isEmpty) return;

      // Buat batch untuk mengirim notifikasi (limit per batch 500)
      var batch = _firestore.batch();
      int count = 0;

      for (var doc in followersSnapshot.docs) {
        final followerUid = doc.id;
        final notifRef = _firestore
            .collection('notifications')
            .doc(followerUid)
            .collection('items')
            .doc(); // Auto generate ID

        // ignore: avoid_print
        print(
          '[new_recipe] per follower recipeImage="${resepImage}" resepId=$resepId',
        );

        batch.set(notifRef, {
          'type': 'new_recipe',
          'title': 'Resep Baru',
          // Per user request, the message should indicate the creator
          'message': '$authorName membagikan resep baru',
          'sender_uid': authorUid,
          'sender_name': authorName,
          'sender_photo': authorPhoto,
          'resep_id': resepId,
          // Fields untuk UI large card
          'recipe_id': resepId,
          'recipe_name': resepName,
          'recipe_image': resepImage,
          'province': resepProvince,
          'cook_time': resepWaktuMasak,
          'description': resepDeskripsi,
          'rating': resepRating,
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });

        count++;
        // Jika sudah mencapai batas batch (500), commit dan buat batch baru
        if (count == 500) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }

      // Commit sisa batch jika ada
      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      print('Error sending recipe notification: $e');
    }
  }

  static Future<void> sendSaveRecipeNotification({
    required String ownerUid,
    required String senderUid,
    required String senderName,
    required String senderPhoto,
    required String recipeId,
    required String recipeName,
    required String notifId,
  }) async {
    // Jangan kirim notif ke diri sendiri
    final ownerUidTrim = ownerUid.trim();
    final senderUidTrim = senderUid.trim();
    final recipeIdTrim = recipeId.trim();
    final notifIdTrim = notifId.trim();

    if (ownerUidTrim.isEmpty) return;
    if (senderUidTrim.isEmpty) return;
    if (recipeIdTrim.isEmpty) return;
    if (notifIdTrim.isEmpty) return;
    if (ownerUidTrim == senderUidTrim) return;

    try {
      await _firestore
          .collection('notifications')
          .doc(ownerUidTrim)
          .collection('items')
          .doc(notifIdTrim)
          .set({
            'type': 'save_recipe',
            'title': 'Resep Tersimpan',
            'message': '$senderName menyimpan resep $recipeName Anda',
            'sender_uid': senderUidTrim,
            'sender_name': senderName,
            'sender_photo': senderPhoto,

            // Konsisten untuk navigasi detail resep
            'resep_id': recipeIdTrim,

            // Field lama/opsional untuk kompatibilitas UI lain
            'recipe_id': recipeIdTrim,
            'recipe_name': recipeName,
            'resep_name': recipeName,

            'is_read': false,
            'created_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error sending save_recipe notification: $e');
    }
  }

  static Future<void> sendCommentRecipeNotification({
    required String recipeOwnerUid,
    required String senderUid,
    required String senderName,
    required String senderPhoto,
    required String recipeId,
    required String recipeName,
    required String notifId,
  }) async {
    // Jangan kirim notif ke diri sendiri
    if (recipeOwnerUid.trim().isEmpty) return;
    if (senderUid.trim().isEmpty) return;
    if (recipeId.trim().isEmpty) return;

    if (recipeOwnerUid == senderUid) return;

    if (notifId.trim().isEmpty) return;

    try {
      await _firestore
          .collection('notifications')
          .doc(recipeOwnerUid.trim())
          .collection('items')
          .doc(notifId.trim())
          .set({
            'type': 'comment_recipe',
            'title': 'Komentar Baru',
            'message': '$senderName mengomentari resep $recipeName Anda',
            'sender_uid': senderUid.trim(),
            'sender_name': senderName,
            'sender_photo': senderPhoto,
            'recipe_id': recipeId,
            // alias untuk kompatibilitas dengan logic existing yang pakai resep_id
            'resep_id': recipeId,
            'recipe_name': recipeName,
            'is_read': false,
            'created_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error sending comment_recipe notification: $e');
    }
  }

  static Future<void> sendReviewNotification({
    required String recipeOwnerUid,
    required String senderUid,
    required String senderName,
    required String senderPhoto,
    required String resepId,
    required String resepName,
  }) async {
    // Jangan kirim notif ke diri sendiri
    if (recipeOwnerUid.trim().isEmpty) return;
    if (senderUid.trim().isEmpty) return;
    if (resepId.trim().isEmpty) return;

    if (recipeOwnerUid == senderUid) return;

    try {
      await _firestore
          .collection('notifications')
          .doc(recipeOwnerUid.trim())
          .collection('items')
          .add({
            'type': 'review',
            'title': 'Review Baru',
            'message':
                '$senderName memberikan review pada resep $resepName Anda',
            'sender_uid': senderUid,
            'sender_name': senderName,
            'sender_photo': senderPhoto,
            'resep_id': resepId,
            'is_read': false,
            'created_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error sending review notification: $e');
    }
  }

  static Future<void> deleteNotification({
    required String uid,
    required String notifId,
  }) async {
    try {
      final uidTrim = uid.trim();
      final notifIdTrim = notifId.trim();
      if (uidTrim.isEmpty) return;
      if (notifIdTrim.isEmpty) return;

      await _firestore
          .collection('notifications')
          .doc(uidTrim)
          .collection('items')
          .doc(notifIdTrim)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  static Future<void> deleteAllNotificationsForUser(
    String uid, {
    int batchSize = 200,
  }) async {
    try {
      final uidTrim = uid.trim();
      if (uidTrim.isEmpty) return;

      final colRef = _firestore
          .collection('notifications')
          .doc(uidTrim)
          .collection('items');

      while (true) {
        final query = await colRef
            .orderBy(FieldPath.documentId)
            .limit(batchSize)
            .get();

        if (query.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final doc in query.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  static Future<void> markAsRead(String uid, String notifId) async {
    try {
      final uidTrim = uid.trim();
      final notifIdTrim = notifId.trim();
      if (uidTrim.isEmpty) return;
      if (notifIdTrim.isEmpty) return;

      await _firestore
          .collection('notifications')
          .doc(uidTrim)
          .collection('items')
          .doc(notifIdTrim)
          .update({'is_read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> markAllAsRead(String uid, {int batchSize = 200}) async {
    try {
      final uidTrim = uid.trim();
      if (uidTrim.isEmpty) return;

      final colRef = _firestore
          .collection('notifications')
          .doc(uidTrim)
          .collection('items');

      while (true) {
        final query = await colRef
            .where('is_read', isEqualTo: false)
            .orderBy(FieldPath.documentId)
            .limit(batchSize)
            .get();

        if (query.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final doc in query.docs) {
          batch.update(doc.reference, {'is_read': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
