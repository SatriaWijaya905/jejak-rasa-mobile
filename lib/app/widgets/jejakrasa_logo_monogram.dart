import 'package:flutter/material.dart';

/// SIMPLE premium JR logo.

/// - Text("JR") modern bold
/// - Thin simple circle outline
/// - Soft shadow + light glow
/// - No custom painter / no experimental geometry
class JejakRasaLogoMonogram extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const JejakRasaLogoMonogram({
    super.key,
    this.size = 112,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    // Auth branding: lebih clean + lebih kecil, tanpa circle border yang dominan.
    // Tetap pakai asset logo asli.
    final logoBox = (size * 0.92).clamp(64.0, 120.0);

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: logoBox,
          height: logoBox,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
