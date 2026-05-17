import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/buat_resep_controller.dart';

class BuatResepView extends GetView<BuatResepController> {
  const BuatResepView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5A623),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Buat Resep',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Cover
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Tambah Foto Cover',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nama Resep
            Text('Nama Resep',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.namaResepController,
              decoration: InputDecoration(
                hintText: 'Contoh: Gado-gado Spesial',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Provinsi
            Text('Provinsi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedProvinsi.value.isEmpty
                      ? null
                      : controller.selectedProvinsi.value,
                  hint: Text('Pilih Provinsi',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.provinsiList
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p, style: GoogleFonts.poppins()),
                          ))
                      .toList(),
                  onChanged: (val) => controller.selectedProvinsi.value = val!,
                )),
            const SizedBox(height: 16),

            // Waktu Masak
            Text('Waktu Masak',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.waktuMasakController,
              decoration: InputDecoration(
                hintText: 'Contoh: 30 Menit',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tingkat Kesulitan
            Text('Tingkat Kesulitan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedKesulitan.value.isEmpty
                      ? null
                      : controller.selectedKesulitan.value,
                  hint: Text('Pilih Kesulitan',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.kesulitanList
                      .map((k) => DropdownMenuItem(
                            value: k,
                            child: Text(k, style: GoogleFonts.poppins()),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      controller.selectedKesulitan.value = val!,
                )),
            const SizedBox(height: 16),

            // Bahan-bahan
            Text('Bahan-bahan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.bahanController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 200g Tahu',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller
                      .addBahan(controller.bahanController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: controller.bahanList
                      .asMap()
                      .entries
                      .map((e) => ListTile(
                            leading: const Icon(Icons.circle,
                                size: 8, color: Color(0xFFF5A623)),
                            title: Text(e.value,
                                style: GoogleFonts.poppins(fontSize: 14)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => controller.removeBahan(e.key),
                            ),
                          ))
                      .toList(),
                )),
            const SizedBox(height: 16),

            // Langkah Memasak
            Text('Langkah Memasak',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildLangkahInput(),
            const SizedBox(height: 8),
            Obx(() => Column(
                  children: controller.langkahList
                      .asMap()
                      .entries
                      .map((e) => ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5A623),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${e.key + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(e.value,
                                style: GoogleFonts.poppins(fontSize: 14)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => controller.removeLangkah(e.key),
                            ),
                          ))
                      .toList(),
                )),
            const SizedBox(height: 24),

            // Tombol Simpan
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.simpanResep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5A623),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Simpan Resep',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLangkahInput() {
    final langkahController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: langkahController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Contoh: Cuci semua bahan...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            controller.addLangkah(langkahController.text.trim());
            langkahController.clear();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5A623),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}