import 'package:sqflite/sqflite.dart';
import '../../../models/teacher.dart';
import '../app_db_platform.dart';

class TeacherDao {
  Future<int> insert(Teacher teacher) async {
    final db = await AppDb().database;
    return db.insert(
      'teachers',
      teacher.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> update(Teacher teacher) async {
    final db = await AppDb().database;
    return db.update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  /// Main fix: SELALU return List<Teacher> (tidak pernah null)
  Future<List<Teacher>> getAllWithEmail() async {
    final db = await AppDb().database;
    final rows = await db.rawQuery('''
      SELECT teachers.*, users.email
      FROM teachers
      JOIN users ON users.id = teachers.user_id
    ''');
    return rows.isNotEmpty
        ? rows.map((row) => Teacher.fromMap(row)).toList()
        : <Teacher>[];
  }

  // Untuk dropdown guru (tanpa join email)
  Future<List<Teacher>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('teachers');
    return rows.isNotEmpty
        ? rows.map((row) => Teacher.fromMap(row)).toList()
        : <Teacher>[];
  }

  Future<Teacher?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.rawQuery('''
      SELECT teachers.*, users.email
      FROM teachers
      JOIN users ON users.id = teachers.user_id
      WHERE teachers.id = ?
    ''', [id]);
    return rows.isEmpty ? null : Teacher.fromMap(rows.first);
  }

  Future<Teacher?> findByUserId(int userId) async {
    final db = await AppDb().database;
    final rows = await db.rawQuery('''
      SELECT teachers.*, users.email
      FROM teachers
      JOIN users ON users.id = teachers.user_id
      WHERE teachers.user_id = ?
    ''', [userId]);
    return rows.isEmpty ? null : Teacher.fromMap(rows.first);
  }

  Future<void> deleteByUserId(int userId) async {
    final db = await AppDb().database;
    await db.delete('teachers', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<String> generateNextNip() async {
    final db = await AppDb().database;
    final rows = await db.rawQuery(
      'SELECT nip FROM teachers ORDER BY id DESC LIMIT 1',
    );
    if (rows.isEmpty || rows.first['nip'] == null) {
      return "198500000";
    } else {
      final lastNip = int.tryParse(rows.first['nip'] as String) ?? 198500000;
      return (lastNip + 1).toString();
    }
  }
}
