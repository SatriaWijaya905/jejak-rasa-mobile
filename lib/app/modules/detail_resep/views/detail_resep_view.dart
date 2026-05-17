import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jejakrasa_mobile_database/app/modules/favorit/controllers/favorit_controller.dart';
import '../controllers/detail_resep_controller.dart';

class DetailResepView extends GetView<DetailResepController> {
  const DetailResepView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final resep = controller.resep.value;
        if (resep == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: const Color(0xFFF5A623),
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              actions: [
                Obx(() {
                  if (!Get.isRegistered<FavoritController>()) {
                    return IconButton(
                      onPressed: () {
                        Get.put(FavoritController());
                        Get.find<FavoritController>().toggleFavorit(
                          resep.id ?? '',
                        );
                      },
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                    );
                  }
                  final favoritController = Get.find<FavoritController>();
                  final isFav = favoritController.isFavorit(resep.id ?? '');
                  return IconButton(
                    onPressed: () {
                      favoritController.toggleFavorit(resep.id ?? '');
                    },
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                  );
                }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resep.namaResep ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          resep.waktuMasak ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.bar_chart,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resep.tingkatKesulitan ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${resep.rating ?? 0} (${resep.jumlahReview ?? 0} ulasan)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5A623).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        resep.provinsi ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFF5A623),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bahan-bahan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (resep.bahan != null)
                      ...resep.bahan!.map(
                        (bahan) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Color(0xFFF5A623),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bahan,
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Langkah Memasak',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (resep.langkah != null && resep.langkah!.isNotEmpty)
                      ...resep.langkah!.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5A623),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value.deskripsi ?? '',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    else
                      Text(
                        'Belum ada langkah memasak',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
