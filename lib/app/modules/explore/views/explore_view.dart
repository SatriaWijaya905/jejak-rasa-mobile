import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/resep_model.dart';
import '../../../data/models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../controllers/explore_controller.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  static const Color _accent = Color(0xFFF5A623);
  static const Color _bg = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final isDesktop = width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContent = isDesktop ? 900.0 : double.infinity;
            return Center(
              child: SizedBox(
                width: maxContent,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Header ──────────────────────────────
                    SliverToBoxAdapter(child: _buildHeader()),
                    // ── Search Bar ───────────────────────────
                    SliverToBoxAdapter(child: _buildSearchBar()),
                    // ── Trending ─────────────────────────────
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('🔥 Trending Hari Ini'),
                    ),
                    SliverToBoxAdapter(child: _buildTrendingSection(isTablet)),
                    // ── Featured Creators ────────────────────
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('⭐ Creator Populer'),
                    ),
                    SliverToBoxAdapter(child: _buildCreatorsSection(isTablet)),
                    // ── Kategori Nusantara ────────────────────
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('🍜 Jelajahi Nusantara'),
                    ),
                    SliverToBoxAdapter(
                      child: _buildKategoriGrid(isTablet, isDesktop),
                    ),
                    // ── Resep Terbaru ────────────────────────
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('🆕 Resep Terbaru'),
                    ),
                    SliverToBoxAdapter(
                      child: _buildTerbaruSection(isTablet, isDesktop),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Kuliner Nusantara',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Temukan resep dan creator terbaik',
            style: GoogleFonts.poppins(fontSize: 13, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: _textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cari resep, bahan, creator...',
                style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION TITLE ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
    );
  }

  // ── TRENDING RESEP ────────────────────────────────────────────────────────
  Widget _buildTrendingSection(bool isTablet) {
    return Obx(() {
      if (controller.isLoadingTrending.value) {
        return _buildHorizontalShimmer(isTablet ? 200 : 170, 3);
      }
      if (controller.trendingResep.isEmpty) {
        return _buildEmptyState(
          icon: Icons.local_fire_department_rounded,
          message: 'Belum ada resep trending',
        );
      }
      final cardWidth = isTablet ? 200.0 : 170.0;
      return SizedBox(
        height: isTablet ? 240 : 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: controller.trendingResep.length,
          itemBuilder: (context, i) =>
              _buildTrendingCard(controller.trendingResep[i], cardWidth),
        ),
      );
    });
  }

  Widget _buildTrendingCard(ResepModel resep, double width) {
    return GestureDetector(
      onTap: () => controller.toDetailResep(resep),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: _networkImage(resep.fotoCover),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resep.namaResep ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: _textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          resep.provinsi ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _pill(
                        icon: Icons.star_rounded,
                        color: _accent,
                        label: (resep.rating ?? 0).toStringAsFixed(1),
                      ),
                      const SizedBox(width: 6),
                      _pill(
                        icon: Icons.favorite_rounded,
                        color: Colors.pinkAccent,
                        label: '${resep.jumlahFavorit ?? 0}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FEATURED CREATORS ─────────────────────────────────────────────────────
  Widget _buildCreatorsSection(bool isTablet) {
    return Obx(() {
      if (controller.isLoadingCreators.value) {
        return _buildHorizontalShimmer(isTablet ? 130 : 110, 4);
      }
      if (controller.featuredCreators.isEmpty) {
        return _buildEmptyState(
          icon: Icons.people_rounded,
          message: 'Belum ada creator',
        );
      }
      final cardW = isTablet ? 130.0 : 110.0;
      return SizedBox(
        height: isTablet ? 180 : 160,
        child: Obx(
          () => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.sortedCreators.length,
            itemBuilder: (context, i) =>
                _buildCreatorCard(controller.sortedCreators[i], cardW),
          ),
        ),
      );
    });
  }

  Widget _buildCreatorCard(UserModel user, double width) {
    final uid = user.uid ?? '';
    return GestureDetector(
      onTap: () => controller.toCreatorProfile(user),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  (user.fotoProfil != null && user.fotoProfil!.isNotEmpty)
                  ? NetworkImage(user.fotoProfil!)
                  : null,
              child: (user.fotoProfil == null || user.fotoProfil!.isEmpty)
                  ? Icon(
                      Icons.person_rounded,
                      size: 28,
                      color: Colors.grey.shade400,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              user.nama ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            // Followers realtime
            Obx(
              () => Text(
                '${_formatCount(controller.getFollowers(uid))} followers',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 10, color: _textSecondary),
              ),
            ),
            const SizedBox(height: 6),
            // Bio
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  color: _textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── KATEGORI NUSANTARA ────────────────────────────────────────────────────
  static const _kategoris = [
    {
      'label': 'Jawa',
      'emoji': '🍚',
      'gradient': [Color(0xFFFF9A5C), Color(0xFFFF6B6B)],
    },
    {
      'label': 'Sumatera',
      'emoji': '🌶',
      'gradient': [Color(0xFF43E97B), Color(0xFF38F9D7)],
    },
    {
      'label': 'Bali',
      'emoji': '🏝',
      'gradient': [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    },
    {
      'label': 'Sulawesi',
      'emoji': '🐟',
      'gradient': [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    },
    {
      'label': 'Papua',
      'emoji': '🌿',
      'gradient': [Color(0xFFFFD200), Color(0xFFF7971E)],
    },
    {
      'label': 'Kalimantan',
      'emoji': '🌳',
      'gradient': [Color(0xFF96FBC4), Color(0xFFF9F586)],
    },
  ];

  Widget _buildKategoriGrid(bool isTablet, bool isDesktop) {
    final crossAxisCount = isDesktop ? 6 : (isTablet ? 4 : 3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _kategoris.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, i) {
          final k = _kategoris[i];
          final gradColors = (k['gradient'] as List).cast<Color>();
          return GestureDetector(
            onTap: () => controller.toKategoriProvinsi(k['label'] as String),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradColors.first.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    k['emoji'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    k['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── RESEP TERBARU ─────────────────────────────────────────────────────────
  Widget _buildTerbaruSection(bool isTablet, bool isDesktop) {
    return Obx(() {
      if (controller.isLoadingTerbaru.value) {
        return _buildVerticalShimmer(3);
      }
      if (controller.terbaru.isEmpty) {
        return _buildEmptyState(
          icon: Icons.new_releases_rounded,
          message: 'Belum ada resep terbaru',
        );
      }
      final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
      if (crossAxisCount > 1) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.terbaru.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, i) =>
                _buildTerbaruCardGrid(controller.terbaru[i]),
          ),
        );
      }
      return Column(
        children: controller.terbaru
            .map((r) => _buildTerbaruCardList(r))
            .toList(),
      );
    });
  }

  Widget _buildTerbaruCardList(ResepModel resep) {
    return GestureDetector(
      onTap: () => controller.toDetailResep(resep),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: _networkImage(resep.fotoCover),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resep.namaResep ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: _textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            resep.provinsi ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _pill(
                          icon: Icons.star_rounded,
                          color: _accent,
                          label: (resep.rating ?? 0).toStringAsFixed(1),
                        ),
                        const SizedBox(width: 8),
                        _pill(
                          icon: Icons.favorite_rounded,
                          color: Colors.pinkAccent,
                          label: '${resep.jumlahFavorit ?? 0}',
                        ),
                        const SizedBox(width: 8),
                        _pill(
                          icon: Icons.timer_rounded,
                          color: Colors.blueAccent,
                          label: resep.waktuMasak ?? '-',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerbaruCardGrid(ResepModel resep) {
    return GestureDetector(
      onTap: () => controller.toDetailResep(resep),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: SizedBox(
                width: 90,
                child: _networkImage(resep.fotoCover, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resep.namaResep ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resep.provinsi ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _pill(
                      icon: Icons.star_rounded,
                      color: _accent,
                      label: (resep.rating ?? 0).toStringAsFixed(1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SHIMMER / SKELETON ────────────────────────────────────────────────────
  Widget _buildHorizontalShimmer(double cardW, int count) {
    return SizedBox(
      height: cardW + 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          width: cardW,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: _shimmerAnimate(BorderRadius.circular(18)),
        ),
      ),
    );
  }

  Widget _buildVerticalShimmer(int count) {
    return Column(
      children: List.generate(
        count,
        (_) => Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          height: 110,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
          child: _shimmerAnimate(BorderRadius.circular(18)),
        ),
      ),
    );
  }

  Widget _shimmerAnimate(BorderRadius radius) {
    return ClipRRect(borderRadius: radius, child: _ShimmerBox());
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 13, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _pill({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _networkImage(String? url, {BoxFit fit = BoxFit.cover}) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.restaurant_rounded,
          color: Colors.grey.shade400,
          size: 32,
        ),
      );
    }
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.grey.shade400,
          size: 32,
        ),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFF5A623),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// ── SHIMMER ANIMATION WIDGET ──────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(_anim.value, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              Color(0xFFE8E8E8),
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
