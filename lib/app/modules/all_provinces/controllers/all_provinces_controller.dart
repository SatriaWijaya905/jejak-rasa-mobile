import 'package:get/get.dart';

class AllProvincesController extends GetxController {
  final isLoading = false.obs; // untuk konsistensi UI

  final provinces = <Map<String, dynamic>>[
    {
      'nama': 'Jawa',
      'gambar': 'https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86',
      'icon': null,
    },
    {
      'nama': 'Sumatera',
      'gambar': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      'icon': null,
    },
    {
      'nama': 'Bali',
      'gambar': 'https://images.unsplash.com/photo-1537953773345-d172ccf13cf1',
      'icon': null,
    },
    {
      'nama': 'Sulawesi',
      'gambar': 'https://images.unsplash.com/photo-1528127269322-539801943592',
      'icon': null,
    },
    {
      'nama': 'Papua',
      'gambar': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
      'icon': null,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    // Simulasi loading singkat (tidak fetch jaringan)
    isLoading.value = false;
  }

  void toKategoriProvinsi(String kategori) {
    Get.toNamed('/kategori-provinsi', arguments: kategori);
  }
}
