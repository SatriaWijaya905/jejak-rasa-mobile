class UserModel {
  String? uid;
  String? nama;
  String? email;
  String? fotoProfil;
  String? role;
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
    this.jumlahResep,
    this.pengikut,
    this.mengikuti,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      nama: json['nama'],
      email: json['email'],
      fotoProfil: json['foto_profil'],
      role: json['role'],
      jumlahResep: json['jumlah_resep'],
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
      'jumlah_resep': jumlahResep ?? 0,
      'pengikut': pengikut ?? [],
      'mengikuti': mengikuti ?? [],
      'created_at': createdAt,
    };
  }
}