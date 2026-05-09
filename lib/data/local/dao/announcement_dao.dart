import '../../../models/announcement.dart';
import '../app_db_platform.dart';

class AnnouncementDao {
  Future<int> insert(Announcement a) async {
    final db = await AppDb().database;
    return db.insert('announcements', a.toMap());
  }

  Future<int> update(Announcement a) async {
    final db = await AppDb().database;
    return db.update('announcements', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('announcements', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Announcement>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('announcements', orderBy: 'created_at DESC');
    return rows.map((r) => Announcement.fromMap(r)).toList();
  }
}
