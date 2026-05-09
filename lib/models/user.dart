class AppUser {
  final int? id; // nullable, auto increment di SQLite
  final String email;
  final String passwordHash; // hasil hash password+salt
  final String salt; // salt untuk hashing
  final String role;
  final String? username;

  String? password; // nullable: hanya untuk input, tidak disimpan di DB

  AppUser({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.role,
    this.username,
    this.password,
  });

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
    id: map['id'] as int?,
    email: map['email'] as String,
    passwordHash: map['password_hash'] as String,
    salt: map['salt'] as String,
    role: map['role'] as String,
    username: map['username'] as String?,
    // Tidak perlu load password, cuma untuk field opsional ketika input saja
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'email': email,
    'password_hash': passwordHash,
    'salt': salt,
    'role': role,
    if (username != null) 'username': username,
    // Tidak perlu simpan password plain di DB
  };

  // Optional: Custom copyWith biar bisa update properti dengan mudah
  AppUser copyWith({
    int? id,
    String? email,
    String? passwordHash,
    String? salt,
    String? role,
    String? username,
    String? password,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      role: role ?? this.role,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
