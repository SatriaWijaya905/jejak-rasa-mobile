import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/user_model.dart';
import 'package:jejakrasa_mobile_database/app/data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final namaController = TextEditingController();

  // Observable
  var isLogin = true.obs;
  var isLoading = false.obs;
  var isObscure = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Pastikan initial mode login
    isLogin.value = true;
  }

  void toggleLogin() {
    isLogin.value = !isLogin.value;
    // Jangan dispose controller saat toggle.
    emailController.clear();
    passwordController.clear();
    namaController.clear();
  }

  void toggleObscure() {
    isObscure.value = !isObscure.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Email dan password tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    final UserModel? user = await _authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    isLoading.value = false;

    if (user != null) {
      Get.offAllNamed('/home');
    }
  }

  Future<void> register() async {
    if (namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi');
      return;
    }

    isLoading.value = true;
    final UserModel? user = await _authService.register(
      nama: namaController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    isLoading.value = false;

    if (user == null) return;

    // Registrasi sukses: cukup balik ke mode login dalam halaman yang sama.
    Get.showSnackbar(
      const GetSnackBar(
        title: 'Berhasil',
        message: 'Registrasi berhasil, silakan login.',
        duration: Duration(seconds: 3),
      ),
    );

    // Jangan navigate ulang/recreate page.
    isLogin.value = true;

    // Clear hanya field yang tidak perlu.
    namaController.clear();
    passwordController.clear();
  }

  void loginAsGuest() {
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    // Dispose hanya ketika controller benar-benar ditutup oleh Get.
    emailController.dispose();
    passwordController.dispose();
    namaController.dispose();
    super.onClose();
  }
}
