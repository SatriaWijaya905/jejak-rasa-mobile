import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  // ─── Warna tema ────────────────────────────────────────────────────────────
  static const _orange1 = Color(0xFFFF8C00);
  static const _orange2 = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ══════════════════════════════════════════════════════════
                    // HEADER
                    // ══════════════════════════════════════════════════════════
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: Get.back,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Profil',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1A1A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Kelola informasi akunmu',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ══════════════════════════════════════════════════════════
                    // AVATAR PREMIUM
                    // ══════════════════════════════════════════════════════════
                    Center(
                      child: Obx(
                        () => Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                // Gradient ring + avatar
                                Container(
                                  width: 140,
                                  height: 140,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFF8C00),
                                        Color(0xFFF5A623),
                                        Color(0xFFFFBF00),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _orange2.withOpacity(0.3),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: CircleAvatar(
                                      radius: 64,
                                      backgroundColor: const Color(0xFFFFF3D9),
                                      backgroundImage:
                                          controller.imageUrl.value.isNotEmpty
                                              ? NetworkImage(
                                                  controller.imageUrl.value)
                                              : null,
                                      child: controller.imageUrl.value.isEmpty
                                          ? Icon(
                                              Icons.person_rounded,
                                              size: 60,
                                              color: _orange2.withOpacity(0.6),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),

                                // Floating camera button
                                GestureDetector(
                                  onTap: controller.pickImage,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [_orange1, _orange2],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _orange1.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Foto Profil',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Tap ikon kamera untuk mengganti foto',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Info badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield_outlined,
                                      color: Colors.orange.shade700, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Foto terlihat oleh pengguna lain',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ══════════════════════════════════════════════════════════
                    // FORM SECTION - INFORMASI DASAR
                    // ══════════════════════════════════════════════════════════
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title
                          _buildSectionTitle(
                            'Informasi Dasar',
                            'Atur data yang akan tampil di profil Anda.',
                          ),

                          const SizedBox(height: 20),

                          // Nama
                          _buildModernField(
                            controller: controller.nameController,
                            label: 'Nama',
                            hint: 'Masukkan nama lengkap',
                            icon: Icons.person_outline_rounded,
                          ),

                          const SizedBox(height: 20),

                          // Bio
                          _buildModernField(
                            controller: controller.bioController,
                            label: 'Bio',
                            hint: 'Ceritakan tentang dirimu…',
                            icon: Icons.edit_note_rounded,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 20),

                          // Lokasi
                          _buildModernField(
                            controller: controller.locationController,
                            label: 'Lokasi',
                            hint: 'Contoh: Malang, Jawa Timur',
                            icon: Icons.location_on_outlined,
                          ),

                          const SizedBox(height: 32),

                          // ══════════════════════════════════════════════════════
                          // FORM SECTION - SOSIAL MEDIA
                          // ══════════════════════════════════════════════════════
                          _buildSectionTitle(
                            'Sosial Media',
                            'Tautkan akun agar lebih mudah ditemukan.',
                          ),

                          const SizedBox(height: 20),

                          // Instagram
                          _buildModernField(
                            controller: controller.instagramController,
                            label: 'Instagram',
                            hint: '@username',
                            icon: Icons.camera_alt_outlined,
                          ),

                          const SizedBox(height: 40),

                          // ══════════════════════════════════════════════════════
                          // SAVE BUTTON — PREMIUM GRADIENT PILL
                          // ══════════════════════════════════════════════════════
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8C00),
                                    Color(0xFFF5A623),
                                    Color(0xFFFFBF00),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: _orange2.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Simpan Perubahan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 32),
                        ],
                      ),
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

  // ─── Section Title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
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
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Modern Input Field ─────────────────────────────────────────────────────
  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  color: _orange2.withOpacity(0.7),
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.shade100,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: _orange2,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
