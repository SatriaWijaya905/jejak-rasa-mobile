class WilayahConstants {
  static const Map<String, List<String>> wilayahProvinsi = {
    'Jawa': [
      'DKI Jakarta',
      'Jawa Barat',
      'Jawa Tengah',
      'Yogyakarta',
      'Jawa Timur',
      'Banten',
    ],
    'Sumatera': [
      'Aceh',
      'Sumatera Utara',
      'Sumatera Barat',
      'Riau',
      'Kepulauan Riau',
      'Jambi',
      'Bengkulu',
      'Sumatera Selatan',
      'Kepulauan Bangka Belitung',
      'Lampung',
    ],
    'Bali': [
      'Bali',
    ],
    'Kalimantan': [
      'Kalimantan Barat',
      'Kalimantan Tengah',
      'Kalimantan Selatan',
      'Kalimantan Timur',
      'Kalimantan Utara',
    ],
    'Sulawesi': [
      'Sulawesi Utara',
      'Gorontalo',
      'Sulawesi Tengah',
      'Sulawesi Barat',
      'Sulawesi Selatan',
      'Sulawesi Tenggara',
    ],
    'Papua': [
      'Papua',
      'Papua Barat',
      'Papua Selatan',
      'Papua Tengah',
      'Papua Pegunungan',
      'Papua Barat Daya',
    ],
  };

  static List<String> get wilayahList => wilayahProvinsi.keys.toList();
}
