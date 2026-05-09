import 'package:sqflite/sqflite.dart';
import '../../../models/grade.dart';
import '../app_db.dart';

class GradeDao {
  Future<int> insert(Grade grade) async {
    final db = await AppDb().database;
    return db.insert('grades', grade.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> update(Grade grade) async {
    final db = await AppDb().database;
    return db.update('grades', grade.toMap(), where: 'id = ?', whereArgs: [grade.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }

  Future<Grade?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query('grades', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Grade.fromMap(rows.first);
  }

  Future<List<Grade>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('grades');
    return rows.map((row) => Grade.fromMap(row)).toList();
  }
}
