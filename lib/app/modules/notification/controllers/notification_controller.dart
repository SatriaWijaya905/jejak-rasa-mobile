import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/notification_service.dart';
import '../../../data/models/resep_model.dart';
import '../../../data/models/user_model.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    _firestore
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
          print('NOTIF SNAPSHOT DOCS: ${snapshot.docs.length}');

          notifications.value = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          print('NOTIFICATIONS STATE: ${notifications.length}');

          unreadCount.value = notifications
              .where((n) => n['is_read'] == false)
              .length;
          isLoading.value = false;
        });
  }

  Future<void> markAsRead(String notifId) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await NotificationService.markAsRead(uid, notifId);
    }
  }

  Future<void> deleteOneNotification(String notifId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    if (notifId.trim().isEmpty) return;

    await NotificationService.deleteNotification(uid: uid, notifId: notifId);
  }

  Future<void> deleteAllNotifications() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await NotificationService.deleteAllNotificationsForUser(uid);
  }

  Future<void> markAllAsRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await NotificationService.markAllAsRead(uid);
  }

  Future<void> handleNotificationTap(Map<String, dynamic> notif) async {
    // 1. Mark as read
    if (notif['is_read'] == false) {
      final notifId = (notif['id'] as String?) ?? '';
      if (notifId.trim().isNotEmpty) {
        await markAsRead(notifId);
      }
    }

    // 2. Navigate based on type
    final type = notif['type'];

    // comment_recipe akan menggunakan alur navigasi yang sama seperti recipe/review
    // (butuh resep_id agar bisa memuat ResepModel)

    if (type == 'follow') {
      // Go to creator profile

      final senderUid = (notif['sender_uid'] as String?) ?? '';
      if (senderUid.trim().isEmpty) {
        Get.snackbar('Informasi', 'Data pengikut tidak tersedia');
        return;
      }
      try {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        final doc = await _firestore
            .collection('users')
            .doc(senderUid.trim())
            .get();

        Get.back(); // close loading dialog

        if (doc.exists) {
          final userMap = doc.data() as Map<String, dynamic>;
          if (!userMap.containsKey('uid') || userMap['uid'] == null) {
            userMap['uid'] = doc.id;
          }
          final creator = UserModel.fromJson(userMap);
          Get.toNamed('/creator-profile', arguments: {'creator': creator});
        } else {
          Get.snackbar(
            'Informasi',
            'Profil pengguna ini mungkin sudah dihapus',
          );
        }
      } catch (e) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Get.snackbar('Error', 'Gagal memuat profil pengguna');
      }
    } else if (type == 'recipe' ||
        type == 'new_recipe' ||
        type == 'review' ||
        type == 'comment_recipe' ||
        type == 'save_recipe') {
      final resepId = (notif['resep_id'] as String?) ?? '';
      if (resepId.trim().isEmpty) {
        Get.snackbar('Informasi', 'Data resep tidak tersedia');
        return;
      }

      // For recipe and review, we need to navigate to recipe details.
      // But we only have resep_id, while DetailResepView expects a ResepModel.
      // So we fetch the recipe first.
      try {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        final doc = await _firestore
            .collection('resep')
            .doc(resepId.trim())
            .get();

        Get.back(); // close loading dialog

        if (doc.exists) {
          final resep = ResepModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          Get.toNamed('/detail-resep', arguments: resep);
        } else {
          Get.snackbar('Informasi', 'Resep ini mungkin sudah dihapus');
        }
      } catch (e) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Get.snackbar('Error', 'Gagal memuat resep');
      }
    }
  }
}
