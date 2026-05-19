import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/data/models/user_model.dart';

class ProfilController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var user = Rxn<UserModel>();
  var isLoading = false.obs;
  var selectedTab = 0.obs;
  var resepSaya = <ResepModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchResepSaya();
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(uid)
            .get();
        user.value = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    isLoading.value = false;
  }

  Future<void> fetchResepSaya() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        QuerySnapshot snapshot = await _firestore
            .collection('resep')
            .where('author_uid', isEqualTo: uid)
            .get();

        resepSaya.value = snapshot.docs
            .map((doc) => ResepModel.fromJson(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed('/auth');
  }
}