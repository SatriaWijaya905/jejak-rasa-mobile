import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jejakrasa_mobile_database/app/modules/home/controllers/home_controller.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  void _showPengaturan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pengaturan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(Icons.person_outline, 'Edit Profil', () {}),
            _buildSettingItem(
                Icons.notifications_outlined, 'Notifikasi', () {}),
            _buildSettingItem(Icons.shield_outlined, 'Privasi', () {}),
            _buildSettingItem(Icons.help_outline, 'Bantuan', () {}),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.logout, color: Color(0xFFF5A623)),
              title: Text(
                'Keluar',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF5A623),
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing:
                  const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: controller.logout,
            ),
          ],
        ),
      ),
    );
  }

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
                      const SizedBox(width: 48),
                      Text(
                        'Profil',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showPengaturan(context),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),
                ),
                // Foto Profil
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF5A623),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person,
                        size: 50, color: Colors.grey),
                  ),
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
                    _buildStat(Icons.restaurant,
                        '${user?.jumlahResep ?? 0}', 'Resep'),
                    const SizedBox(width: 32),
                    _buildStat(Icons.people_outline,
                        '${user?.pengikut?.length ?? 0}', 'Pengikut'),
                    const SizedBox(width: 32),
                    _buildStat(Icons.favorite_outline,
                        '${user?.mengikuti?.length ?? 0}', 'Mengikuti'),
                  ],
                ),
                const SizedBox(height: 24),
                // Tombol Kreasi & Favorit
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Kreasi Saya
                      GestureDetector(
                        onTap: () =>
                            Get.find<HomeController>().changeTab(1),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFF5A623)
                                    .withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5A623)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.restaurant,
                                    color: Color(0xFFF5A623), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kreasi Resep Saya',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Obx(() => Text(
                                          '${controller.user.value?.jumlahResep ?? 0} resep telah dibuat',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Color(0xFFF5A623)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Favorit
                      GestureDetector(
                        onTap: () =>
                            Get.find<HomeController>().changeTab(2),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFF5A623)
                                    .withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5A623)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.favorite,
                                    color: Color(0xFFF5A623), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Resep Favorit',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Lihat resep yang kamu simpan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Color(0xFFF5A623)),
                            ],
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF5A623), size: 20),
        const SizedBox(height: 4),
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

  Widget _buildSettingItem(
      IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}