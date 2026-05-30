import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/controllers/home_controller.dart';

import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  // ─── Warna tema ────────────────────────────────────────────────────────────
  static const _orange1 = Color(0xFFFF8C00);
  static const _orange2 = Color(0xFFF5A623);
  static const _orangeLight = Color(0xFFFFF3D9);
  static const _bg = Color(0xFFF6F7FA);


  // ─── Count resep menu card (stream) ────────────────────────────────────────
  Widget _countResepMenuCard({required VoidCallback onTap}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resep')
          .where('author_uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
          .snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.data?.docs.length ?? 0;
        return _buildMenuCard(
          Icons.restaurant_menu_rounded,
          'Kreasi Resep Saya',
          '$total resep telah dibuat',
          onTap,
        );
      },
    );
  }

  // ─── Bottom sheet pengaturan ────────────────────────────────────────────────
  void _showPengaturan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_orange1, _orange2],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pengaturan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingItem(Icons.person_outline_rounded, 'Edit Profil',
                    () => Get.toNamed('/edit-profile')),
                _buildSettingItem(Icons.notifications_outlined, 'Notifikasi',
                    () => Get.toNamed('/notification')),
                _buildSettingItem(Icons.shield_outlined, 'Privasi',
                    () => Get.toNamed('/privacy')),
                _buildSettingItem(Icons.help_outline_rounded, 'Bantuan',
                    () => Get.toNamed('/help')),
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade100, thickness: 1),
                const SizedBox(height: 8),
                // Logout tile
                InkWell(
                  onTap: controller.logout,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, color: _orange1, size: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Keluar',
                            style: GoogleFonts.poppins(
                              color: _orange1,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _orange1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW > 600;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: _orange2),
                  const SizedBox(height: 14),
                  Text('Memuat profil…',
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          final user = controller.user.value;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 560 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── HEADER ────────────────────────────────────────────────
                    _buildHeader(context, user),

                    const SizedBox(height: 16),

                    // ── LOKASI & INSTAGRAM ────────────────────────────────────────
                    if ((user?.alamat != null && user!.alamat.toString().trim().isNotEmpty) || 
                        (user?.instagram != null && user!.instagram.toString().trim().isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            if (user.alamat != null && user.alamat.toString().trim().isNotEmpty)
                              _buildLocation(user.alamat!),
                            if (user.instagram != null && user.instagram.toString().trim().isNotEmpty)
                              _buildInstagramBadge(user.instagram!),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ── MENU CARDS ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionLabel('Aktivitas'),
                          const SizedBox(height: 12),
                          _countResepMenuCard(
                            onTap: () => Get.find<HomeController>().changeTab(1),
                          ),
                          const SizedBox(height: 12),
                          _buildMenuCard(
                            Icons.favorite_rounded,
                            'Resep Favorit',
                            'Lihat resep favorit kamu',
                            () => Get.find<HomeController>().changeTab(2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── HEADER widget ──────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, dynamic user) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8C00), Color(0xFFF5A623), Color(0xFFFFBF00)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: Column(
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profil Saya',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  _HoverScaleWidget(
                    child: GestureDetector(
                      onTap: () => _showPengaturan(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: const Color(0xFFFFF3D9),
                      child: ClipOval(
                        child: user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty
                            ? Image.network(
                                user.fotoProfil!,
                                width: 112,
                                height: 112,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_rounded,
                                  size: 64,
                                  color: _orange2,
                                ),
                              )
                            : const Icon(Icons.person_rounded, size: 64, color: _orange2),
                      ),
                    ),
                  ),
                  // Edit badge
                  GestureDetector(
                    onTap: () => Get.toNamed('/edit-profile'),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_orange1, _orange2],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _orange2.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Nama
              Text(
                user?.nama ?? 'Pengguna',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.email ?? '-',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Bio
              if (user?.bio != null && (user!.bio as String).isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  user.bio!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── STATS CARD ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Resep count
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('resep')
                          .where('author_uid',
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                          .snapshots(),
                      builder: (context, snapshot) {
                        final total = snapshot.data?.docs.length ?? 0;
                        return _buildStatItem(Icons.restaurant_menu_rounded, '$total', 'Resep');
                      },
                    ),
                    _buildStatDivider(),
                    // Pengikut
                    StreamBuilder<int>(
                      stream: Get.find<ProfilController>()
                          .getFollowersCountStream(creatorUid: user?.uid ?? ''),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return _buildStatItem(Icons.people_rounded, '$count', 'Pengikut');
                      },
                    ),
                    _buildStatDivider(),
                    // Mengikuti
                    StreamBuilder<int>(
                      stream: Get.find<ProfilController>()
                          .getFollowingCountStream(currentUid: user?.uid ?? ''),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return _buildStatItem(Icons.favorite_rounded, '$count', 'Mengikuti');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade100);
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_orange1.withOpacity(0.12), _orange2.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _orange1, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_orange1, _orange2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ─── Location & Instagram Badges ─────────────────────────────────────────────
  Widget _buildLocation(String location) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('📍', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          location,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramBadge(String instagram) {
    final username = instagram.startsWith('@') ? instagram : 'IG: @$instagram';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        const SizedBox(width: 6),
        Text(
          username,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ─── Menu card ──────────────────────────────────────────────────────────────
  Widget _buildMenuCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return _HoverScaleWidget(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_orange1.withOpacity(0.15), _orange2.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: _orange1, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _orangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _orange1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Setting item (bottom sheet) ────────────────────────────────────────────
  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.grey.shade500, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey.shade300),
            ],
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