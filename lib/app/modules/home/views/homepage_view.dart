import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/home_controller.dart';
import '../widgets/recipe_feed_card.dart';

class HomepageView extends GetView<HomeController> {
  const HomepageView({super.key});

  static const Color _accent = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSearchBar(),
                  ),
                  Obx(() {
                    final searching = controller.searchQuery.value
                        .trim()
                        .isNotEmpty;

                    if (searching) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildSearchResults(),
                      );
                    }
                    return Column(
                      children: [
                        _buildFeedTabs(),
                        const SizedBox(height: 4),
                        Obx(() => _buildTabContent(context)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================
  // FEED TABS — Untuk Anda | Mengikuti | Terbaru
  // =============================================
  Widget _buildFeedTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTabItem(0, 'Untuk Anda', Icons.auto_awesome_rounded),
              _buildTabItem(1, 'Mengikuti', Icons.people_rounded),
              _buildTabItem(2, 'Terbaru', Icons.schedule_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isActive = controller.feedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.feedTabIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFBC02D), Color(0xFFF5A623)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _accent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================
  // TAB CONTENT — Switch between feed views
  // =============================================
  Widget _buildTabContent(BuildContext context) {
    switch (controller.feedTabIndex.value) {
      case 0:
        return _buildUntukAndaTab();
      case 1:
        return _buildMengikutiTab(context);
      case 2:
        return _buildTerbaruTab(context);
      default:
        return _buildUntukAndaTab();
    }
  }

  // =============================================
  // TAB 0 — Untuk Anda (existing homepage content)
  // =============================================
  Widget _buildUntukAndaTab() {
    return Column(
      children: [
        const SizedBox(height: 4),
        _buildBanner(),
        _buildKategoriProvinsi(),
        _buildPencarianPopuler(),
        _buildResepTerbaru(),
        const SizedBox(height: 24),
      ],
    );
  }

  // Banner
  Widget _buildBanner() {
    return _BannerWidget(controller: controller, accent: _accent);
  }

  // =============================================
  // TAB 1 — Mengikuti (Following Feed)
  // =============================================
  Widget _buildMengikutiTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingFeed.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
              strokeWidth: 2.5,
            ),
          ),
        );
      }

      if (controller.followingIds.isEmpty) {
        return _buildEmptyState(
          icon: Icons.people_outline_rounded,
          title: 'Belum Mengikuti Siapa pun',
          subtitle:
              'Ikuti creator favoritmu untuk melihat\nfeed resep terbaru mereka di sini.',
        );
      }

      if (controller.followingRecipes.isEmpty) {
        return _buildEmptyState(
          icon: Icons.restaurant_menu_rounded,
          title: 'Belum Ada Resep',
          subtitle:
              'Creator yang kamu ikuti belum\nmemposting resep. Tunggu update terbaru!',
        );
      }

      return _buildResponsiveFeedGrid(context, controller.followingRecipes);
    });
  }

  // =============================================
  // TAB 2 — Terbaru (Latest Feed)
  // =============================================
  Widget _buildTerbaruTab(BuildContext context) {
    return Obx(() {
      if (controller.latestRecipes.isEmpty) {
        return _buildEmptyState(
          icon: Icons.schedule_rounded,
          title: 'Belum Ada Resep Terbaru',
          subtitle: 'Resep terbaru akan muncul di sini.',
        );
      }

      return _buildResponsiveFeedGrid(context, controller.latestRecipes);
    });
  }

  // =============================================
  // RESPONSIVE FEED GRID
  // =============================================
  Widget _buildResponsiveFeedGrid(BuildContext context, List recipes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.of(context).size.width;
        if (width > 900) {
          return _buildGridFeed(recipes, 3);
        } else if (width > 600) {
          return _buildGridFeed(recipes, 2);
        } else {
          return _buildListFeed(recipes);
        }
      },
    );
  }

  Widget _buildListFeed(List recipes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: recipes.map((resep) {
          return Obx(
            () => RecipeFeedCard(
              resep: resep,
              creatorName: controller.getCreatorName(resep.authorUid),
              creatorPhoto: controller.getCreatorPhoto(resep.authorUid),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridFeed(List recipes, int crossAxisCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final resep = recipes[index];
          return Obx(
            () => RecipeFeedCard(
              resep: resep,
              creatorName: controller.getCreatorName(resep.authorUid),
              creatorPhoto: controller.getCreatorPhoto(resep.authorUid),
            ),
          );
        },
      ),
    );
  }

  // =============================================
  // EMPTY STATE — Modern UI
  // =============================================
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accent.withOpacity(0.12), const Color(0xFFFFF3E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 44, color: _accent.withOpacity(0.7)),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBC02D), Color(0xFFF5A623)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.feedTabIndex.value = 0,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: Text(
                    'Jelajahi Resep',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // Header
  // =============================================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBC02D), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kuliner Nusantara',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Get.toNamed('/notification'),
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // Search bar
  // =============================================
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.searchResep,
        decoration: InputDecoration(
          hintText: 'Cari makanan nusantara...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
          prefixIcon: const Icon(Icons.search, color: _accent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // =============================================
  // Search results — gabungan user + resep
  // =============================================
  Widget _buildSearchResults() {
    return Obx(() {
      final resepList = controller.searchResults;
      final userList = controller.searchUsers;

      final hasUsers = userList.isNotEmpty;
      final hasResep = resepList.isNotEmpty;

      if (!hasUsers && !hasResep) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Tidak ada hasil ditemukan',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (hasUsers) ...[
            const SizedBox(height: 2),
            _buildSearchSectionHeader(
              title: '👤 Pengguna',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 10),
            _buildUserResults(userList),
            const SizedBox(height: 18),
          ],
          if (hasResep) ...[
            _buildSearchSectionHeader(
              title: '🍜 Resep',
              icon: Icons.restaurant_menu_rounded,
            ),
            const SizedBox(height: 10),
            _buildResepResults(resepList),
          ],
        ],
      );
    });
  }

  Widget _buildSearchSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _accent, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserResults(List users) {
    return Column(
      children: List.generate(users.length, (index) {
        final user = users[index];

        // jumlah resep harus sinkron dengan CreatorProfile.
        // HomeController menyediakan cache `resepCountByCreator`.
        final creatorUid = user.uid?.trim();
        final jumlahResep = (creatorUid != null && creatorUid.isNotEmpty)
            ? (controller.resepCountByCreator[creatorUid] ?? 0)
            : (user.jumlahResep ?? 0);

        final bio = (user.bio ?? '').toString().trim();
        final foto = (user.fotoProfil ?? '').toString().trim();
        final nama = (user.nama ?? '').toString().trim();
        final userId = user.uid?.toString().trim();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              if (userId == null || userId.isEmpty) return;
              Get.toNamed('/creator-profile', arguments: {'creator': user});
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: (foto.isNotEmpty)
                  ? Image.network(
                      foto,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFFFFFBEE),
                      child: Icon(Icons.person_rounded, color: _accent),
                    ),
            ),
            title: Text(
              nama.isNotEmpty ? nama : 'User',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            subtitle: Text(
              [bio].where((e) => e.isNotEmpty).join('').trim().isNotEmpty
                  ? bio
                  : 'Bio belum tersedia',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accent.withOpacity(0.20),
                    _accent.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 14, color: _accent),
                  const SizedBox(width: 6),
                  Text(
                    '$jumlahResep',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResepResults(List resepList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resepList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final resep = resepList[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: (resep.fotoCover != null && resep.fotoCover!.isNotEmpty)
                  ? Image.network(
                      resep.fotoCover!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 52,
                      height: 52,
                      color: const Color(0xFFFFFBEE),
                      child: const Icon(Icons.fastfood_outlined),
                    ),
            ),
            title: Text(
              resep.namaResep ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              [
                resep.provinsi,
                resep.waktuMasak,
              ].whereType<String>().where((e) => e.isNotEmpty).join(' • '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            onTap: () {
              if (resep.id != null) {
                Get.toNamed('/detail-resep', arguments: resep);
              }
            },
          ),
        );
      },
    );
  }

  // =============================================
  // EXISTING — Kategori Provinsi
  // =============================================
  Widget _buildKategoriProvinsi() {
    final kategori = [
      {
        'nama': 'Jawa',
        'gambar': 'https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nama': 'Sumatera',
        'gambar': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nama': 'Kalimantan',
        'gambar': 'https://plus.unsplash.com/premium_photo-1730035377575-67e5522b09c9?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      },
      {
        'nama': 'Sulawesi',
        'gambar': 'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nama': 'Bali',
        'gambar': 'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1?auto=format&fit=crop&w=600&q=80',
      },
      {
        'nama': 'Papua',
        'gambar': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=600&q=80',
      },
    ];

    return Padding(
      // Memberi jarak bawah ekstra agar tidak mepet navbar/floating button
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eksplorasi Wilayah',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed('/all-provinces'),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // Lebih tinggi dan tidak gepeng
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kategori.length,
              itemBuilder: (context, index) {
                final item = kategori[index];
                final nama = item['nama'].toString();
                final gambar = item['gambar'].toString();

                return GestureDetector(
                  onTap: () => Get.toNamed(
                    '/kategori-provinsi',
                    arguments: nama,
                  ),
                  child: Container(
                    width: 160, // Lebar proporsional
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28), // Rounded besar
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            gambar,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient overlay halus
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        // Text di bawah kiri
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nama,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Jumlah resep lebih subtle
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('resep')
                                    .where(
                                      'kategori_provinsi',
                                      isEqualTo: nama,
                                    )
                                    .where('status', isEqualTo: 'approved')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final count = snapshot.data?.docs.length ?? 0;
                                  return Row(
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu_rounded,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$count resep',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
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
      ),
    );
  }

  // =============================================
  // EXISTING — Resep Populer
  // =============================================
  Widget _buildPencarianPopuler() {
    return Obx(() {
      final populer = controller.resepPopuler;
      if (populer.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resep Populer',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/popular-recipes'),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: _accent),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: populer.length,
                itemBuilder: (context, index) {
                  final resep = populer[index];
                  return GestureDetector(
                    onTap: () {
                      if (resep.id != null) {
                        Get.toNamed('/detail-resep', arguments: resep);
                      }
                    },
                    child: Container(
                      width: 175,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child:
                                (resep.fotoCover != null &&
                                    resep.fotoCover!.isNotEmpty)
                                ? Image.network(
                                    resep.fotoCover!,
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 130,
                                    color: const Color(0xFFFFFBEE),
                                    child: const Icon(
                                      Icons.fastfood_outlined,
                                      color: _accent,
                                      size: 40,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resep.namaResep ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    resep.provinsi ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: _accent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        resep.waktuMasak ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                        ),
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
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // =============================================
  // EXISTING — Resep Terbaru
  // =============================================
  Widget _buildResepTerbaru() {
    return Obx(() {
      final terbaru = controller.resepTerbaru;
      if (terbaru.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resep Terbaru',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/newest-recipes'),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: _accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: terbaru.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final resep = terbaru[index];
                return GestureDetector(
                  onTap: () {
                    if (resep.id != null) {
                      Get.toNamed('/detail-resep', arguments: resep);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(20),
                          ),
                          child:
                              (resep.fotoCover != null &&
                                  resep.fotoCover!.isNotEmpty)
                              ? Image.network(
                                  resep.fotoCover!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 90,
                                  height: 90,
                                  color: const Color(0xFFFFFBEE),
                                  child: const Icon(
                                    Icons.restaurant_menu_outlined,
                                    color: _accent,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resep.namaResep ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [resep.provinsi, resep.waktuMasak]
                                      .whereType<String>()
                                      .where((e) => e.isNotEmpty)
                                      .join(' • '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    resep.tingkatKesulitan ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: _accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================
// Banner Widget
// ============================================================
class _BannerWidget extends StatefulWidget {
  final HomeController controller;
  final Color accent;

  const _BannerWidget({required this.controller, required this.accent});

  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.controller.bannerIndex.value,
    );
    widget.controller.bindBannerPageController(_pageController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sliderItems = widget.controller.resepFeatured.take(3).toList();
      if (sliderItems.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pageController,
              itemCount: sliderItems.length,
              onPageChanged: (i) {
                widget.controller.bannerIndex.value = i;
              },
              itemBuilder: (context, index) {
                final resep = sliderItems[index];
                return GestureDetector(
                  onTap: () {
                    if (resep.id != null) {
                      Get.toNamed('/detail-resep', arguments: resep);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      image:
                          (resep.fotoCover != null &&
                              resep.fotoCover!.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(resep.fotoCover!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: const Color(0xFFFFF3D9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Most Favorite',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          bottom: 28,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resep.namaResep ?? 'Resep Unggulan',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [resep.provinsi, resep.waktuMasak]
                                    .whereType<String>()
                                    .where((e) => e.isNotEmpty)
                                    .join(' • '),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                sliderItems.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: widget.controller.bannerIndex.value == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.controller.bannerIndex.value == i
                        ? widget.accent
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
