import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/buat-resep'),
        backgroundColor: const Color(0xFFF5A623),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Buat Resep',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = controller.user.value;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.transparent),
                      Text(
                        'Profil',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                ),
                // Foto Profil
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade300,
                  child:
                      const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // Nama
                Text(
                  user?.nama ?? 'Pengguna',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('${user?.jumlahResep ?? 0}', 'Resep'),
                    const SizedBox(width: 32),
                    _buildStat(
                        '${user?.pengikut?.length ?? 0}', 'Pengikut'),
                    const SizedBox(width: 32),
                    _buildStat(
                        '${user?.mengikuti?.length ?? 0}', 'Mengikuti'),
                  ],
                ),
                const SizedBox(height: 16),
                // Tab
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedTab.value = 0,
                        child: Obx(() => Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: controller.selectedTab.value == 0
                                        ? const Color(0xFFF5A623)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Resep Saya',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight:
                                      controller.selectedTab.value == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: controller.selectedTab.value == 0
                                      ? const Color(0xFFF5A623)
                                      : Colors.grey,
                                ),
                              ),
                            )),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedTab.value = 1,
                        child: Obx(() => Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: controller.selectedTab.value == 1
                                        ? const Color(0xFFF5A623)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Disimpan',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight:
                                      controller.selectedTab.value == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: controller.selectedTab.value == 1
                                      ? const Color(0xFFF5A623)
                                      : Colors.grey,
                                ),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Konten Tab
                Obx(() => controller.selectedTab.value == 0
                    ? _buildResepSaya()
                    : _buildDisimpan()),
                const SizedBox(height: 16),
                // Tombol Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.logout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildResepSaya() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant,
            size: 48,
            color: Color(0xFFF5A623),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada resep',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Bagikan resep pertamamu ke komunitas!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisimpan() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 48,
            color: Color(0xFFF5A623),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada resep tersimpan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Simpan resep favoritmu di sini!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}