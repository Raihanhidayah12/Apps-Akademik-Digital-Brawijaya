import 'dart:convert';
import 'dart:html' as html;

class WebUserStore {
  static final WebUserStore instance = WebUserStore._();
  WebUserStore._();

  static const String _key = 'users_store_v1';
  static const String _idKey = 'users_store_v1_last_id';

  List<Map<String, Object?>> _load() {
    final raw = html.window.localStorage[_key];
    if (raw == null || raw.isEmpty) return <Map<String, Object?>>[];
    final List list = jsonDecode(raw) as List;
    return list.cast<Map<String, Object?>>();
  }

  void _save(List<Map<String, Object?>> rows) {
    html.window.localStorage[_key] = jsonEncode(rows);
  }

  int _nextId() {
    final raw = html.window.localStorage[_idKey];
    final current = raw == null ? 0 : int.tryParse(raw) ?? 0;
    final next = current + 1;
    html.window.localStorage[_idKey] = next.toString();
    return next;
  }

  Future<List<Map<String, Object?>>> query({String? where, List<Object?> whereArgs = const []}) async {
    final rows = _load();
    if (where == null) return rows;
    if (where == 'email = ?' && whereArgs.isNotEmpty) {
      final email = whereArgs.first as String;
      return rows.where((r) => r['email'] == email).toList();
    }
    if (where == 'id = ?' && whereArgs.isNotEmpty) {
      final id = whereArgs.first is int ? whereArgs.first as int : int.parse(whereArgs.first.toString());
      return rows.where((r) => r['id'] == id).toList();
    }
    return rows;
  }

  Future<int> insert(Map<String, Object?> values) async {
    final rows = _load();
    final id = _nextId();
    final newRow = {
      'id': id,
      ...values,
    };
    rows.add(newRow);
    _save(rows);
    return id;
  }

  Future<int> update(int id, Map<String, Object?> values) async {
    final rows = _load();
    final idx = rows.indexWhere((r) => r['id'] == id);
    if (idx < 0) return 0;
    rows[idx] = {
      ...rows[idx],
      ...values,
    };
    _save(rows);
    return 1;
  }

  Future<int> delete(int id) async {
    final rows = _load();
    final before = rows.length;
    rows.removeWhere((r) => r['id'] == id);
    _save(rows);
    return before - rows.length;
  }
}