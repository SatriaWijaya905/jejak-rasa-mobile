import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/jejakrasa_logo_monogram.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  static const Color _accent = Color(0xFFF5A623);

  Future<bool> _handleBack() async {
    Get.offAllNamed('/onboarding');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Obx(
            () => Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  child: controller.isLogin.value
                      ? _LoginView(controller: controller, width: size.width)
                      : _RegisterView(
                          controller: controller,
                          width: size.width,
                        ),
                ),

                // Tombol back UI WAJIB kelihatan di kiri atas.
                Positioned(
                  top: 24,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      Get.offAllNamed('/onboarding');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginView extends StatelessWidget {
  final AuthController controller;
  final double width;

  const _LoginView({required this.controller, required this.width});

  @override
  Widget build(BuildContext context) {
    final isWebWide = width >= 720;

    return Stack(
      children: [
        _WarmBackground(headerHeight: isWebWide ? 220 : 200),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWebWide ? 140 : 22,
              vertical: isWebWide ? 18 : 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                _LogoJR(),
                const SizedBox(height: 10),

                _PremiumHeader(
                  title: 'Jejak Rasa',
                  subtitle: 'Jelajahi Kuliner Nusantara',
                  showBackButton: false,
                ),
                const SizedBox(height: 22),
                _AuthCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang!',
                        style: GoogleFonts.poppins(
                          fontSize: isWebWide ? 26 : 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk untuk mulai eksplorasi',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _AuthTextField(
                        label: 'Email',
                        hint: 'contoh@email.com',
                        icon: Icons.email_outlined,
                        controller: controller.emailController,
                        obscure: false,
                        accent: AuthView._accent,
                      ),
                      const SizedBox(height: 14),

                      Obx(
                        () => _AuthTextField(
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outlined,
                          controller: controller.passwordController,
                          obscure: controller.isObscure.value,
                          accent: AuthView._accent,
                          suffix: IconButton(
                            tooltip: controller.isObscure.value
                                ? 'Sembunyikan'
                                : 'Tampilkan',
                            icon: Icon(
                              controller.isObscure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black.withOpacity(0.55),
                              size: 20,
                            ),
                            onPressed: controller.toggleObscure,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Obx(
                        () => _GradientButton(
                          height: 54,
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Masuk',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Center(
                        child: TextButton(
                          onPressed: controller.toggleLogin,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.45),
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Daftar',
                                  style: GoogleFonts.poppins(
                                    color: AuthView._accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const SizedBox(height: 18),

                      Center(
                        child: TextButton(
                          onPressed: controller.loginAsGuest,
                          child: Text(
                            'Masuk Tanpa Akun',
                            style: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterView extends StatelessWidget {
  final AuthController controller;
  final double width;

  const _RegisterView({required this.controller, required this.width});

  @override
  Widget build(BuildContext context) {
    final isWebWide = width >= 720;

    return Stack(
      children: [
        _WarmBackground(headerHeight: isWebWide ? 190 : 170),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWebWide ? 140 : 22,
              vertical: isWebWide ? 18 : 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                _LogoJR(),
                const SizedBox(height: 10),

                _PremiumHeader(
                  title: 'Daftar Akun',
                  subtitle: 'Bergabung dengan komunitas kuliner nusantara',
                  showBackButton: false,
                ),
                const SizedBox(height: 22),
                _AuthCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bergabung Sekarang',
                        style: GoogleFonts.poppins(
                          fontSize: isWebWide ? 26 : 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Buat profil dan mulai berbagi kreasi masakanmu',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 22),

                      _AuthTextField(
                        label: 'Nama Lengkap',
                        hint: 'Nama kamu',
                        icon: Icons.person_outlined,
                        controller: controller.namaController,
                        obscure: false,
                        accent: AuthView._accent,
                      ),
                      const SizedBox(height: 14),

                      _AuthTextField(
                        label: 'Email',
                        hint: 'contoh@email.com',
                        icon: Icons.email_outlined,
                        controller: controller.emailController,
                        obscure: false,
                        accent: AuthView._accent,
                      ),
                      const SizedBox(height: 14),

                      Obx(
                        () => _AuthTextField(
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outlined,
                          controller: controller.passwordController,
                          obscure: controller.isObscure.value,
                          accent: AuthView._accent,
                          suffix: IconButton(
                            tooltip: controller.isObscure.value
                                ? 'Sembunyikan'
                                : 'Tampilkan',
                            icon: Icon(
                              controller.isObscure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black.withOpacity(0.55),
                              size: 20,
                            ),
                            onPressed: controller.toggleObscure,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Obx(
                        () => _GradientButton(
                          height: 54,
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.register,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Daftar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Center(
                        child: TextButton(
                          onPressed: controller.toggleLogin,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Sudah punya akun? ',
                              style: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.45),
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Masuk',
                                  style: GoogleFonts.poppins(
                                    color: AuthView._accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WarmBackground extends StatelessWidget {
  final double headerHeight;

  const _WarmBackground({required this.headerHeight});

  @override
  Widget build(BuildContext context) {
    final top = headerHeight;

    return Positioned.fill(
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFC107),
                  const Color(0xFFF97316),
                  const Color(0xFFFFF7ED),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -top * 0.25,
            left: -top * 0.25,
            child: _BlurCircle(size: top * 0.55, opacity: 0.22),
          ),
          Positioned(
            top: top * 0.05,
            right: -top * 0.22,
            child: _BlurCircle(size: top * 0.62, opacity: 0.18),
          ),
          Positioned(
            bottom: -top * 0.42,
            left: -top * 0.10,
            child: _BlurCircle(size: top * 0.72, opacity: 0.14),
          ),
          Positioned(
            top: top * 0.15,
            left: -40,
            child: _CulinaryIcon(icon: Icons.emoji_food_beverage_outlined),
          ),
          Positioned(
            top: top * 0.28,
            right: -34,
            child: _CulinaryIcon(icon: Icons.no_food_outlined),
          ),
          Positioned(
            bottom: -20,
            left: 18,
            child: _CulinaryIcon(icon: Icons.spa),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _BlurCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: size,
          height: size,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}

class _LogoJR extends StatelessWidget {
  const _LogoJR();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.28),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(child: JejakRasaLogoMonogram(size: 86, strokeWidth: 2.2)),
      ),
    );
  }
}

class _CulinaryIcon extends StatelessWidget {
  final IconData icon;

  const _CulinaryIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.18,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Center(child: Icon(icon, size: 32, color: Colors.white)),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;

  const _PremiumHeader({
    required this.title,
    required this.subtitle,
    required this.showBackButton,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton)
            SizedBox(
              width: 42,
              height: 42,
              child: IconButton(
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.14),
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            )
          else
            const SizedBox(width: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final Widget child;

  const _AuthCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(44),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: child,
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Color accent;
  final Widget? suffix;

  const _AuthTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.obscure,
    required this.accent,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black.withOpacity(0.32),
            ),
            prefixIcon: Icon(icon, size: 20, color: accent),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.08),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: accent.withOpacity(0.55),
                width: 1.3,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const _GradientButton({
    required this.onPressed,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onPressed == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: AnimatedScaleOnHover(
        on: true,
        scale: 1.01,
        builder: (isHovering) {
          return DecoratedBox(
            decoration: const BoxDecoration(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: height,
              width: double.infinity,
              transform: Matrix4.identity()..scale(isHovering ? 1.0 : 1.0),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFBC02D), Color(0xFFF97316)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedScaleOnHover extends StatefulWidget {
  final bool on;
  final double scale;
  final Widget Function(bool isHovering) builder;

  const AnimatedScaleOnHover({
    super.key,
    required this.on,
    required this.scale,
    required this.builder,
  });

  @override
  State<AnimatedScaleOnHover> createState() => _AnimatedScaleOnHoverState();
}

class _AnimatedScaleOnHoverState extends State<AnimatedScaleOnHover> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.on) return widget.builder(false);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: _isHovering ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.builder(_isHovering),
      ),
    );
  }
}
