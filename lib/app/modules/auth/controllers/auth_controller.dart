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

  // Toggle login/register
  void toggleLogin() {
    isLogin.value = !isLogin.value;
    emailController.clear();
    passwordController.clear();
    namaController.clear();
  }

  // Toggle show/hide password
  void toggleObscure() {
    isObscure.value = !isObscure.value;
  }

  // Login
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Email dan password tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    UserModel? user = await _authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    isLoading.value = false;

    if (user != null) {
      Get.offAllNamed('/home');
    }
  }

  // Register
  Future<void> register() async {
    if (namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi');
      return;
    }

    isLoading.value = true;
    UserModel? user = await _authService.register(
      nama: namaController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    isLoading.value = false;

    if (user != null) {
      Get.offAllNamed('/home');
    }
  }

  // Login sebagai guest
  void loginAsGuest() {
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    namaController.dispose();
    super.onClose();
  }
}