import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/favorit_controller.dart';

class FavoritView extends GetView<FavoritController> {
  const FavoritView({super.key});

  static const Color _accent = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFBC02D), Color(0xFFF57C00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bookmark, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resep Tersimpan', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Obx(() => Text('${controller.favoritList.length} resep', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.favoritList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(color: _accent.withOpacity(0.08), shape: BoxShape.circle),
                          child: const Icon(Icons.bookmark_border, size: 60, color: _accent),
                        ),
                        const SizedBox(height: 20),
                        Text('Belum ada resep tersimpan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text('Tap ❤️ di resep untuk menyimpannya', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.78),
                  itemCount: controller.favoritList.length,
                  itemBuilder: (context, index) {
                    final resep = controller.favoritList[index];
                    return GestureDetector(
                      onTap: () => Get.toNamed('/detail-resep', arguments: resep),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    (resep.fotoCover != null && resep.fotoCover!.isNotEmpty)
                                        ? Image.network(resep.fotoCover!, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFFF3D9), child: const Icon(Icons.restaurant, color: _accent, size: 40)))
                                        : Container(color: const Color(0xFFFFF3D9), child: const Icon(Icons.restaurant, color: _accent, size: 40)),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: GestureDetector(
                                        onTap: () => controller.toggleFavorit(resep.id!),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
                                          child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(resep.namaResep ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 11, color: _accent),
                                      const SizedBox(width: 2),
                                      Expanded(child: Text(resep.provinsi ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
