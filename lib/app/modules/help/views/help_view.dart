import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../controllers/help_controller.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.cardShadow(),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        iconColor: AppTheme.accent,
        collapsedIconColor: AppTheme.accent,
        title: Text(
          question,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        children: [
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.cardShadow(),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.accent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tidak perlu Rx/Obx untuk TabBar; cukup DefaultTabController.
    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bantuan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.25),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.accent,
                  unselectedLabelColor: Colors.grey.shade600,
                  tabs: const [
                    Tab(text: 'FAQ'),
                    Tab(text: 'Kontak'),
                  ],
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w800),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // FAQ
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.cardShadow(),
                            ),
                            child: Text(
                              'Pertanyaan paling sering ditanyakan',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...controller.faqItems.map(
                            (item) => _buildFaqItem(item['q']!, item['a']!),
                          ),
                        ],
                      ),
                    ),

                    // Kontak
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: Column(
                        children: [
                          _buildContactCard(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            subtitle: 'support@jejakrasa.id',
                            onTap: () => Get.snackbar(
                              'Info',
                              'Link email belum disiapkan.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildContactCard(
                            icon: Icons.camera_alt_outlined,
                            title: 'Instagram',
                            subtitle: '@jejakrasa',
                            onTap: () => Get.snackbar(
                              'Info',
                              'Link Instagram belum disiapkan.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildContactCard(
                            icon: Icons.chat_bubble_outline,
                            title: 'Live Chat',
                            subtitle: 'Respon cepat (dummy)',
                            onTap: () => Get.snackbar(
                              'Info',
                              'Live chat belum tersedia.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildContactCard(
                            icon: Icons.phone_outlined,
                            title: 'Telepon',
                            subtitle: '+62 812-0000-0000',
                            onTap: () => Get.snackbar(
                              'Info',
                              'Nomor telepon belum bisa dihubungi dari aplikasi.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
