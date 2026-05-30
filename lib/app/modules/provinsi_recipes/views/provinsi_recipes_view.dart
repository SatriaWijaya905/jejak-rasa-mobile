import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/provinsi_recipes_controller.dart';
import '../../home/widgets/recipe_feed_card.dart';

class ProvinsiRecipesView extends GetView<ProvinsiRecipesController> {
  const ProvinsiRecipesView({super.key});

  static const Color _accent = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: _accent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Kuliner ${controller.provinsi}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          );
        }

        if (controller.recipes.isEmpty) {
          return _EmptyState(
            icon: Icons.restaurant_menu_rounded,
            title: 'Belum ada resep',
            subtitle: 'Jadilah yang pertama membagikan\nresep dari ${controller.provinsi}!',
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            if (width > 900) {
              return _buildGridFeed(3);
            } else if (width > 600) {
              return _buildGridFeed(2);
            } else {
              return _buildListFeed();
            }
          },
        );
      }),
    );
  }

  Widget _buildListFeed() {
    return RefreshIndicator(
      onRefresh: () async => controller.onInit(),
      color: _accent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.recipes.length,
        itemBuilder: (context, index) {
          final resep = controller.recipes[index];
          return Obx(() => RecipeFeedCard(
            resep: resep,
            creatorName: controller.getCreatorName(resep.authorUid),
            creatorPhoto: controller.getCreatorPhoto(resep.authorUid),
          ));
        },
      ),
    );
  }

  Widget _buildGridFeed(int crossAxisCount) {
    return RefreshIndicator(
      onRefresh: () async => controller.onInit(),
      color: _accent,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.recipes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final resep = controller.recipes[index];
          return Obx(() => RecipeFeedCard(
            resep: resep,
            creatorName: controller.getCreatorName(resep.authorUid),
            creatorPhoto: controller.getCreatorPhoto(resep.authorUid),
          ));
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const Color _accent = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _accent.withOpacity(0.14),
                    const Color(0xFFFFF3E0),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: 44,
                color: _accent.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
