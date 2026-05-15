class ResepModel {
  String? id;
  String? namaResep;
  String? fotoCover;
  String? provinsi;
  String? waktuMasak;
  String? tingkatKesulitan;
  double? rating;
  int? jumlahReview;
  bool? isPopular;
  bool? isFeatured;
  List<String>? bahan;
  List<LangkahModel>? langkah;
  String? authorUid;
  DateTime? createdAt;

  ResepModel({
    this.id,
    this.namaResep,
    this.fotoCover,
    this.provinsi,
    this.waktuMasak,
    this.tingkatKesulitan,
    this.rating,
    this.jumlahReview,
    this.isPopular,
    this.isFeatured,
    this.bahan,
    this.langkah,
    this.authorUid,
    this.createdAt,
  });

  factory ResepModel.fromJson(Map<String, dynamic> json, String id) {
    return ResepModel(
      id: id,
      namaResep: json['nama_resep'],
      fotoCover: json['foto_cover'],
      provinsi: json['provinsi'],
      waktuMasak: json['waktu_masak'],
      tingkatKesulitan: json['tingkat_kesulitan'],
      rating: json['rating']?.toDouble(),
      jumlahReview: json['jumlah_review'],
      isPopular: json['is_popular'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      bahan: List<String>.from(json['bahan'] ?? []),
      langkah: (json['langkah'] as List?)
          ?.map((e) => LangkahModel.fromJson(e))
          .toList(),
      authorUid: json['author_uid'],
      createdAt: json['created_at']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_resep': namaResep,
      'foto_cover': fotoCover,
      'provinsi': provinsi,
      'waktu_masak': waktuMasak,
      'tingkat_kesulitan': tingkatKesulitan,
      'rating': rating ?? 0.0,
      'jumlah_review': jumlahReview ?? 0,
      'is_popular': isPopular ?? false,
      'is_featured': isFeatured ?? false,
      'bahan': bahan ?? [],
      'langkah': langkah?.map((e) => e.toJson()).toList() ?? [],
      'author_uid': authorUid,
      'created_at': createdAt,
    };
  }
}

class LangkahModel {
  int? urutan;
  String? deskripsi;
  String? foto;

  LangkahModel({
    this.urutan,
    this.deskripsi,
    this.foto,
  });

  factory LangkahModel.fromJson(Map<String, dynamic> json) {
    return LangkahModel(
      urutan: json['urutan'],
      deskripsi: json['deskripsi'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urutan': urutan,
      'deskripsi': deskripsi,
      'foto': foto,
    };
  }
}