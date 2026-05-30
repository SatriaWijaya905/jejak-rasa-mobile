import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientOnboardingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const GradientOnboardingButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: MouseRegion(
        cursor: onPressed == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
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
          child: _PremiumGradientButtonBody(
            label: label,
            enabled: onPressed != null,
          ),
        ),
      ),
    );
  }
}

class _PremiumGradientButtonBody extends StatelessWidget {
  final String label;
  final bool enabled;

  const _PremiumGradientButtonBody({
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 54,
      width: double.infinity,
      transform: Matrix4.identity()..scale(enabled ? 1.0 : 0.995),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBC02D), Color(0xFFF97316)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(enabled ? 0.35 : 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(enabled ? 0.06 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(enabled ? 1.0 : 0.92),
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
