import 'package:flutter/material.dart';

/// Minimal floating logo for Splash & Onboarding.
///
/// Default: tampil dengan warm glow.
/// clean mode: logo clean/sharp tanpa glow/shadow tambahan.
class JejakRasaLogoAppIcon extends StatelessWidget {
  final double size;
  final bool clean;

  const JejakRasaLogoAppIcon({super.key, this.size = 96, this.clean = false});

  @override
  Widget build(BuildContext context) {
    final logoSize = (size * 1.02).clamp(72.0, 220.0);

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!clean)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      const BoxShadow(
                        color: Color(0xFFF97316),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: Offset(0, 10),
                      ).copyWith(
                        color: const Color(0xFFF97316).withOpacity(0.18),
                      ),
                      const BoxShadow(
                        color: Colors.black,
                        blurRadius: 26,
                        spreadRadius: 0,
                        offset: Offset(0, 8),
                      ).copyWith(color: Colors.black.withOpacity(0.06)),
                    ],
                  ),
                ),
              ),

            Image.asset(
              'assets/images/logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
