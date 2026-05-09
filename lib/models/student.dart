class Student {
  final int? id;          // auto increment
  final int userId;       // relasi ke tabel users
  final String? nis;      // 🔹 nullable, akan diisi otomatis di DAO
  final String name;
  final String kelas;
  final String jurusan;

  Student({
    this.id,
    required this.userId,
    this.nis,             // 🔹 boleh null saat insert
    required this.name,
    required this.kelas,
    required this.jurusan,
  });

  /// Convert dari Map (row SQLite) ke Student
  factory Student.fromMap(Map<String, dynamic> map) => Student(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        nis: map['nis'] as String?,
        name: map['name'] as String,
        kelas: map['kelas'] as String,
        jurusan: map['jurusan'] as String,
      );

  /// Convert ke Map untuk insert/update
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'kelas': kelas,
      'jurusan': jurusan,
    };

    // 🔹 NIS hanya ditambahin kalau ada (misalnya update)
    if (id != null) data['id'] = id;
    if (nis != null) data['nis'] = nis;

    return data;
  }
}
