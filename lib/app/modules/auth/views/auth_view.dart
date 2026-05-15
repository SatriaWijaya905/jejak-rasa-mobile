import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEE),
      body: SafeArea(
        child: Obx(() => controller.isLogin.value
            ? _buildLogin()
            : _buildRegister()),
      ),
    );
  }

  // ===== HALAMAN LOGIN =====
  Widget _buildLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'JR',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Jejak Rasa',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF5A623),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'Selamat Datang!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Login untuk mulai eksplorasi kuliner',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          // Email
          TextField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Password
          Obx(() => TextField(
            controller: controller.passwordController,
            obscureText: controller.isObscure.value,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(controller.isObscure.value
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: controller.toggleObscure,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )),
          const SizedBox(height: 24),
          // Tombol Login
          Obx(() => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          )),
          const SizedBox(height: 16),
          // Ke Register
          Center(
            child: TextButton(
              onPressed: controller.toggleLogin,
              child: Text(
                'Belum punya akun? Daftar sekarang',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF5A623),
                ),
              ),
            ),
          ),
          // Guest
          Center(
            child: TextButton(
              onPressed: controller.loginAsGuest,
              child: Text(
                'Login Tanpa Akun',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== HALAMAN REGISTER =====
  Widget _buildRegister() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          IconButton(
            onPressed: controller.toggleLogin,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(height: 16),
          Text(
            'Buat Akun',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Bergabung dengan komunitas kuliner',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          // Nama
          TextField(
            controller: controller.namaController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Email
          TextField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Password
          Obx(() => TextField(
            controller: controller.passwordController,
            obscureText: controller.isObscure.value,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(controller.isObscure.value
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: controller.toggleObscure,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )),
          const SizedBox(height: 24),
          // Tombol Register
          Obx(() => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Daftar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          )),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: controller.toggleLogin,
              child: Text(
                'Sudah punya akun? Login',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF5A623),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}