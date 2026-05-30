class ReviewModel {
  final String? id;
  final String? uid;
  final String? namaUser;
  final String? fotoUser;
  final String? komentar;
  final double? rating;
  final DateTime? createdAt;

  ReviewModel({
    this.id,
    this.uid,
    this.namaUser,
    this.fotoUser,
    this.komentar,
    this.rating,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    return ReviewModel(
      id: id,
      uid: json['uid'],
      namaUser: json['nama_user'],
      fotoUser: json['foto_user'],
      komentar: json['komentar'],
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: json['created_at']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama_user': namaUser,
      'foto_user': fotoUser,
      'komentar': komentar,
      'rating': rating,
      'created_at': createdAt,
    };
  }
}
