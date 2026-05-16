import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/resep_model.dart';

class ResepService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil semua resep
  Future<List<ResepModel>> getAllResep() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('resep')
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ResepModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
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
          .where('is_popular', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ResepModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
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
          .where('is_featured', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => ResepModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  // Ambil resep terbaru
  Future<List<ResepModel>> getResepTerbaru() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('resep')
          .orderBy('created_at', descending: true)
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => ResepModel.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return [];
    }
  }

  // Tambah resep
  Future<bool> addResep(ResepModel resep) async {
    try {
      await _firestore.collection('resep').add(resep.toJson());
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    }
  }

  // Edit resep
  Future<bool> updateResep(String id, ResepModel resep) async {
    try {
      await _firestore
          .collection('resep')
          .doc(id)
          .update(resep.toJson());
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