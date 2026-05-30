import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/widgets/recipe_status_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeFeedCard extends StatelessWidget {
  final ResepModel resep;
  final String? creatorName;
  final String? creatorPhoto;

  const RecipeFeedCard({
    super.key,
    required this.resep,
    this.creatorName,
    this.creatorPhoto,
  });

  static const Color _accent = Color(0xFFF5A623);
  static const Color _accentDark = Color(0xFFE8941A);

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} tahun lalu';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} bulan lalu';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} minggu lalu';
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (resep.id != null) {
          Get.toNamed('/detail-resep', arguments: resep);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _accent.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === COVER IMAGE ===
            _buildCoverImage(isPending: resep.status == 'pending'),
            // === CONTENT ===
            resep.status == 'pending' 
              ? ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                  child: _buildContent(),
                )
              : _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage({bool isPending = false}) {
    Widget imageWidget = (resep.fotoCover != null && resep.fotoCover!.isNotEmpty)
        ? Image.network(
            resep.fotoCover!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingImage();
            },
          )
        : _buildPlaceholderImage();

    if (isPending) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: imageWidget,
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          imageWidget,

          // Gradient overlay bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Province badge
          if (resep.provinsi != null && resep.provinsi!.isNotEmpty)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 13, color: _accent),
                    const SizedBox(width: 4),
                    Text(
                      resep.provinsi!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Difficulty badge
          if (resep.tingkatKesulitan != null &&
              resep.tingkatKesulitan!.isNotEmpty)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getDifficultyColors(resep.tingkatKesulitan!),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  resep.tingkatKesulitan!,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Status badge
          if (resep.status != null && resep.authorUid == FirebaseAuth.instance.currentUser?.uid)
            Positioned(
              bottom: 12,
              left: 12,
              child: RecipeStatusBadge(status: resep.status!),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe name
          Text(
            resep.namaResep ?? 'Tanpa Nama',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Creator info row
          Row(
            children: [
              // Creator avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accent.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (creatorPhoto != null && creatorPhoto!.isNotEmpty)
                      ? Image.network(
                          creatorPhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(width: 10),

              // Creator name + time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creatorName ?? 'Creator',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    if (resep.createdAt != null)
                      Text(
                        _timeAgo(resep.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),

              // Rating
              if (resep.rating != null && resep.rating! > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Color(0xFFFFB800)),
                      const SizedBox(width: 3),
                      Text(
                        resep.rating!.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom stats row
          Row(
            children: [
              // Cooking time badge
              if (resep.waktuMasak != null && resep.waktuMasak!.isNotEmpty)
                _buildStatBadge(
                  icon: Icons.access_time_rounded,
                  label: resep.waktuMasak!,
                  bgColor: const Color(0xFFF0F4FF),
                  iconColor: const Color(0xFF5B7CF7),
                ),

              if (resep.waktuMasak != null && resep.waktuMasak!.isNotEmpty)
                const SizedBox(width: 8),

              // Review count
              if (resep.jumlahReview != null && resep.jumlahReview! > 0)
                _buildStatBadge(
                  icon: Icons.rate_review_outlined,
                  label: '${resep.jumlahReview}',
                  bgColor: const Color(0xFFF5F0FF),
                  iconColor: const Color(0xFF8B5CF6),
                ),

              const Spacer(),

              // Favorite count
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _accent.withOpacity(0.08),
                      const Color(0xFFFF6B6B).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded,
                        size: 15, color: Color(0xFFFF6B6B)),
                    const SizedBox(width: 5),
                    Text(
                      '${resep.jumlahFavorit ?? 0}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFFFF3E0),
      child: const Icon(
        Icons.person_rounded,
        size: 20,
        color: _accent,
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8E7),
            Color(0xFFFFF0D4),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_rounded,
                size: 48, color: _accent.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text(
              'Tanpa Foto',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _accent.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: const Color(0xFFFFF8E7),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
          ),
        ),
      ),
    );
  }

  List<Color> _getDifficultyColors(String difficulty) {
    final lower = difficulty.toLowerCase();
    if (lower.contains('mudah')) {
      return [const Color(0xFF4ADE80), const Color(0xFF22C55E)];
    } else if (lower.contains('sedang')) {
      return [_accent, _accentDark];
    } else {
      return [const Color(0xFFFF6B6B), const Color(0xFFEF4444)];
    }
  }
}
