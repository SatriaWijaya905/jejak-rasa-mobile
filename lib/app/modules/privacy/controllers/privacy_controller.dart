import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PrivacyController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isPrivate = false.obs;
  final RxBool showInSearch = true.obs;
  final RxBool showOnlineStatus = true.obs;
  final RxBool allowMentions = true.obs;
  final RxBool isLoading = false.obs;

  String? get _uid => _auth.currentUser?.uid;

  String get _email => _auth.currentUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    _listenUserPrivacy();
  }

  void _listenUserPrivacy() {
    final uid = _uid;
    if (uid == null) return;

    _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (docSnap) {
            if (!docSnap.exists) return;
            final data = docSnap.data() as Map<String, dynamic>? ?? {};

            isPrivate.value = (data['is_private'] ?? false) as bool;
            showInSearch.value = (data['show_in_search'] ?? true) as bool;
            showOnlineStatus.value =
                (data['show_online_status'] ?? true) as bool;
            allowMentions.value = (data['allow_mentions'] ?? true) as bool;
          },
          onError: (e) {
            if (kDebugMode) debugPrint('[PrivacyController] listen error: $e');
            Get.snackbar('Error', 'Gagal memuat privacy');
          },
        );
  }

  Future<void> updateField(String field, bool value) async {
    final uid = _uid;
    if (uid == null) {
      Get.snackbar('Error', 'User tidak ditemukan');
      return;
    }

    try {
      await _firestore.collection('users').doc(uid).update({field: value});
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> clearSearchHistoryDummy() async {
    Get.snackbar('Info', 'Fitur ini belum tersedia.');
  }

  Future<void> resetPassword() async {
    final email = _email;
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email user tidak ditemukan.');
      return;
    }

    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Berhasil',
        'Link reset kata sandi sudah dikirim ke email kamu.',
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Gagal mengirim email reset password');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    final uid = _uid;
    if (uid == null) {
      Get.snackbar('Error', 'User tidak ditemukan');
      return;
    }

    final authUser = _auth.currentUser;
    if (authUser == null) {
      Get.snackbar('Error', 'Firebase user tidak tersedia');
      return;
    }

    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Akun?'),
        content: const Text(
          'Tindakan ini akan menghapus akun kamu. Ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (confirmed != true) return;

    isLoading.value = true;
    try {
      await authUser.delete();

      // Cleanup doc user (best-effort)
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (_) {
        // ignore
      }

      Get.offAllNamed('/auth');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Gagal menghapus akun');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
