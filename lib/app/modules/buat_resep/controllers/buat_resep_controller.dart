import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/controllers/home_controller.dart';

class BuatResepController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final namaResepController = TextEditingController();
  final waktuMasakController = TextEditingController();
  final bahanController = TextEditingController();

  var selectedProvinsi = ''.obs;
  var selectedKesulitan = ''.obs;
  var isLoading = false.obs;
  var bahanList = <String>[].obs;
  var langkahList = <String>[].obs;

  final List<String> provinsiList = [
    'Jawa', 'Sumatera', 'Bali', 'Sulawesi', 'Papua',
    'Kalimantan', 'Nusa Tenggara', 'Maluku'
  ];

  final List<String> kesulitanList = ['Mudah', 'Menengah', 'Sulit'];

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
      langkahList.add(langkah);
    }
  }

  void removeLangkah(int index) {
    langkahList.removeAt(index);
  }

  Future<void> simpanResep() async {
    if (namaResepController.text.isEmpty ||
        selectedProvinsi.value.isEmpty ||
        selectedKesulitan.value.isEmpty ||
        waktuMasakController.text.isEmpty ||
        bahanList.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi!');
      return;
    }

    isLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid;

      List<Map<String, dynamic>> langkahData = langkahList
          .asMap()
          .entries
          .map((e) => {
                'urutan': e.key + 1,
                'deskripsi': e.value,
                'foto': '',
              })
          .toList();

      await _firestore.collection('resep').add({
        'nama_resep': namaResepController.text,
        'foto_cover': '',
        'provinsi': selectedProvinsi.value,
        'waktu_masak': waktuMasakController.text,
        'tingkat_kesulitan': selectedKesulitan.value,
        'rating': 0.0,
        'jumlah_review': 0,
        'is_popular': false,
        'is_featured': false,
        'bahan': bahanList,
        'langkah': langkahData,
        'author_uid': uid,
        'created_at': Timestamp.now(),
      });

      // Update jumlah resep user
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'jumlah_resep': FieldValue.increment(1),
        });
      }

      // Refresh home controller
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
    super.onClose();
  }
}