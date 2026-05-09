import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleProvider extends ChangeNotifier {
  final _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;

  List<Map<String, dynamic>> get items => _items;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    final snap = await _fs.collection('jadwal').orderBy('hari').get();
    _items = snap.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadByKelasJurusan(String kelas, String jurusan) async {
    _loading = true;
    notifyListeners();
    final snap = await _fs
        .collection('jadwal')
        .where('kelas', isEqualTo: kelas)
        .where('jurusan', isEqualTo: jurusan)
        .get();
    _items = snap.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Map<String, dynamic> s) async {
    await _fs.collection('jadwal').add({
      ...s,
      'created_at': FieldValue.serverTimestamp(),
    });
    await loadAll();
  }

  Future<void> update(String id, Map<String, dynamic> s) async {
    await _fs.collection('jadwal').doc(id).update({
      ...s,
      'updated_at': FieldValue.serverTimestamp(),
    });
    await loadAll();
  }

  Future<void> delete(String id) async {
    await _fs.collection('jadwal').doc(id).delete();
    await loadAll();
  }
}
