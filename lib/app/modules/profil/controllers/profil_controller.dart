import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/user_model.dart';

class ProfilController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var user = Rxn<UserModel>();
  var isLoading = false.obs;
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
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

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed('/auth');
  }
}