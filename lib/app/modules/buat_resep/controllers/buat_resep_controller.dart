import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jejakrasa_mobile_database/app/data/services/cloudinary_service.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/controllers/home_controller.dart';
import 'package:jejakrasa_mobile_database/app/services/notification_service.dart';
import 'package:jejakrasa_mobile_database/app/utils/youtube_url_utils.dart';

class BuatResepStep {
  String text;
  XFile? imageFile;
  String? imageUrl;

  BuatResepStep({required this.text, this.imageFile, this.imageUrl});

  Map<String, dynamic> toJson() {
    return {'text': text, if (imageUrl != null) 'imageUrl': imageUrl};
  }
}

class BuatResepController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final namaResepController = TextEditingController();

  final waktuMasakController = TextEditingController();

  final bahanController = TextEditingController();

  // Link video youtube (opsional)
  final youtubeVideoController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  RxString imageUrl = ''.obs;

  var selectedWilayah = ''.obs;

  var selectedProvinsi = ''.obs;

  var selectedKesulitan = ''.obs;

  var isLoading = false.obs;

  var bahanList = <String>[].obs;

  var langkahList = <BuatResepStep>[].obs;

  final List<String> kesulitanList = ['Mudah', 'Menengah', 'Sulit'];

  void onWilayahChanged(String newWilayah) {
    if (selectedWilayah.value != newWilayah) {
      selectedWilayah.value = newWilayah;
      selectedProvinsi.value = '';
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),

      barrierDismissible: false,
    );

    final url = await CloudinaryService.uploadImage(
      kIsWeb ? await image.readAsBytes() : File(image.path),

      fileName: 'resep_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    Get.back();

    if (url != null) {
      imageUrl.value = url;

      Get.snackbar('Berhasil', 'Foto resep berhasil diupload');
    }
  }

  void addBahan(String bahan) {
    if (bahan.isNotEmpty) {
      bahanList.add(bahan);

      bahanController.clear();
    }
  }

  void removeBahan(int index) {
    bahanList.removeAt(index);
  }

  void addLangkah(String langkah) {
    if (langkah.isNotEmpty) {
      langkahList.add(BuatResepStep(text: langkah));
    }
  }

  Future<void> pickStepImage(int index) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      langkahList[index].imageFile = image;
      langkahList.refresh();
    }
  }

  void removeStepImage(int index) {
    langkahList[index].imageFile = null;
    langkahList[index].imageUrl = null;
    langkahList.refresh();
  }

  void removeLangkah(int index) {
    langkahList.removeAt(index);
  }

  Future<void> simpanResep() async {
    if (namaResepController.text.isEmpty ||
        selectedWilayah.value.isEmpty ||
        selectedProvinsi.value.isEmpty ||
        selectedKesulitan.value.isEmpty ||
        waktuMasakController.text.isEmpty ||
        bahanList.isEmpty ||
        imageUrl.value.isEmpty) {
      Get.snackbar(
        'Error',

        'Semua field harus diisi! Pastikan foto cover sudah diupload.',
      );

      return;
    }

    isLoading.value = true;

    try {
      final uid = _auth.currentUser?.uid;

      final normalizedYoutube = YoutubeUrlUtils.normalizeYoutubeUrl(
        youtubeVideoController.text,
      );
      if (youtubeVideoController.text.trim().isNotEmpty &&
          normalizedYoutube == null) {
        Get.snackbar('Error', 'Link video YouTube tidak valid');
        isLoading.value = false;
        return;
      }

      // Upload gambar langkah jika ada
      for (var step in langkahList) {
        if (step.imageFile != null) {
          final url = await CloudinaryService.uploadImage(
            kIsWeb
                ? await step.imageFile!.readAsBytes()
                : File(step.imageFile!.path),
            fileName: 'step_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          if (url != null) {
            step.imageUrl = url;
          }
        }
      }

      final resepDocRef = await _firestore.collection('resep').add({
        'nama_resep': namaResepController.text,

        'foto_cover': imageUrl.value,

        'provinsi': selectedProvinsi.value,

        // kategori untuk query halaman "Kuliner $kategori"
        'kategori_provinsi': selectedWilayah.value,

        'waktu_masak': waktuMasakController.text,

        'tingkat_kesulitan': selectedKesulitan.value,

        'rating': 0.0,

        'jumlah_review': 0,

        'is_popular': false,

        'is_featured': false,

        'bahan': bahanList,

        'langkah': langkahList.map((e) => e.toJson()).toList(),

        'youtube_video_url': normalizedYoutube,

        'author_uid': uid,

        'created_at': Timestamp.now(),

        'status': 'pending',
      });

      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'jumlah_resep': FieldValue.increment(1),
        });

        // Trigger notification new_recipe ke seluruh followers creator
        try {
          final authorDoc = await _firestore.collection('users').doc(uid).get();
          final authorData = authorDoc.data() ?? <String, dynamic>{};

          final authorName = authorData['nama'] as String? ?? 'Creator';
          final authorPhoto = authorData['foto_profil'] as String? ?? '';

          // Followers dokumen berada di: users/{creatorUid}/followers/{followerUid}
          final followersSnapshot = await _firestore
              .collection('users')
              .doc(uid)
              .collection('followers')
              .get();

          // Debug log
          // ignore: avoid_print
          print(
            '[new_recipe] trigger start: creatorUid=$uid resepId=${resepDocRef.id}',
          );
          // ignore: avoid_print
          print(
            '[new_recipe] recipeName=${namaResepController.text} recipeImage=${imageUrl.value}',
          );
          // ignore: avoid_print
          print(
            '[new_recipe] followers count=${followersSnapshot.docs.length}',
          );

          await NotificationService.sendRecipeNotification(
            authorUid: uid,
            authorName: authorName,
            authorPhoto: authorPhoto,
            resepId: resepDocRef.id,
            resepName: namaResepController.text,
          );

          // ignore: avoid_print
          print('[new_recipe] write success for followers.');
          // ignore: avoid_print
          print(
            '[new_recipe] notifications sent to followers for resepId=${resepDocRef.id}',
          );
        } catch (e) {
          // ignore: avoid_print
          print('[new_recipe] failed sending notification: $e');
        }
      }

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchData();
      }

      Get.back();

      Get.snackbar('Sukses', 'Resep berhasil ditambahkan!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    namaResepController.dispose();

    waktuMasakController.dispose();

    bahanController.dispose();

    youtubeVideoController.dispose();

    super.onClose();
  }
}
