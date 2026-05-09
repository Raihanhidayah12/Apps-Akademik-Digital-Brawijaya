import 'package:sqflite/sqflite.dart';
import '../app_db_platform.dart';
import '../../../models/student.dart';

class StudentWithUser {
  final Student student;
  final String email;
  final String role;

  StudentWithUser({
    required this.student,
    required this.email,
    required this.role,
  });
}

class StudentDao {
  Future<String> generateNextNis() async {
    final db = await AppDb().database;
    final rows = await db.rawQuery(
      'SELECT nis FROM students ORDER BY id DESC LIMIT 1'
    );
    if (rows.isEmpty || rows.first['nis'] == null) {
      return "202500000";
    } else {
      final lastNis = int.tryParse(rows.first['nis'] as String) ?? 202500000;
      return (lastNis + 1).toString();
    }
  }

  Future<int> countByClassAndMajor(String kelas, String jurusan) async {
    final db = await AppDb().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM students WHERE kelas = ? AND jurusan = ?',
      [kelas, jurusan],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> insert(Student student) async {
    final db = await AppDb().database;
    final total = await countByClassAndMajor(student.kelas, student.jurusan);
    if (total >= 30) {
      throw Exception(
          "Kelas ${student.kelas} - ${student.jurusan} sudah penuh (maks 30 siswa)");
    }
    final nis = (student.nis?.isEmpty ?? true)
        ? await generateNextNis()
        : student.nis!;
    return await db.insert(
      'students',
      {
        ...student.toMap(),
        'nis': nis,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Student>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      orderBy: 'kelas ASC, name ASC',
    );
    return rows.map((r) => Student.fromMap(r)).toList();
  }

  // 🚩 FULL UPDATE: Query join ambil role user
  Future<List<StudentWithUser>> getAllWithUser() async {
    final db = await AppDb().database;
    final rows = await db.rawQuery('''
      SELECT s.*, u.email, u.role
      FROM students s
      JOIN users u ON u.id = s.user_id
      ORDER BY s.kelas ASC, s.name ASC
    ''');
    return rows.map((r) {
      return StudentWithUser(
        student: Student.fromMap(r),
        email: r['email'] as String,
        role: r['role'] as String,
      );
    }).toList();
  }

  Future<Student?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  Future<Student?> findByUserId(int userId) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  Future<int> update(Student student) async {
    final db = await AppDb().database;
    final total = await countByClassAndMajor(student.kelas, student.jurusan);
    if (total >= 30) {
      throw Exception(
          "Kelas ${student.kelas} - ${student.jurusan} sudah penuh (maks 30 siswa)");
    }
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByUserId(int userId) async {
    final db = await AppDb().database;
    return await db.delete(
      'students',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Student>> getByKelas(String kelas) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      where: 'kelas = ?',
      whereArgs: [kelas],
      orderBy: 'name ASC',
    );
    return rows.map((r) => Student.fromMap(r)).toList();
  }
}
