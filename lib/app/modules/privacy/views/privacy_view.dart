import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../controllers/privacy_controller.dart';

class PrivacyView extends GetView<PrivacyController> {
  const PrivacyView({super.key});

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow(),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeColor: AppTheme.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color ?? Colors.white),
        label: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.accent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildGhostButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppTheme.accent),
        label: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.accent.withOpacity(0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Privasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                _buildSwitchRow(
                  title: 'Akun Privat',
                  subtitle: 'Jika aktif, akun creator kamu menjadi private.',
                  value: controller.isPrivate.value,
                  onChanged: (v) {
                    controller.isPrivate.value = v;
                    controller.updateField('is_private', v);
                  },
                ),
                const SizedBox(height: 12),
                _buildSwitchRow(
                  title: 'Tampilkan di Pencarian',
                  subtitle: 'Konten kamu akan muncul saat pengguna mencari.',
                  value: controller.showInSearch.value,
                  onChanged: (v) {
                    controller.showInSearch.value = v;
                    controller.updateField('show_in_search', v);
                  },
                ),
                const SizedBox(height: 12),
                _buildSwitchRow(
                  title: 'Status Online',
                  subtitle: 'Tampilkan status online untuk sesama pengguna.',
                  value: controller.showOnlineStatus.value,
                  onChanged: (v) {
                    controller.showOnlineStatus.value = v;
                    controller.updateField('show_online_status', v);
                  },
                ),
                const SizedBox(height: 12),
                _buildSwitchRow(
                  title: 'Izinkan Mention',
                  subtitle:
                      'Izinkan orang lain untuk mention kamu di platform.',
                  value: controller.allowMentions.value,
                  onChanged: (v) {
                    controller.allowMentions.value = v;
                    controller.updateField('allow_mentions', v);
                  },
                ),

                const SizedBox(height: 18),
                _buildSectionTitle(
                  'Aksi Akun',
                  subtitle: 'Kontrol data dan keamanan akun kamu',
                ),
                const SizedBox(height: 10),

                _buildGhostButton(
                  title: 'Hapus Riwayat Pencarian',
                  icon: Icons.history_toggle_off,
                  onTap: controller.clearSearchHistoryDummy,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  title: 'Ubah Kata Sandi',
                  icon: Icons.lock_reset,
                  onTap: controller.resetPassword,
                ),
                const SizedBox(height: 12),
                _buildGhostButton(
                  title: 'Hapus Akun',
                  icon: Icons.delete_forever,
                  onTap: controller.deleteAccount,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }
}
