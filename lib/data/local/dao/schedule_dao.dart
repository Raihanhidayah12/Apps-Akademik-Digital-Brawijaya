import 'package:uasmobile/models/schedule.dart';
import '../app_db_platform.dart';

// Untuk join view di ListView (nama guru, dll)
class ScheduleWithDetails {
  final Schedule schedule;
  final String teacherName;

  ScheduleWithDetails({
    required this.schedule,
    required this.teacherName,
  });
}

class ScheduleDao {
  Future<int> insert(Schedule s) async {
    final db = await AppDb().database;
    return db.insert('schedules', s.toMap());
  }

  Future<int> update(Schedule s) async {
    final db = await AppDb().database;
    return db.update('schedules', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Schedule>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('schedules');
    return rows.map((row) => Schedule.fromMap(row)).toList();
  }

  Future<List<Schedule>> getByKelasJurusan(String kelas, String jurusan) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'schedules',
      where: 'kelas = ? AND jurusan = ?',
      whereArgs: [kelas, jurusan],
    );
    return rows.map((row) => Schedule.fromMap(row)).toList();
  }

  // Join untuk mendapatkan jadwal plus nama guru (detail tampilan)
Future<List<ScheduleWithDetails>> getAllWithDetails() async {
  final db = await AppDb().database;
  final rows = await db.rawQuery('''
    SELECT s.*, t.name AS teacher_name
    FROM schedules s
    LEFT JOIN teachers t ON s.teacher_id = t.id
    ORDER BY s.kelas, s.jurusan, s.day, s.time
  ''');
  return rows.map((row) => ScheduleWithDetails(
    schedule: Schedule.fromMap(row),
    teacherName: row['teacher_name']?.toString() ?? '-',
  )).toList();
}

}
