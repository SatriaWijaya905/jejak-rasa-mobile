import 'package:cloud_firestore/cloud_firestore.dart';

class DummySeeder {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> seedAll() async {
    // =====================================================
    // USERS
    // =====================================================

    final users = [
      {
  'uid': 'creator_kalimantan',
  'nama': 'Chef Kalimantan',
  'email': 'kalimantan@test.com',
  'foto_profil':
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
  'bio': 'Kuliner khas Kalimantan autentik',
  'lokasi': 'Samarinda',
  'instagram': '@chefkalimantan',
  'youtube': '',
  'website': '',
  'created_at': Timestamp.now(),
},
    ];

    // SAVE USERS

    for (var user in users) {
      await firestore.collection('users').doc(user['uid'] as String).set(user);
    }

    // =====================================================
    // RECIPES
    // =====================================================

final dummyRecipes = [

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Ayam',
      'Soun',
      'Kayu manis',
      'Cengkeh',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=1200&auto=format&fit=crop',

    'is_featured': true,
    'is_popular': true,
    'jumlah_review': 18,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Rebus ayam hingga matang',
      'Haluskan bumbu',
      'Masukkan ke kuah',
      'Sajikan hangat',
    ],

    'nama_resep': 'Soto Banjar',

    'provinsi': 'Kalimantan Selatan',

    'rating': 4.8,

    'status': 'approved',

    'tingkat_kesulitan': 'Menengah',

    'waktu_masak': '45 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Ayam',
      'Cabai merah',
      'Kecap manis',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?q=80&w=1200&auto=format&fit=crop',

    'is_featured': false,
    'is_popular': true,
    'jumlah_review': 15,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Haluskan bumbu',
      'Lumuri ayam',
      'Bakar hingga matang',
      'Sajikan hangat',
    ],

    'nama_resep': 'Ayam Cincane',

    'provinsi': 'Kalimantan Timur',

    'rating': 4.7,

    'status': 'approved',

    'tingkat_kesulitan': 'Mudah',

    'waktu_masak': '40 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Beras',
      'Ikan asin',
      'Kemangi',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=1200&auto=format&fit=crop',

    'is_featured': false,
    'is_popular': false,
    'jumlah_review': 12,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Masak nasi berbumbu',
      'Goreng ikan asin',
      'Sajikan bersama pelengkap',
    ],

    'nama_resep': 'Nasi Bekepor',

    'provinsi': 'Kalimantan Timur',

    'rating': 4.6,

    'status': 'approved',

    'tingkat_kesulitan': 'Menengah',

    'waktu_masak': '50 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Ketupat',
      'Ikan haruan',
      'Santan',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1529042410759-befb1204b468?q=80&w=1200&auto=format&fit=crop',

    'is_featured': true,
    'is_popular': true,
    'jumlah_review': 21,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Bakar ikan haruan',
      'Masak kuah santan',
      'Siram ke ketupat',
    ],

    'nama_resep': 'Ketupat Kandangan',

    'provinsi': 'Kalimantan Selatan',

    'rating': 4.9,

    'status': 'approved',

    'tingkat_kesulitan': 'Sulit',

    'waktu_masak': '60 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Rotan muda',
      'Ikan patin',
      'Cabai',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1200&auto=format&fit=crop',

    'is_featured': false,
    'is_popular': false,
    'jumlah_review': 10,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Rebus rotan muda',
      'Masak ikan dengan bumbu',
      'Campurkan semua bahan',
    ],

    'nama_resep': 'Juhu Singkah',

    'provinsi': 'Kalimantan Tengah',

    'rating': 4.5,

    'status': 'approved',

    'tingkat_kesulitan': 'Sulit',

    'waktu_masak': '35 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Umbut kelapa',
      'Ikan gabus',
      'Santan',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?q=80&w=1200&auto=format&fit=crop',

    'is_featured': false,
    'is_popular': false,
    'jumlah_review': 12,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Iris umbut kelapa',
      'Masak santan dan bumbu',
      'Masukkan ikan dan umbut',
    ],

    'nama_resep': 'Gangan Humbut',

    'provinsi': 'Kalimantan Selatan',

    'rating': 4.5,

    'status': 'approved',

    'tingkat_kesulitan': 'Menengah',

    'waktu_masak': '45 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Durian',
      'Gula',
      'Garam',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=1200&auto=format&fit=crop',

    'is_featured': false,
    'is_popular': true,
    'jumlah_review': 14,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Masak daging durian',
      'Tambahkan gula',
      'Aduk hingga mengental',
    ],

    'nama_resep': 'Lempok Durian',

    'provinsi': 'Kalimantan Barat',

    'rating': 4.6,

    'status': 'approved',

    'tingkat_kesulitan': 'Sulit',

    'waktu_masak': '90 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Beras',
      'Sayuran',
      'Kelapa sangrai',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?q=80&w=1200&auto=format&fit=crop',

    'is_featured': false,
    'is_popular': false,
    'jumlah_review': 10,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Masak bubur',
      'Tambahkan sayuran',
      'Masukkan kelapa sangrai',
    ],

    'nama_resep': 'Bubur Pedas',

    'provinsi': 'Kalimantan Barat',

    'rating': 4.4,

    'status': 'approved',

    'tingkat_kesulitan': 'Menengah',

    'waktu_masak': '50 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Kepiting soka',
      'Bawang putih',
      'Saus tiram',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?q=80&w=1200&auto=format&fit=crop',

    'is_featured': true,
    'is_popular': true,
    'jumlah_review': 18,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Bersihkan kepiting',
      'Tumis bumbu',
      'Masak hingga matang',
    ],

    'nama_resep': 'Kepiting Soka',

    'provinsi': 'Kalimantan Utara',

    'rating': 4.8,

    'status': 'approved',

    'tingkat_kesulitan': 'Menengah',

    'waktu_masak': '40 Menit',
  },

  {
    'author_uid': 'creator_kalimantan',

    'bahan': [
      'Ikan patin',
      'Cabai',
      'Asam jawa',
    ],

    'created_at': Timestamp.now(),

    'foto_cover':
        'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?q=80&w=1200&auto=format&fit=crop',

    'is_featured': false,
    'is_popular': false,
    'jumlah_review': 11,

    'kategori_provinsi': 'Kalimantan',

    'langkah': [
      'Rebus ikan',
      'Masukkan bumbu',
      'Masak hingga matang',
    ],

    'nama_resep': 'Ikan Asam Pedas Banjar',

    'provinsi': 'Kalimantan Selatan',

    'rating': 4.5,

    'status': 'approved',

    'tingkat_kesulitan': 'Mudah',

    'waktu_masak': '35 Menit',
  },

];


    // SAVE RECIPES

    for (var recipe in dummyRecipes) {
      await firestore.collection('resep').add(recipe);
    }

    print('DUMMY DATA BERHASIL DIBUAT');
  }
}
