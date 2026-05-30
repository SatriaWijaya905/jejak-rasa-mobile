import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  static const Color _accent = Color(0xFFF5A623);

  String _timeAgo(dynamic createdAt) {
    if (createdAt == null) return '';

    // Firestore timestamp yang benar akan berupa Timestamp.
    if (createdAt is Timestamp) {
      final dateTime = createdAt.toDate();
      final diff = DateTime.now().difference(dateTime);
      if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} thn lalu';
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} bln lalu';
      if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} mgg lalu';
      if (diff.inDays > 0) return '${diff.inDays} hari lalu';
      if (diff.inHours > 0) return '${diff.inHours} jam lalu';
      if (diff.inMinutes > 0) return '${diff.inMinutes} mnt lalu';
      return 'Baru saja';
    }

    // Jika tipe tidak sesuai (mis. null / serverTimestamp belum tersinkron / unexpected type)
    // jangan crash.
    return '';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'follow':
        return Icons.person_add_alt_1_rounded;
      case 'recipe':
        return Icons.restaurant_menu_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'comment_recipe':
        return Icons.comment_rounded;
      case 'save_recipe':
        return Icons.favorite;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'follow':
        return const Color(0xFF4ADE80);
      case 'recipe':
        return _accent;
      case 'review':
        return const Color(0xFFFFB800);
      case 'comment_recipe':
        return const Color(0xFF60A5FA);
      case 'save_recipe':
        return const Color(0xFFFF6B6B);
      default:
        return Colors.grey;
    }
  }

  Widget _buildNewRecipeLargeCard({
    required Map<String, dynamic> item,
    required bool isRead,
  }) {
    final String timeAgo = _timeAgo(item['created_at']);

    final String provinceText =
        ((item['province'] ?? item['kategori_provinsi']) ?? '').toString();
    final String recipeNameText =
        ((item['recipe_name'] ?? item['nama_resep']) ?? '').toString();
    final String imageUrl = ((item['recipe_image'] ?? item['foto_cover']) ?? '')
        .toString();

    // Gunakan sender_name atau message untuk info creator
    final String senderName = (item['sender_name'] ?? 'Seseorang').toString();
    final String creatorInfo = '$senderName membagikan resep baru';

    final double? rating = (item['rating'] as num?)?.toDouble();
    final dynamic cookTimeRaw = item['cook_time'] ?? item['waktu_masak'];
    final String cookTimeText = (cookTimeRaw ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(24),
        border: isRead
            ? Border.all(color: Colors.black.withOpacity(0.04))
            : Border.all(color: _accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: creator info + unread indicator + time
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    image:
                        (item['sender_photo'] != null &&
                            item['sender_photo'].toString().isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(item['sender_photo']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      (item['sender_photo'] == null ||
                          item['sender_photo'].toString().isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creatorInfo,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
              ],
            ),
          ),

          // Gambar resep
          if (imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant_menu_rounded),
                ),
              ),
            )
          else
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.restaurant_menu_rounded, size: 40),
              ),
            ),

          // Body konten
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provinceText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provinceText,
                      style: GoogleFonts.poppins(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                Text(
                  recipeNameText.isNotEmpty ? recipeNameText : 'Resep Baru',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Info rating & durasi & CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: const Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating != null ? rating.toStringAsFixed(1) : '0.0',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cookTimeText.isNotEmpty ? cookTimeText : '-',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    // CTA "Lihat Resep →"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF5A623), Color(0xFFFF7B00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Lihat Resep',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAnnouncementCard({
    required Map<String, dynamic> item,
    required bool isRead,
  }) {
    final String timeAgo = _timeAgo(item['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRead
              ? [Colors.white, Colors.white]
              : [const Color(0xFFFFF3E0), const Color(0xFFFFF8E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRead
              ? Colors.black.withOpacity(0.04)
              : _accent.withOpacity(0.5),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isRead
                ? Colors.black.withOpacity(0.03)
                : _accent.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRead ? Colors.grey.shade100 : _accent.withOpacity(0.15),
            ),
            child: Icon(
              Icons.campaign_rounded,
              color: isRead ? Colors.grey.shade400 : _accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Badge & Time)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.grey.shade200 : _accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ADMIN',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isRead ? Colors.grey.shade600 : Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                Text(
                  item['title'] ?? 'Pengumuman Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isRead ? Colors.black87 : const Color(0xFFE05C1A),
                  ),
                ),
                const SizedBox(height: 4),
                // Message
                Text(
                  item['message'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead) const SizedBox(width: 10),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactNotificationCard({
    required Map<String, dynamic> item,
    required String type,
    required bool isRead,
  }) {
    final String timeAgo = _timeAgo(item['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(20),
        border: isRead
            ? Border.all(color: Colors.black.withOpacity(0.04))
            : Border.all(color: _accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image:
                      (item['sender_photo'] != null &&
                          item['sender_photo'].toString().isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(item['sender_photo']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    (item['sender_photo'] == null ||
                        item['sender_photo'].toString().isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getColorForType(type),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _getIconForType(type),
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] ?? 'Notifikasi',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isRead
                              ? FontWeight.w600
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['message'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isRead ? Colors.grey.shade600 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead) const SizedBox(width: 10),
          if (!isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
        title: Row(
          children: [
            Text(
              'Notifikasi',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              if (controller.unreadCount.value > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${controller.unreadCount.value}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
            onSelected: (value) async {
              if (value == 1) {
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );
                await controller.markAllAsRead();
                if (Get.isDialogOpen ?? false) Get.back();
                Get.snackbar(
                  'Berhasil',
                  'Semua notifikasi ditandai dibaca',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
              if (value == 2) {
                final shouldDelete = await Get.dialog<bool>(
                  AlertDialog(
                    title: Text(
                      'Hapus semua notifikasi?',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Tindakan ini hanya menghapus notifikasi milik akun Anda.',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text(
                          'Hapus',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE53935),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldDelete != true) return;

                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );
                await controller.deleteAllNotifications();
                if (Get.isDialogOpen ?? false) Get.back();

                Get.snackbar(
                  'Berhasil',
                  'Semua notifikasi dihapus',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.check_circle_rounded),
                  title: Text('✓ Tandai Semua Dibaca'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.delete_outline_rounded),
                  title: Text('🗑 Hapus Semua'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            final type = item['type'] ?? 'info';

            final isRead = item['is_read'] ?? true;

            final notifId = (item['id'] as String?) ?? '';

            return Stack(
              children: [
                GestureDetector(
                  onTap: () => controller.handleNotificationTap(item),
                  child: type == 'announcement'
                      ? _buildAdminAnnouncementCard(item: item, isRead: isRead)
                      : type == 'new_recipe'
                      ? _buildNewRecipeLargeCard(item: item, isRead: isRead)
                      : _buildCompactNotificationCard(
                          item: item,
                          type: type,
                          isRead: isRead,
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        if (notifId.trim().isEmpty) {
                          Get.snackbar(
                            'Informasi',
                            'Data notifikasi tidak valid',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        final shouldDelete = await Get.dialog<bool>(
                          AlertDialog(
                            title: Text(
                              'Hapus Notifikasi?',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Notifikasi ini akan dihapus dari akun Anda.',
                              style: GoogleFonts.poppins(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: Text(
                                  'Hapus',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFE53935),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete != true) return;

                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );
                        await controller.deleteOneNotification(notifId);
                        if (Get.isDialogOpen ?? false) Get.back();

                        Get.snackbar(
                          'Berhasil',
                          'Notifikasi dihapus',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 44,
              color: _accent.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi terbaru akan muncul di sini.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
