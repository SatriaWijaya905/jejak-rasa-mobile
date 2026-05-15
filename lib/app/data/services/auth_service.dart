import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cek user yang sedang login
  User? get currentUser => _auth.currentUser;

  // Register
  Future<UserModel?> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: result.user!.uid,
        nama: nama,
        email: email,
        fotoProfil: '',
        role: 'user',
        jumlahResep: 0,
        pengikut: [],
        mengikuti: [],
        createdAt: DateTime.now(),
      );

      // Simpan ke Firestore
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toJson());

      return user;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  // Login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}