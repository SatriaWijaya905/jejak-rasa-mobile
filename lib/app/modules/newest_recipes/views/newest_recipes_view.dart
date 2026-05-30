import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/resep_model.dart';
import '../controllers/newest_recipes_controller.dart';

class NewestRecipesView extends GetView<NewestRecipesController> {
  const NewestRecipesView({super.key});

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
          'Resep Terbaru',
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
            icon: Icons.schedule_rounded,
            title: 'Belum ada resep terbaru',
            subtitle: 'Resep terbaru akan muncul di sini.',
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 900
                ? 4
                : width > 600
                    ? 3
                    : 2;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: controller.recipes.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.74,
                ),
                itemBuilder: (context, index) {
                  final resep = controller.recipes[index];
                  return _RecipeCard(resep: resep);
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final ResepModel resep;

  const _RecipeCard({required this.resep});

  static const Color _accent = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (resep.id != null) {
          Get.toNamed('/detail-resep', arguments: resep);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: (resep.fotoCover != null && resep.fotoCover!.isNotEmpty)
                    ? Image.network(
                        resep.fotoCover!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFFFFBEE),
                          child: const Icon(
                            Icons.fastfood_outlined,
                            color: _accent,
                            size: 36,
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFFFFBEE),
                        child: const Icon(
                          Icons.fastfood_outlined,
                          color: _accent,
                          size: 36,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resep.namaResep ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${resep.provinsi ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: _accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        resep.waktuMasak ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
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

