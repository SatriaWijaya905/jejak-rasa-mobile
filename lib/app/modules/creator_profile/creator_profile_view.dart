import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:jejakrasa_mobile_database/app/data/models/resep_model.dart';
import 'package:jejakrasa_mobile_database/app/data/models/user_model.dart';
import 'package:jejakrasa_mobile_database/app/services/follow_service.dart';
import 'package:jejakrasa_mobile_database/app/routes/app_pages.dart';

import 'controllers/creator_profile_controller.dart';
import 'package:jejakrasa_mobile_database/app/modules/detail_resep/controllers/detail_resep_controller.dart';

// ─── Konstanta Warna ─────────────────────────────────────────────────────────
const _kOrange1 = Color(0xFFFFB300);
const _kOrange2 = Color(0xFFFF6F00);
const _kOrange3 = Color(0xFFFF8C00);
const _kBg = Color(0xFFF5F5F7);
const _kCard = Colors.white;

class CreatorProfileView extends StatefulWidget {
  const CreatorProfileView({super.key});

  @override
  State<CreatorProfileView> createState() => _CreatorProfileViewState();
}

class _CreatorProfileViewState extends State<CreatorProfileView>
    with TickerProviderStateMixin {
  final FollowService _followService = FollowService();

  late CreatorProfileController controller;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Realtime Firestore stream: hanya resep milik creator & status approved ──
  Stream<List<ResepModel>> _resepStream(String creatorUid) {
    if (creatorUid.isEmpty) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('resep')
        .where('author_uid', isEqualTo: creatorUid)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ResepModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map?;
    final UserModel? creator = args?['creator'];

    // ── PERBAIKAN: Tidak lagi pakai creator.jumlahResep atau resepList dari args ──
    final creatorUid = creator?.uid ?? '';
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final canFollow =
        creatorUid.isNotEmpty &&
        currentUid.isNotEmpty &&
        creatorUid != currentUid;

    controller = Get.put(
      CreatorProfileController().init(
        creatorUid: creatorUid,
        currentUid: currentUid,
      ),
      tag: creatorUid,
    );

    final String creatorName = creator?.nama ?? 'Chef';
    final String creatorUsername =
        creator?.email?.split('@').first ?? creatorName.toLowerCase();
    String creatorBio = creator?.bio?.trim() ?? '';
    final String? creatorPhoto = creator?.fotoProfil;

    bool creatorVerified = false;
    try {
      final dynamic c = creator as dynamic;
      final String? v = c.verified?.toString().toLowerCase();
      creatorVerified = v == 'true';
    } catch (_) {}

    return Scaffold(
      backgroundColor: _kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            // ── StreamBuilder membungkus seluruh scroll view ──────────────
            child: StreamBuilder<List<ResepModel>>(
              stream: _resepStream(creatorUid),
              builder: (context, snapshot) {
                // Gunakan list kosong saat loading, bukan data lama dari args
                final List<ResepModel> resepList = snapshot.hasData
                    ? snapshot.data!
                    : [];
                // jumlahResep selalu dari panjang list realtime, bukan cache
                final int jumlahResep = resepList.length;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── 1. SliverAppBar gradient ──────────────────────────────
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      stretch: true,
                      backgroundColor: _kOrange2,
                      elevation: 0,
                      leading: Padding(
                        padding: const EdgeInsets.all(8),
                        child: _GlassButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Get.back(),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const [StretchMode.blurBackground],
                        background: _HeaderBackground(
                          creatorName: creatorName,
                          creatorUsername: '@$creatorUsername',
                          creatorBio: creatorBio,
                          creatorPhoto: creatorPhoto,
                          creatorVerified: creatorVerified,
                          canFollow: canFollow,
                          followButton: _buildFollowButton(),
                        ),
                      ),
                    ),

                    // ── 2. Stats Card ──────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _StatsSection(
                        followService: _followService,
                        creatorUid: creatorUid,
                        currentUid: currentUid,
                        // jumlahResep dari realtime list, bukan cache/arguments
                        jumlahResep: jumlahResep,
                      ),
                    ),

                    // ── 3. Section Title ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_kOrange1, _kOrange2],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Resep dari Chef ini',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const Spacer(),
                            // Badge jumlah resep — tampil saat loading maupun sudah ada data
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData)
                              // Tampilkan loading indicator kecil saat pertama kali
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _kOrange2,
                                ),
                              )
                            else if (resepList.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_kOrange1, _kOrange2],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$jumlahResep resep',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── 4. Recipe Grid / Loading / Empty State ─────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
                      sliver:
                          snapshot.connectionState == ConnectionState.waiting &&
                              !snapshot.hasData
                          // Skeleton loading saat pertama kali stream belum emit
                          ? SliverToBoxAdapter(child: _LoadingState())
                          : resepList.isEmpty
                          ? SliverToBoxAdapter(child: _EmptyState())
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.72,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _RecipeCard(resep: resepList[i]),
                                childCount: resepList.length,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Follow Button ──────────────────────────────────────────────────────────
  Widget _buildFollowButton() {
    return Obx(() {
      final isFollowing = controller.isFollowing.value;
      final isLoading = controller.isLoadingFollow.value;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        child: isLoading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : _FollowButton(
                key: ValueKey(isFollowing),
                isFollowing: isFollowing,
                onTap: controller.toggleFollow,
              ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderBackground extends StatelessWidget {
  final String creatorName;
  final String creatorUsername;
  final String creatorBio;
  final String? creatorPhoto;
  final bool creatorVerified;
  final bool canFollow;
  final Widget followButton;

  const _HeaderBackground({
    required this.creatorName,
    required this.creatorUsername,
    required this.creatorBio,
    required this.creatorPhoto,
    required this.creatorVerified,
    required this.canFollow,
    required this.followButton,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFCC02), _kOrange3, _kOrange2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -40,
          right: -30,
          child: _DecorCircle(size: 160, opacity: 0.12),
        ),
        Positioned(
          bottom: 30,
          left: -50,
          child: _DecorCircle(size: 200, opacity: 0.08),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: _DecorCircle(size: 60, opacity: 0.10),
        ),

        // Curved bottom clip
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 30,
            decoration: const BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFE082)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
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
                      radius: 52,
                      backgroundColor: const Color(0xFFFFE0B2),
                      backgroundImage:
                          (creatorPhoto != null && creatorPhoto!.isNotEmpty)
                          ? NetworkImage(creatorPhoto!)
                          : null,
                      child: (creatorPhoto == null || creatorPhoto!.isEmpty)
                          ? const Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: _kOrange2,
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Name + verified badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        creatorName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (creatorVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF60A5FA),
                        size: 20,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 3),

                // Username
                Text(
                  creatorUsername,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Bio
                if (creatorBio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    creatorBio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],

                // Follow button
                if (canFollow) ...[
                  const SizedBox(height: 16),
                  SizedBox(width: 180, child: followButton),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOLLOW BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _FollowButton extends StatefulWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
  });

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.isFollowing
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white70, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mengikuti',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add_rounded,
                      color: _kOrange2,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Follow',
                      style: GoogleFonts.poppins(
                        color: _kOrange2,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _StatsSection extends StatelessWidget {
  final FollowService followService;
  final String creatorUid;
  final String currentUid;
  final int jumlahResep;

  const _StatsSection({
    required this.followService,
    required this.creatorUid,
    required this.currentUid,
    required this.jumlahResep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            // Followers
            Expanded(
              child: _StatItem(
                icon: Icons.people_alt_rounded,
                label: 'Followers',
                stream: followService.getFollowersCountStream(
                  creatorUid: creatorUid,
                ),
              ),
            ),
            _Divider(),
            // Following
            Expanded(
              child: _StatItem(
                icon: Icons.person_outline_rounded,
                label: 'Following',
                stream: followService.getFollowingCountStream(
                  currentUid: creatorUid,
                ),
              ),
            ),
            _Divider(),
            // Resep — nilai realtime dari StreamBuilder di parent
            Expanded(
              child: _StatItemStatic(
                icon: Icons.menu_book_rounded,
                label: 'Resep',
                value: jumlahResep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: Colors.black.withOpacity(0.07),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Stream<int> stream;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (_, snap) {
        final count = snap.data ?? 0;
        return _StatContent(icon: icon, label: label, value: count);
      },
    );
  }
}

class _StatItemStatic extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatItemStatic({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _StatContent(icon: icon, label: label, value: value);
  }
}

class _StatContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatContent({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _kOrange2, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          _formatCount(value),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECIPE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _RecipeCard extends StatefulWidget {
  final ResepModel resep;

  const _RecipeCard({required this.resep});

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _navigate() {
    final resep = widget.resep;
    final id = resep.id;
    if (id == null || id.isEmpty) return;

    // Delete controller lama agar onInit() dipanggil ulang dengan data resep baru.
    try {
      Get.delete<DetailResepController>(force: true);
    } catch (_) {}

    Get.toNamed(
      Routes.DETAIL_RESEP,
      arguments: resep,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resep;
    final hasImage = r.fotoCover != null && r.fotoCover!.isNotEmpty;
    final category = r.kategoriProvinsi ?? r.provinsi ?? '';

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        _navigate();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ──────────────────────────────────────────────
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo
                      hasImage
                          ? Image.network(
                              r.fotoCover!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),

                      // Gradient overlay tipis
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Category chip
                      if (category.isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kOrange1, _kOrange2],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // Rating chip
                      if (r.rating != null && r.rating! > 0)
                        Positioned(
                          bottom: 6,
                          right: 8,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: _kOrange1,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                r.rating!.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Info + Tombol ──────────────────────────────────────
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nama resep
                        Text(
                          r.namaResep ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: const Color(0xFF1A1A2E),
                            height: 1.3,
                          ),
                        ),

                        // Waktu masak
                        if (r.waktuMasak != null && r.waktuMasak!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 11,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                r.waktuMasak!,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                        // Tombol Lihat Resep
                        GestureDetector(
                          onTap: _navigate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kOrange1, _kOrange2],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: _kOrange2.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lihat Resep',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 9,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFFF3E0),
      child: const Center(
        child: Icon(Icons.restaurant_rounded, color: _kOrange2, size: 36),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING STATE (skeleton saat stream pertama kali loading)
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _kOrange2, strokeWidth: 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kOrange1.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.ramen_dining_rounded,
              size: 60,
              color: _kOrange2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chef ini belum membagikan resep',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pantau terus, mungkin ada resep baru\nyang segera hadir! 🍳',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILITY WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
