import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:jejakrasa_mobile_database/app/data/services/cloudinary_service.dart';
import '../../profil/controllers/profil_controller.dart';
import '../../../data/models/user_model.dart';

class EditProfileController extends GetxController {
  TextEditingController fotoProfilController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();

  final bioController = TextEditingController();

  final locationController = TextEditingController();

  final instagramController = TextEditingController();

  final youtubeController = TextEditingController();

  final websiteController = TextEditingController();

  RxBool isLoading = false.obs;

  final ImagePicker picker = ImagePicker();

  RxString imageUrl = ''.obs;

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),

      barrierDismissible: false,
    );

    final url = await CloudinaryService.uploadImage(
      // di web, image.path bisa tidak tersedia; service akan menangani via bytes
      kIsWeb ? await image.readAsBytes() : File(image.path),
      fileName: 'foto_profil_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    Get.back();

    if (url != null) {
      // UPDATE UI
      imageUrl.value = url;

      // UPDATE TEXTFIELD
      fotoProfilController.text = url;

      final uid = _auth.currentUser?.uid;

      if (uid != null) {
        try {
          // SAVE FIRESTORE
          await _firestore.collection('users').doc(uid).update({
            'foto_profil': url,
          });
        } catch (e) {
          Get.snackbar('Error', 'Gagal update foto profil: ${e.toString()}');
          return;
        }

        // Refresh profil agar foto berubah langsung
        final profilController = Get.isRegistered<ProfilController>()
            ? Get.find<ProfilController>()
            : null;

        if (profilController != null) {
          final currentUser = profilController.user.value;
          if (currentUser != null) {
            profilController.user.value = UserModel(
              uid: currentUser.uid,
              nama: currentUser.nama,
              email: currentUser.email,
              fotoProfil: url,
              role: currentUser.role,
              instagram: currentUser.instagram,
              tiktok: currentUser.tiktok,
              bio: currentUser.bio,
              alamat: currentUser.alamat,
              jumlahResep: currentUser.jumlahResep,
              pengikut: currentUser.pengikut,
              mengikuti: currentUser.mengikuti,
              createdAt: currentUser.createdAt,
            );
          }

          // pastikan state terbaru dari Firestore
          await profilController.fetchUserData();
        }
      }

      Get.snackbar('Berhasil', 'Foto profil berhasil diupdate');
    }
  }

  // =========================
  // INIT
  // =========================

  @override
  void onInit() {
    super.onInit();

    loadProfile();
  }

  // =========================
  // LOAD PROFILE
  // =========================

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final uid = _auth.currentUser?.uid;

      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;

        nameController.text = data['nama'] ?? '';

        bioController.text = data['bio'] ?? '';

        locationController.text = data['alamat'] ?? '';

        instagramController.text = data['instagram'] ?? '';

        youtubeController.text = data['youtube'] ?? '';

        websiteController.text = data['website'] ?? '';

        imageUrl.value = data['foto_profil'] ?? '';

        fotoProfilController.text = data['foto_profil'] ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // SAVE PROFILE
  // =========================

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      final uid = _auth.currentUser?.uid;

      if (uid == null) return;

      await _firestore.collection('users').doc(uid).set({
        "nama": nameController.text,
        "bio": bioController.text,
        "alamat": locationController.text,
        "instagram": instagramController.text,
        "youtube": youtubeController.text,
        "website": websiteController.text,
        "foto_profil": imageUrl.value,
      }, SetOptions(merge: true));

      // Sinkronkan reactive state profil agar nama langsung berubah.
      if (Get.isRegistered<ProfilController>()) {
        final profilController = Get.find<ProfilController>();
        await profilController.fetchUserData();
      }

      // Setelah save, kembali ke halaman Profil.
      Get.back();

      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',

        backgroundColor: Colors.orange,

        colorText: Colors.white,

        snackPosition: SnackPosition.TOP,

        margin: const EdgeInsets.all(16),

        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void onClose() {
    nameController.dispose();

    bioController.dispose();

    locationController.dispose();

    instagramController.dispose();

    youtubeController.dispose();

    websiteController.dispose();

    super.onClose();
  }
}
