class UserModel {
  String? uid;
  String? nama;
  String? email;
  String? fotoProfil;
  String? role;
  String? instagram;
  String? tiktok;
  String? bio;
  String? alamat;
  int? jumlahResep;
  List<String>? pengikut;
  List<String>? mengikuti;
  DateTime? createdAt;
  UserModel({
    this.uid,
    this.nama,
    this.email,
    this.fotoProfil,
    this.role,

    this.bio,
    this.alamat,

    this.instagram,
    this.tiktok,

    this.jumlahResep,
    this.pengikut,
    this.mengikuti,
    this.createdAt,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // jumlah resep kadang disimpan dengan key berbeda.
    final dynamic rawJumlahResep =
        json['jumlah_resep'] ?? json['jumlahResep'] ?? json['recipeCount'];

    int? parsedJumlahResep;
    if (rawJumlahResep is int) {
      parsedJumlahResep = rawJumlahResep;
    } else if (rawJumlahResep is num) {
      parsedJumlahResep = rawJumlahResep.toInt();
    } else if (rawJumlahResep is String) {
      parsedJumlahResep = int.tryParse(rawJumlahResep);
    }

    return UserModel(
      uid: json['uid'],
      nama: json['nama'],
      email: json['email'],
      fotoProfil: json['foto_profil'],
      role: json['role'],
      bio: json['bio'],
      alamat: json['alamat'],
      instagram: json['instagram'],
      tiktok: json['tiktok'],
      jumlahResep: parsedJumlahResep,
      pengikut: List<String>.from(json['pengikut'] ?? []),
      mengikuti: List<String>.from(json['mengikuti'] ?? []),
      createdAt: json['created_at']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'foto_profil': fotoProfil,
      'role': role,
      'bio': bio,
      'alamat': alamat,
      'instagram': instagram,
      'tiktok': tiktok,
      'jumlah_resep': jumlahResep ?? 0,
      'pengikut': pengikut ?? [],
      'mengikuti': mengikuti ?? [],
      'created_at': createdAt,
    };
  }
}
