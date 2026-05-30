import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/splash_controller.dart';

import '../../../widgets/jejakrasa_logo_app_icon.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Responsive scale: jangan terlalu besar di mobile kecil, tapi tetap bagus di web.
    final base = (size.shortestSide).clamp(320.0, 900.0);
    final logoSize = base * 0.22; // ~70..198
    final padding = base * 0.06; // ~19..54

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (warm culinary premium) diagonal smooth
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF59E0B),
                    Color(0xFFFBBF24),
                    Color(0xFFFFF7ED),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Soft decorative circles (tanpa shadow/glow besar)
          Positioned(
            top: -base * 0.22,
            left: -base * 0.18,
            child: _SoftCircle(size: base * 0.62, opacity: 0.18),
          ),
          Positioned(
            bottom: -base * 0.26,
            right: -base * 0.18,
            child: _SoftCircle(size: base * 0.70, opacity: 0.12),
          ),
          Positioned(
            top: base * 0.22,
            right: -base * 0.12,
            child: _SoftCircle(size: base * 0.42, opacity: 0.10),
          ),

          // Floating food icons (light/transparant)
          Positioned(
            top: size.height * 0.18,
            left: -base * 0.06,
            child: _FloatingIcon(
              icon: Icons.no_food_outlined,
              // placeholder: diganti via transform/opacity; masih aman tanpa asset
              label: 'mie',
            ),
          ),
          Positioned(
            top: size.height * 0.34,
            right: -base * 0.05,
            child: _FloatingIcon(icon: Icons.spa, label: 'sendok'),
          ),
          Positioned(
            bottom: size.height * 0.22,
            left: -base * 0.05,
            child: _FloatingIcon(
              icon: Icons.emoji_food_beverage_outlined,
              label: 'chef',
            ),
          ),

          // Center content with fade + scale
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween<double>(begin: 0.96, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, scale, _) {
                return Opacity(
                  opacity: 1.0,
                  child: Transform.scale(
                    scale: scale,
                    child: _SplashContent(
                      logoSize: logoSize,
                      padding: padding,
                      tagline: 'Jelajahi Cita Rasa Nusantara',
                    ),
                  ),
                );
              },
            ),
          ),

          // Fade in overlay (separate layer to ensure opacity anim)
          _FadeInLayer(duration: const Duration(milliseconds: 1500)),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _SoftCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _FadeInLayer extends StatefulWidget {
  final Duration duration;

  const _FadeInLayer({required this.duration});

  @override
  State<_FadeInLayer> createState() => _FadeInLayerState();
}

class _FadeInLayerState extends State<_FadeInLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  final double logoSize;
  final double padding;
  final String tagline;

  const _SplashContent({
    required this.logoSize,
    required this.padding,
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo floating (tanpa card besar)
          Container(
            width: logoSize * 1.55,
            height: logoSize * 1.10,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: JejakRasaLogoAppIcon(size: logoSize * 1.2, clean: true),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'JejakRasa',
            style: GoogleFonts.poppins(
              fontSize: (logoSize * 0.18).clamp(18, 24),
              fontWeight: FontWeight.w800,
              color: textColor.withOpacity(0.98),
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            tagline,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: (logoSize * 0.095).clamp(12, 15),
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.92),
            ),
          ),

          const SizedBox(height: 24),

          const _ElegantDotsLoading(),

          SizedBox(height: (logoSize * 0.06).clamp(10, 14)),
        ],
      ),
    );
  }
}

class _ElegantDotsLoading extends StatelessWidget {
  const _ElegantDotsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _Dot(dotIndex: 0),
        SizedBox(width: 8),
        _Dot(dotIndex: 1),
        SizedBox(width: 8),
        _Dot(dotIndex: 2),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final int dotIndex;

  const _Dot({required this.dotIndex});

  @override
  Widget build(BuildContext context) {
    return _StaggeredDot(dotIndex: dotIndex);
  }
}

class _StaggeredDot extends StatefulWidget {
  final int dotIndex;

  const _StaggeredDot({required this.dotIndex});

  @override
  State<_StaggeredDot> createState() => _StaggeredDotState();
}

class _StaggeredDotState extends State<_StaggeredDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // stagger efek dengan menggeser phase animasi
    final t = (_controller.value + (widget.dotIndex * 0.33)) % 1.0;
    final value = Curves.easeInOut.transform(t);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 8,
      height: 8 + (6 * value),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FloatingIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.18,
      child: SizedBox(width: 90, height: 90, child: _DriftIcon(icon: icon)),
    );
  }
}

class _DriftIcon extends StatefulWidget {
  final IconData icon;

  const _DriftIcon({required this.icon});

  @override
  State<_DriftIcon> createState() => _DriftIconState();
}

class _DriftIconState extends State<_DriftIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx = (t - 0.5) * 10;
        final dy = (0.5 - (t - 0.5).abs()) * 6;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Center(
            child: Icon(
              widget.icon,
              size: 56,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        );
      },
    );
  }
}
