import 'package:get/get.dart';

class HelpController extends GetxController {
  final RxInt selectedTab = 0.obs;

  final faqItems = const [
    {
      'q': 'Cara membuat resep?',
      'a':
          'Buka halaman "Buat Resep" lalu isi detail resep sampai dipublikasikan.',
    },
    {
      'q': 'Cara edit profil?',
      'a': 'Masuk ke Profil > Pengaturan > Edit Profil.',
    },
    {
      'q': 'Cara follow creator?',
      'a': 'Buka profil creator lalu tekan tombol Follow.',
    },
    {
      'q': 'Cara simpan favorit?',
      'a':
          'Saat melihat resep, tekan ikon favorit untuk menyimpannya ke koleksi kamu.',
    },
    {
      'q': 'Cara hapus resep?',
      'a':
          'Buka resep kamu, lalu gunakan opsi hapus (jika tersedia) di halaman detail resep.',
    },
    {
      'q': 'Apakah aplikasi gratis?',
      'a': 'Ya, JejakRasa bisa digunakan secara gratis.',
    },
    {
      'q': 'Apakah data aman?',
      'a':
          'Kami berusaha menjaga keamanan data. Kamu juga bisa mengatur privasi akun di menu Privacy.',
    },
  ];
}
