import 'package:sqflite/sqflite.dart';
import '../app_db_platform.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

// Model user
class AppUser {
  final int? id;
  final String email;
  final String passwordHash;
  final String salt;
  final String role;
  final String? username;
  String? password; // hanya dipakai waktu register/login

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
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'email': email,
    'password_hash': passwordHash,
    'salt': salt,
    'role': role,
    if (username != null) 'username': username,
  };
}

class UserDao {
  // Generate salt (panjang default: 16 bytes, bisa diubah)
  String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Hash gabungan: SALT + PASSWORD (jangan diubah urutannya)
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AppUser?> findByEmail(String email) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<List<AppUser>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('users');
    return rows.map((row) => AppUser.fromMap(row)).toList();
  }

  Future<int> insert(AppUser user) async {
    final db = await AppDb().database;
    return db.insert(
      'users',
      user.toMap()..remove('id'), // biar id autoincrement
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> update(AppUser user) async {
    final db = await AppDb().database;
    return db.update(
      'users',
      user.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updateRole(int id, String role) async {
    final db = await AppDb().database;
    return db.update('users', {'role': role}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
