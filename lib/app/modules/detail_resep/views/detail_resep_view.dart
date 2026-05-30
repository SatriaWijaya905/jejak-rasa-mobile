import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jejakrasa_mobile_database/app/modules/favorit/controllers/favorit_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/detail_resep_controller.dart';
import 'package:jejakrasa_mobile_database/app/utils/launch_url_utils.dart';

// ignore_for_file: avoid_print

import '../widgets/review_section.dart';
import 'package:jejakrasa_mobile_database/app/widgets/recipe_status_badge.dart';

class DetailResepView extends GetView<DetailResepController> {
  const DetailResepView({super.key});

  static const Color _accent = Color(0xFFF5A623);

  Widget _buildYoutubeVideoSection(String youtubeUrl) {
    final trimmed = youtubeUrl.trim();
    final isValid = trimmed.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _accent.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4B4B).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Color(0xFFFF4B4B),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🎥 Video Tutorial',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trimmed,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isValid
                  ? () async {
                      // Use url_launcher (works after dependency added)
                      // If launcher fails, keep UI safe.
                      try {
                        await LaunchUrlUtils.launchYouTube(trimmed);
                        return;
                      } catch (_) {
                        // fallback (mobile/web-safe)
                        try {
                          await launchUrl(
                            Uri.parse(trimmed),
                            webOnlyWindowName: '_blank',
                          );
                        } catch (_) {
                          Get.snackbar('Gagal', 'Tidak bisa membuka YouTube');
                        }
                      }
                    }
                  : null,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('[Tonton di YouTube]'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Color _cream = Color(0xFFFFF8EE);
  static const Color _bg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        final resep = controller.resep.value;
        if (resep == null) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        final resepSafe = resep;
        final isOwner = resepSafe.authorUid == controller.auth.currentUser?.uid;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HERO HEADER ---
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              backgroundColor: _accent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: _buildFloatingButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Get.back(),
              ),
              actions: [
                if (isOwner) _buildOwnerMenu(resepSafe),
                const SizedBox(width: 8),
                _buildFavoriteButton(resepSafe.id ?? ''),
                const SizedBox(width: 12),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Hero Image
                    (resep.fotoCover != null && resep.fotoCover!.isNotEmpty)
                        ? Image.network(
                            resep.fotoCover!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),

                    // Content Overlay
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _buildBadge(
                                resep.kategoriProvinsi ?? 'Umum',
                                _accent,
                              ),
                              const SizedBox(width: 8),
                              _buildBadge(
                                resep.provinsi ?? '-',
                                Colors.white24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            resep.namaResep ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoItem(
                                Icons.access_time_rounded,
                                resep.waktuMasak ?? '-',
                              ),
                              const SizedBox(width: 16),
                              _buildInfoItem(
                                Icons.bar_chart_rounded,
                                resep.tingkatKesulitan ?? '-',
                              ),
                              const SizedBox(width: 16),
                              _buildInfoItem(
                                Icons.star_rounded,
                                '${(resep.rating ?? 0).toStringAsFixed(1)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- CONTENT BODY ---
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  decoration: const BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Status Badge (if owner)
                      if (resep.status != null && isOwner)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: RecipeStatusBadge(status: resep.status!),
                        ),

                      // Reject Card (if rejected and owner)
                      if (resep.status == 'rejected' && isOwner)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: _buildRejectCard(resep),
                        ),

                      // Author Profile
                      _buildAuthorProfile(),

                      const SizedBox(height: 20),

                      // Ingredients
                      _buildIngredientsSection(resep.bahan),

                      // Video Tutorial (opsional)
                      if (resep.youtubeVideoUrl != null &&
                          resep.youtubeVideoUrl!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: _buildYoutubeVideoSection(
                            resep.youtubeVideoUrl!,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Steps
                      _buildStepsSection(resep.langkah),

                      const SizedBox(height: 20),

                      // Other Recipes from Creator
                      _buildOtherRecipes(),

                      const SizedBox(height: 10),

                      // Reviews
                      ReviewSection(resepId: resep.id ?? ''),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildFavoriteButton(String resepId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Obx(() {
        if (!Get.isRegistered<FavoritController>()) {
          return IconButton(
            onPressed: () {
              Get.put(FavoritController());
              Get.find<FavoritController>().toggleFavorit(resepId);
            },
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 22,
            ),
          );
        }
        final fc = Get.find<FavoritController>();
        final isFav = fc.isFavorit(resepId);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: IconButton(
            key: ValueKey<bool>(isFav),
            onPressed: () => fc.toggleFavorit(resepId),
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? const Color(0xFFFF4B4B) : Colors.white,
              size: 22,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOwnerMenu(dynamic resep) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (value) async {
          if (value == 'edit') Get.toNamed('/edit-resep', arguments: resep);
          if (value == 'hapus') {
            final confirm = await Get.dialog(
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'Hapus Resep',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Yakin ingin menghapus resep ini?',
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Hapus',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) await controller.hapusResep(resep.id!);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit_rounded, size: 18, color: Colors.black87),
                const SizedBox(width: 12),
                Text('Edit', style: GoogleFonts.poppins(color: Colors.black87)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'hapus',
            child: Row(
              children: [
                const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                const SizedBox(width: 12),
                Text('Hapus', style: GoogleFonts.poppins(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectCard(dynamic resep) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resep Perlu Perbaikan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Alasan Penolakan:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            resep.rejectReason ?? 'Tidak ada alasan spesifik.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/edit-resep', arguments: resep),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text(
                'Revisi Resep',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: _cream,
      child: const Center(
        child: Icon(Icons.restaurant_menu_rounded, size: 80, color: _accent),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: _accent),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorProfile() {
    return Obx(() {
      final creator = controller.creator.value;
      return GestureDetector(
        onTap: () {
          if (creator != null) {
            Get.toNamed(
              '/creator-profile',
              arguments: {
                'creator': creator,
                'resepList': controller.resepCreator,
              },
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: _cream, width: 2),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accent.withOpacity(0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: _cream,
                  backgroundImage:
                      (creator?.fotoProfil != null &&
                          creator!.fotoProfil!.isNotEmpty)
                      ? NetworkImage(creator.fotoProfil!)
                      : null,
                  child:
                      (creator?.fotoProfil == null ||
                          creator!.fotoProfil!.isEmpty)
                      ? const Icon(Icons.person_outline_rounded, color: _accent)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resep oleh',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      creator?.nama ?? 'Chef Nusantara',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, Color(0xFFFF8C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Lihat Profil',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIngredientsSection(List<dynamic>? bahan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bahan-bahan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${bahan?.length ?? 0} Item',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bahan != null && bahan.isNotEmpty)
            ...bahan.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              'Belum ada data bahan',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(List<dynamic>? langkah) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Langkah Memasak',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${langkah?.length ?? 0} Step',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (langkah != null && langkah.isNotEmpty)
            ...langkah.asMap().entries.map((entry) {
              final stepIndex = entry.key + 1;
              final stepData = entry.value;
              final bool isLast = stepIndex == langkah.length;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Line & Dot
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accent, Color(0xFFFF8C00)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$stepIndex',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: _cream,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Step Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24, top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stepData.text ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                            if (stepData.imageUrl != null &&
                                stepData.imageUrl.toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: GestureDetector(
                                  onTap: () =>
                                      _showFullscreenImage(stepData.imageUrl),
                                  child: Hero(
                                    tag: 'step_img_$stepIndex',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        stepData.imageUrl,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Text(
              'Belum ada langkah memasak',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _showFullscreenImage(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherRecipes() {
    return Obx(() {
      final list = controller.resepCreator;
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Resep Lain dari Chef Ini',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final r = list[i];
                return GestureDetector(
                  onTap: () {
                    // Prevent duplicate route if same recipe, or just push
                    Get.toNamed(
                      '/detail-resep',
                      arguments: r,
                      preventDuplicates: false,
                    );
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child:
                              (r.fotoCover != null && r.fotoCover!.isNotEmpty)
                              ? Image.network(r.fotoCover!, fit: BoxFit.cover)
                              : Container(
                                  color: _cream,
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: _accent,
                                  ),
                                ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.6],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            r.namaResep ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
