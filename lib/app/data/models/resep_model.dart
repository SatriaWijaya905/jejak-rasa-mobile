import 'package:cloud_firestore/cloud_firestore.dart';

class ResepModel {
  final String? id;
  final String? namaResep;
  final String? fotoCover;
  final String? provinsi;
  final String? waktuMasak;
  final String? tingkatKesulitan;
  final double? rating;
  final int? jumlahReview;
  final int? jumlahFavorit;
  final bool? isPopular;
  final bool? isFeatured;
  final String? kategoriProvinsi;
  final List<String>? bahan;
  final List<ResepStep>? langkah;
  final String? authorUid;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? status;
  final String? youtubeVideoUrl;
  final String? rejectReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final int? revisionCount;

  ResepModel({
    this.id,
    this.namaResep,
    this.fotoCover,
    this.provinsi,
    this.waktuMasak,
    this.tingkatKesulitan,
    this.rating,
    this.jumlahReview,
    this.jumlahFavorit,
    this.isPopular,
    this.isFeatured,
    this.kategoriProvinsi,
    this.bahan,
    this.langkah,
    this.authorUid,
    this.createdAt,
    this.approvedAt,
    this.status,
    this.youtubeVideoUrl,
    this.rejectReason,
    this.reviewedBy,
    this.reviewedAt,
    this.revisionCount,
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
      jumlahFavorit: json['jumlah_favorit'],
      isPopular: json['is_popular'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      kategoriProvinsi: json['kategori_provinsi'],
      bahan: List<String>.from(json['bahan'] ?? []),
      langkah: _parseLangkah(json['langkah']),
      authorUid: json['author_uid'],
      createdAt: json['created_at']?.toDate(),
      approvedAt: json['approved_at'] != null
          ? (json['approved_at'] as Timestamp).toDate()
          : null,
      status: json['status'],
      youtubeVideoUrl: json['youtube_video_url'],
      rejectReason: json['reject_reason'],
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'] != null
          ? (json['reviewed_at'] as Timestamp).toDate()
          : null,
      revisionCount: json['revision_count'],
    );
  }

  static List<ResepStep> _parseLangkah(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => ResepStep.fromJson(e)).toList();
    }
    return [];
  }

  factory ResepModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ResepModel(
      id: doc.id,
      namaResep: data['nama_resep'],
      fotoCover: data['foto_cover'],
      provinsi: data['provinsi'],
      waktuMasak: data['waktu_masak'],
      tingkatKesulitan: data['tingkat_kesulitan'],
      rating: (data['rating'] as num?)?.toDouble(),
      jumlahReview: data['jumlah_review'] as int?,
      jumlahFavorit: data['jumlah_favorit'] as int?,
      isPopular: data['is_popular'] ?? false,
      isFeatured: data['is_featured'] ?? false,
      kategoriProvinsi: data['kategori_provinsi'],
      bahan: (data['bahan'] as List?)?.map((e) => e.toString()).toList(),
      langkah: _parseLangkah(data['langkah']),

      authorUid: data['author_uid'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      approvedAt: data['approved_at'] != null
          ? (data['approved_at'] as Timestamp).toDate()
          : null,
      status: data['status'],
      youtubeVideoUrl: data['youtube_video_url'],
      rejectReason: data['reject_reason'],
      reviewedBy: data['reviewed_by'],
      reviewedAt: data['reviewed_at'] != null
          ? (data['reviewed_at'] as Timestamp).toDate()
          : null,
      revisionCount: data['revision_count'],
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
      'jumlah_favorit': jumlahFavorit ?? 0,
      'is_popular': isPopular ?? false,
      'is_featured': isFeatured ?? false,
      'kategori_provinsi': kategoriProvinsi,
      'bahan': bahan ?? [],
      'langkah': langkah?.map((e) => e.toJson()).toList() ?? [],

      'author_uid': authorUid,
      'created_at': createdAt,
      'status': status ?? 'pending',
      'youtube_video_url': youtubeVideoUrl,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (revisionCount != null) 'revision_count': revisionCount,
    };
  }
}

class ResepStep {
  final String text;
  final String? imageUrl;

  ResepStep({required this.text, this.imageUrl});

  factory ResepStep.fromJson(dynamic json) {
    if (json is String) {
      return ResepStep(text: json);
    } else if (json is Map) {
      return ResepStep(
        text: (json['text'] ?? json['deskripsi'] ?? '').toString(),
        imageUrl: json['imageUrl'] as String?,
      );
    }
    return ResepStep(text: '');
  }

  Map<String, dynamic> toJson() {
    return {'text': text, if (imageUrl != null) 'imageUrl': imageUrl};
  }
}
