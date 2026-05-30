import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_ui.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/jejakrasa_logo_app_icon.dart';

import 'onboarding_button_widgets.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: const Color(0xFFFFFBEE),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal =
                (constraints.maxWidth * 0.07).clamp(18.0, 28.0);

            return Column(
              children: [
               AppPageHeader(
  title: '',
  
  leading: Row(
    children: [
      JejakRasaLogoAppIcon(
        size: 56,
        clean: true,
      ),

      const SizedBox(width: 10),

      Text(
        'Jejak Rasa',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFC97A00),
        ),
      ),
    ],
  ),
),

                const SizedBox(height: 12),

                Expanded(
                  child: PageView(
                    onPageChanged: (index) =>
                        controller.currentPage.value = index,
                    children: const [
                      _OnboardingSlide(
                        imagePath: 'assets/images/onboarding1.jpg',
                      ),
                      _OnboardingSlide(
                        imagePath: 'assets/images/onboarding2.webp',
                      ),
                      _OnboardingSlide(
                        imagePath: 'assets/images/onboarding3.webp',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final selected =
                          controller.currentPage.value == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 4),
                        width: selected ? 22 : 9,
                        height: selected ? 10 : 8,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.accent
                              : Colors.black.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 18),

                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: horizontal),
                  child: Column(
                    children: [
                      Text(
                        'Jejak Rasa',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize:
                              (constraints.maxWidth >= 700) ? 28 : 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -0.35,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Temukan cita rasa terbaik dari seluruh Indonesia',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.25,
                          color: const Color(0xFFF97316),
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Jelajahi pengalaman kuliner yang autentik',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: horizontal),
                  child: GradientOnboardingButton(
                    onPressed: controller.mulaiEksplorasi,
                    label: 'Mulai Eksplorasi →',
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: controller.skip,
                  child: Text(
                    'Login Tanpa Akun',
                    style: GoogleFonts.poppins(
                      color: Colors.black.withOpacity(0.55),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 22),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String imagePath;

  const _OnboardingSlide({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = (w * 0.07).clamp(18.0, 28.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: pad,
        vertical: 6,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // IMAGE
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),

              // SOFT OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.02),
                        Colors.black.withOpacity(0.18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}