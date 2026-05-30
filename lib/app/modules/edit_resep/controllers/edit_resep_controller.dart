import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/data/services/cloudinary_service.dart';
import 'package:jejakrasa_mobile_database/app/utils/youtube_url_utils.dart';

import '../../home/controllers/home_controller.dart';

/// Model lokal untuk tiap step edit — menyimpan teks + XFile (gambar baru)
/// + imageUrl (gambar lama dari Firestore)
class EditableStep {
  String text;
  XFile? imageFile; // gambar baru yang dipilih dari galeri
  String? imageUrl; // URL gambar lama dari Firestore

  EditableStep({required this.text, this.imageFile, this.imageUrl});

  /// Konversi ke ResepStep untuk disimpan ke Firestore
  ResepStep toResepStep() => ResepStep(text: text, imageUrl: imageUrl);
}

class EditResepController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late ResepModel resep;

  // ─── Text Controllers ─────────────────────────────────────────────────────
  final namaController = TextEditingController();
  final waktuController = TextEditingController();
  final provinsiController = TextEditingController();
  final kesulitanController = TextEditingController();

  var selectedWilayah = ''.obs;
  var selectedProvinsi = ''.obs;
  var selectedKesulitan = ''.obs;
  final bahanController = TextEditingController();
  final langkahController = TextEditingController();

  // ─── Picker ──────────────────────────────────────────────────────────────
  final ImagePicker picker = ImagePicker();

  // ─── State ───────────────────────────────────────────────────────────────
  RxString imageUrl = ''.obs; // URL foto cover (existing atau baru)
  final youtubeVideoController = TextEditingController();

  XFile? _newCoverFile; // file cover baru (belum diupload)

  var bahanList = <String>[].obs;
  var langkahList = <EditableStep>[].obs; // pakai EditableStep, bukan ResepStep
  var isLoading = false.obs;

  void onWilayahChanged(String newWilayah) {
    if (selectedWilayah.value != newWilayah) {
      selectedWilayah.value = newWilayah;
      selectedProvinsi.value = '';
    }
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    resep = Get.arguments as ResepModel;

    namaController.text = resep.namaResep ?? '';
    waktuController.text = resep.waktuMasak ?? '';
    provinsiController.text = resep.provinsi ?? '';
    kesulitanController.text = resep.tingkatKesulitan ?? '';

    selectedWilayah.value = resep.kategoriProvinsi ?? '';
    selectedProvinsi.value = resep.provinsi ?? '';
    selectedKesulitan.value = resep.tingkatKesulitan ?? '';
    imageUrl.value = resep.fotoCover ?? '';
    youtubeVideoController.text = resep.youtubeVideoUrl ?? '';

    bahanList.value = List<String>.from(resep.bahan ?? []);

    // Konversi ResepStep lama → EditableStep agar bisa ditampilkan & diedit
    langkahList.value = (resep.langkah ?? []).map((s) {
      return EditableStep(text: s.text, imageUrl: s.imageUrl);
    }).toList();
  }

  // ─── Cover Image ─────────────────────────────────────────────────────────
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    _newCoverFile = image;
    // Preview lokal langsung tanpa upload dulu
    imageUrl.value = kIsWeb ? image.path : image.path;
    imageUrl.refresh();
  }

  /// Hapus foto cover
  void removeCoverImage() {
    _newCoverFile = null;
    imageUrl.value = '';
  }

  // ─── Step Image ──────────────────────────────────────────────────────────
  Future<void> pickStepImage(int index) async {
    if (index < 0 || index >= langkahList.length) return;
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;
    // Simpan XFile; URL lama di-clear agar preview pakai file baru
    langkahList[index] = EditableStep(
      text: langkahList[index].text,
      imageFile: image,
      imageUrl: null, // file baru menggantikan URL lama
    );
    langkahList.refresh();
  }

  void removeStepImage(int index) {
    if (index < 0 || index >= langkahList.length) return;
    langkahList[index] = EditableStep(
      text: langkahList[index].text,
      imageFile: null,
      imageUrl: null,
    );
    langkahList.refresh();
  }

  // ─── Bahan ───────────────────────────────────────────────────────────────
  void addBahan() {
    final text = bahanController.text.trim();
    if (text.isEmpty) return;
    bahanList.add(text);
    bahanController.clear();
  }

  void removeBahan(int index) => bahanList.removeAt(index);

  // ─── Langkah ─────────────────────────────────────────────────────────────
  void addLangkah() {
    final text = langkahController.text.trim();
    if (text.isEmpty) return;
    langkahList.add(EditableStep(text: text));
    langkahController.clear();
  }

  void removeLangkah(int index) => langkahList.removeAt(index);

  // ─── Save ─────────────────────────────────────────────────────────────────
  Future<void> updateResep() async {
    if (namaController.text.trim().isEmpty) {
      Get.snackbar(
        'Oops',
        'Nama resep tidak boleh kosong',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // 1. Upload cover baru jika ada
      String finalCoverUrl = resep.fotoCover ?? '';
      if (_newCoverFile != null) {
        final uploaded = await CloudinaryService.uploadImage(
          kIsWeb
              ? await _newCoverFile!.readAsBytes()
              : File(_newCoverFile!.path),
          fileName:
              'cover_${resep.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        if (uploaded != null) finalCoverUrl = uploaded;
      } else if (imageUrl.value.isEmpty) {
        // user sengaja hapus cover
        finalCoverUrl = '';
      }

      // 2. Upload gambar tiap step yang baru
      final List<Map<String, dynamic>> langkahJson = [];
      for (final step in langkahList) {
        String? stepImageUrl = step.imageUrl; // URL lama (null jika dihapus)

        if (step.imageFile != null) {
          // Ada file baru → upload
          final uploaded = await CloudinaryService.uploadImage(
            kIsWeb
                ? await step.imageFile!.readAsBytes()
                : File(step.imageFile!.path),
            fileName:
                'step_${resep.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          stepImageUrl = uploaded;
        }

        langkahJson.add({
          'text': step.text,
          if (stepImageUrl != null && stepImageUrl.isNotEmpty)
            'imageUrl': stepImageUrl,
        });
      }

      // 3. Validasi opsional link YouTube
      final normalizedYoutube = YoutubeUrlUtils.normalizeYoutubeUrl(
        youtubeVideoController.text,
      );
      if (youtubeVideoController.text.trim().isNotEmpty &&
          normalizedYoutube == null) {
        Get.snackbar(
          'Oops',
          'Link video YouTube tidak valid',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return;
      }

      // 4. Update dokumen Firestore (tidak membuat dokumen baru)
      Map<String, dynamic> updateData = {
        'nama_resep': namaController.text.trim(),
        'foto_cover': finalCoverUrl,
        'waktu_masak': waktuController.text.trim(),
        'kategori_provinsi': selectedWilayah.value,
        'provinsi': selectedProvinsi.value,
        'tingkat_kesulitan': selectedKesulitan.value,
        'bahan': bahanList.toList(),
        'langkah': langkahJson,
        'youtube_video_url': normalizedYoutube,
      };

      if (resep.status == 'rejected') {
        updateData['status'] = 'revision';
        updateData['reject_reason'] = null;
        updateData['revision_count'] = FieldValue.increment(1);
      }

      await firestore.collection('resep').doc(resep.id).update(updateData);

      // 4. Refresh home jika controller aktif
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchData();
        Get.find<HomeController>().fetchResepSaya();
      }

      Get.back();
      Get.snackbar(
        'Berhasil! 🎉',
        'Resep berhasil diperbarui',
        backgroundColor: const Color(0xFFF5A623),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────
  @override
  void onClose() {
    namaController.dispose();
    waktuController.dispose();
    provinsiController.dispose();
    kesulitanController.dispose();
    bahanController.dispose();
    langkahController.dispose();
    youtubeVideoController.dispose();
    super.onClose();
  }
}
