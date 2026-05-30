import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/edit_resep_controller.dart';
import 'package:jejakrasa_mobile_database/app/utils/wilayah_constants.dart';

class EditResepView extends GetView<EditResepController> {
  const EditResepView({super.key});

  // ─── Palet Warna (konsisten dengan BuatResepView) ────────────────────────
  static const _orange1 = Color(0xFFF5A623);
  static const _orange2 = Color(0xFFFF7E00);
  static const _bg = Color(0xFFF9FAFB);
  static const _dark = Color(0xFF2D3142);
  static const _cream1 = Color(0xFFFFF3D9);
  static const _cream2 = Color(0xFFFFE0B2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverSection(),
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildBahanSection(),
            const SizedBox(height: 24),
            _buildLangkahSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_orange1, _orange2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Resep',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            'Perbarui resep nusantaramu',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION CARD WRAPPER (sama persis dengan BuatResepView)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _dark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COVER PHOTO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCoverSection() {
    return _buildSectionCard(
      title: 'Foto Utama',
      subtitle: 'Ganti atau pertahankan foto masakanmu',
      child: Obx(() {
        final url = controller.imageUrl.value;
        final hasImage = url.isNotEmpty;

        return Column(
          children: [
            GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [_cream1, _cream2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Coba load sebagai network image dulu
                            _buildCoverImageWidget(url),
                            // Overlay edit button
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: _orange1,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 40,
                              color: _orange1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pilih Foto Masakan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD35400),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // Tombol hapus cover — hanya muncul jika ada gambar
            if (hasImage) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: controller.removeCoverImage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hapus Foto',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  /// Pilih antara Image.network (URL lama) atau Image.file/network (file baru)
  Widget _buildCoverImageWidget(String path) {
    // Jika path adalah URL http → network image
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _coverPlaceholder(),
      );
    }
    // File lokal
    if (kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _coverPlaceholder(),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _coverPlaceholder(),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: _cream1,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, size: 48, color: _orange1),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INFORMASI RESEP
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInfoSection() {


    final List<String> kesulitanList = ['Mudah', 'Menengah', 'Sulit'];

    return _buildSectionCard(
      title: 'Informasi Resep',
      child: Column(
        children: [
          _modernTextField(
            ctrl: controller.namaController,
            label: 'Nama Resep',
            hint: 'Contoh: Rendang Daging',
            icon: Icons.restaurant_menu_rounded,
          ),

          const SizedBox(height: 16),

          _modernTextField(
            ctrl: controller.youtubeVideoController,
            label: '🎥 Link Video YouTube (Opsional)',
            hint: 'https://youtube.com/watch?v=...',
            icon: Icons.play_circle_fill_rounded,
          ),

          const SizedBox(height: 16),

          _buildModernDropdown(
            value: controller.selectedWilayah,
            items: WilayahConstants.wilayahList,
            label: 'Wilayah Besar',
            hint: 'Pilih Wilayah',
            icon: Icons.map_rounded,
            onChanged: (val) {
              if (val != null) controller.onWilayahChanged(val);
            },
          ),

          const SizedBox(height: 16),

          Obx(() {
            final wilayah = controller.selectedWilayah.value;
            final provList = wilayah.isEmpty
                ? <String>[]
                : WilayahConstants.wilayahProvinsi[wilayah] ?? [];
            return _buildModernDropdown(
              value: controller.selectedProvinsi,
              items: provList,
              label: 'Provinsi',
              hint: 'Pilih Provinsi',
              icon: Icons.location_on_rounded,
            );
          }),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _modernTextField(
                  ctrl: controller.waktuController,
                  label: 'Waktu Masak',
                  hint: 'Contoh: 45 Menit',
                  icon: Icons.timer_rounded,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedKesulitan.value.isEmpty
                        ? null
                        : controller.selectedKesulitan.value,
                    decoration: InputDecoration(
                      labelText: 'Kesulitan',
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.map_rounded,
                        color: _orange1,
                      ),
                      filled: true,
                      fillColor: _bg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: _orange1,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: kesulitanList.map((level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedKesulitan.value = val;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BAHAN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBahanSection() {
    return _buildSectionCard(
      title: 'Bahan-bahan',
      subtitle: 'Masukkan bahan satu per satu',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _modernTextField(
                  ctrl: controller.bahanController,
                  hint: 'Contoh: 500gr Daging Sapi',
                  icon: Icons.kitchen_rounded,
                ),
              ),
              const SizedBox(width: 12),
              _addButton(onTap: controller.addBahan),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: controller.bahanList.asMap().entries.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: _orange1,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.removeBahan(e.key),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LANGKAH MEMASAK
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLangkahSection() {
    return _buildSectionCard(
      title: 'Langkah Memasak',
      subtitle: 'Edit langkah & foto tiap step',
      child: Column(
        children: [
          // Input tambah langkah baru
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.langkahController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Tumis bumbu hingga harum...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: _bg,
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _orange1, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _addButton(onTap: controller.addLangkah),
            ],
          ),
          const SizedBox(height: 20),

          // Daftar langkah (reorderable)
          Obx(
            () => ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              proxyDecorator: (child, index, animation) => Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: child,
              ),
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = controller.langkahList.removeAt(oldIndex);
                controller.langkahList.insert(newIndex, item);
              },
              children: controller.langkahList.asMap().entries.map((e) {
                final index = e.key;
                final step = e.value;
                return _buildStepCard(index: index, step: step);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({required int index, required EditableStep step}) {
    final bool hasNewFile = step.imageFile != null;
    final bool hasOldUrl = step.imageUrl != null && step.imageUrl!.isNotEmpty;
    final bool hasAnyImage = hasNewFile || hasOldUrl;

    return Container(
      key: ValueKey('step_$index'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nomor step ──────────────────────────────────────────────────
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_orange1, _orange2]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Teks + gambar step ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.text,
                  style: GoogleFonts.poppins(
                    height: 1.5,
                    fontSize: 14,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 12),

                // Preview gambar (file baru atau URL lama)
                if (hasAnyImage)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasNewFile
                            ? _buildStepImageFromFile(step.imageFile!)
                            : Image.network(
                                step.imageUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120,
                                  color: _cream1,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: _orange1,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      // Tombol ganti / hapus gambar step
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            _stepImageAction(
                              icon: Icons.edit_rounded,
                              onTap: () => controller.pickStepImage(index),
                            ),
                            const SizedBox(width: 6),
                            _stepImageAction(
                              icon: Icons.close_rounded,
                              onTap: () => controller.removeStepImage(index),
                              isDelete: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  // Tombol tambah foto step
                  GestureDetector(
                    onTap: () => controller.pickStepImage(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_a_photo_rounded,
                            color: _orange1,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tambah Foto',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFD35400),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Action: hapus + drag handle ─────────────────────────────────
          Column(
            children: [
              GestureDetector(
                onTap: () => controller.removeLangkah(index),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(height: 16),
              const Icon(
                Icons.drag_indicator_rounded,
                color: Colors.grey,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepImageFromFile(XFile file) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 120,
          color: _cream1,
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: _orange1),
          ),
        ),
      );
    }
    return Image.file(
      File(file.path),
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 120,
        color: _cream1,
        child: const Center(
          child: Icon(Icons.broken_image_rounded, color: _orange1),
        ),
      ),
    );
  }

  Widget _stepImageAction({
    required IconData icon,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDelete ? Colors.red.shade600 : Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE BUTTON
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSaveButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: controller.isLoading.value
              ? const LinearGradient(colors: [Colors.grey, Colors.grey])
              : const LinearGradient(colors: [_orange1, _orange2]),
          boxShadow: controller.isLoading.value
              ? []
              : [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.isLoading.value ? null : controller.updateResep,
            borderRadius: BorderRadius.circular(100),
            child: Center(
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      'Simpan Perubahan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════
  
  Widget _buildModernDropdown({
    required RxString value,
    required List<String> items,
    String? label,
    required String hint,
    required IconData icon,
    Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Obx(
          () => DropdownButtonFormField<String>(
            value: value.value.isEmpty ? null : value.value,
            hint: Text(
              hint,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _bg,
              prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: _orange1,
                  width: 1.5,
                ),
              ),
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: onChanged ?? (val) {
              if (val != null) value.value = val;
            },
          ),
        ),
      ],
    );
  }

  Widget _modernTextField({
    required TextEditingController ctrl,
    String? label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: ctrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            filled: true,
            fillColor: _bg,
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _orange1, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_orange1, _orange2]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
