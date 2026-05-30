import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jejakrasa_mobile_database/app/modules/favorit/bindings/favorit_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/favorit/views/favorit_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/controllers/home_controller.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/views/homepage_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/views/kreasi_view.dart';
import 'package:jejakrasa_mobile_database/app/modules/notification/bindings/notification_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/profil/bindings/profil_binding.dart';
import 'package:jejakrasa_mobile_database/app/modules/profil/views/profil_view.dart';

import 'package:jejakrasa_mobile_database/app/theme/app_theme.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    ProfilBinding().dependencies();
    FavoritBinding().dependencies();

    // Tambahan: NotificationBinding tetap seperti sebelumnya jika diperlukan oleh tabs lain
    NotificationBinding().dependencies();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Obx(() => _buildBody(controller.currentIndex.value)),
          ),
          Obx(() {
            final currentIndex = controller.currentIndex.value;
            final showFab =
                currentIndex == 0 ||
                currentIndex == 1 ||
                currentIndex == 2 ||
                currentIndex == 3;
            if (!showFab) return const SizedBox.shrink();

            return Positioned(
              right: 24,
              bottom: 18,
              child: (currentIndex == 0 || currentIndex == 2)
                  ? _buildSmallFAB()
                  : _buildExtendedFAB(),
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Obx(
            () => Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 57, 57, 56),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.black.withOpacity(0.06),
                  width: 0.8,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BottomNavigationBar(
                  currentIndex: controller.currentIndex.value,
                  onTap: controller.changeTab,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppTheme.accent,
                  unselectedItemColor: Colors.grey.shade500,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedIconTheme: const IconThemeData(size: 26),
                  unselectedIconTheme: const IconThemeData(size: 23),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book_outlined),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_border_outlined),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: '',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomepageView();

      case 1:
        return const KreasiView();

      case 2:
        return const FavoritView();

      case 3:
        return const ProfilView();

      default:
        return const HomepageView();
    }
  }

  // ─── FAB Bulat Kecil (Home & Favorit) ──────────────────────────────────────
  Widget _buildSmallFAB() {
    return _HoverScaleWidget(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C00), Color(0xFFF5A623)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF5A623).withOpacity(0.45),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => Get.toNamed('/buat-resep'),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  // ─── FAB Extended (Profil & Kreasi) ─────────────────────────────────────────
  Widget _buildExtendedFAB() {
    return _HoverScaleWidget(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C00), Color(0xFFF5A623)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF5A623).withOpacity(0.45),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => Get.toNamed('/buat-resep'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Buat Resep',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hover / tap scale micro-interaction ────────────────────────────────────
class _HoverScaleWidget extends StatefulWidget {
  final Widget child;
  const _HoverScaleWidget({required this.child});

  @override
  State<_HoverScaleWidget> createState() => _HoverScaleWidgetState();
}

class _HoverScaleWidgetState extends State<_HoverScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
