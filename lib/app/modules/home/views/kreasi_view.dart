import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jejakrasa_mobile_database/app/widgets/recipe_status_badge.dart';

import '../controllers/home_controller.dart';

class KreasiView extends GetView<HomeController> {
  const KreasiView({super.key});

  static const Color _accent = Color(0xFFF5A623);
  static const Color _coverFallback = Color(0xFFFFF3D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                final isLoading = controller.isLoading.value;
                final resepSaya = controller.resepSaya;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (resepSaya.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: resepSaya.length,
                  itemBuilder: (context, index) {
                    final resep = resepSaya[index];
                    return _RecipeCard(
                      resep: resep,
                      onTap: () =>
                          Get.toNamed('/detail-resep', arguments: resep),
                      onEdit: () {
                        Get.toNamed('/edit-resep', arguments: resep);
                      },
                      onDelete: (id) => _confirmAndDelete(id),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFBC02D), Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kreasi Saya 🍳',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Resep yang kamu buat',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/buat-resep'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _accent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Buat',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant, size: 65, color: _accent),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada kreasi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat resep pertamamu dan\n'
            'bagi ke komunitas kuliner',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/buat-resep'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Buat Resep Pertama',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(String? id) async {
    if (id == null || id.trim().isEmpty) {
      Get.snackbar('Error', 'ID resep tidak valid.');
      return;
    }

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus resep?'),
        content: const Text('Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    await controller.hapusResep(id);
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.resep,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final dynamic resep; // keeps view decoupled; actual type is ResepModel
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final ValueChanged<String?> onDelete;

  @override
  Widget build(BuildContext context) {
    final String? id = resep.id;
    final String status = (resep.status ?? 'pending').toString();
    final bool isPending = status == 'pending';

    final String namaResep = (resep.namaResep ?? '-').toString();
    final String provinsi = (resep.provinsi ?? '').toString();
    final String? fotoCover = resep.fotoCover;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _RecipeCover(fotoCover: fotoCover, isPending: isPending),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          }
                          if (value == 'hapus') {
                            onDelete(id);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 6),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'hapus',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.red.shade600,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (status.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: RecipeStatusBadge(status: status),
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
                  Text(
                    namaResep,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 11,
                        color: KreasiView._accent,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          provinsi.isEmpty ? '-' : provinsi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (status == 'rejected') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red.shade700,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                        ),
                        icon: const Icon(Icons.edit_note_rounded, size: 14),
                        label: Text(
                          'Revisi',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCover extends StatelessWidget {
  const _RecipeCover({required this.fotoCover, required this.isPending});

  final String? fotoCover;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final String? url = fotoCover;

    Widget img = (url != null && url.isNotEmpty)
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: KreasiView._coverFallback,
                child: const Icon(
                  Icons.restaurant,
                  color: KreasiView._accent,
                  size: 40,
                ),
              );
            },
          )
        : Container(
            color: KreasiView._coverFallback,
            child: const Icon(
              Icons.restaurant,
              color: KreasiView._accent,
              size: 40,
            ),
          );

    if (!isPending) return img;

    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: img,
    );
  }
}
