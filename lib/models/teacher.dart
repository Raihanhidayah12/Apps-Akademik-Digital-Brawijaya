class Teacher {
  final int? id;
  final int userId;
  final String nip;
  final String name;
  final String subject;
  final String email; // now always required for joined query

  Teacher({
    this.id,
    required this.userId,
    required this.nip,
    required this.name,
    required this.subject,
    required this.email,
  });

  // Untuk hasil JOIN SQL user+teacher (harus ada kolom 'email')
factory Teacher.fromMap(Map<String, dynamic> map) {
  return Teacher(
    id: map['id'],
    userId: map['user_id'],
    nip: (map['nip'] ?? '') as String,
    name: (map['name'] ?? '') as String,
    subject: (map['subject'] ?? '') as String,
    email: (map['email'] ?? '') as String,
  );
}


  // Untuk insert/update ke tabel guru saja (tanpa email, insert langsung teacher)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nip': nip,
      'name': name,
      'subject': subject,
      // email tidak disimpan di tabel teacher
    };
  }
}
