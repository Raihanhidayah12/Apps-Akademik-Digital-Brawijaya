import 'package:flutter/material.dart';
import '../data/local/dao/teacher_dao.dart';
import '../models/teacher.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherDao _teacherDao = TeacherDao();
  List<Teacher> _teachers = [];
  bool _loading = false;

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _loading;

  Future<void> loadTeachers() async {
    _loading = true;
    notifyListeners();
    try {
      // Main fix: gunakan getAllWithEmail agar field email selalu terisi
      _teachers = await _teacherDao.getAllWithEmail();
    } catch (e) {
      _teachers = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addTeacher(Teacher teacher) async {
    await _teacherDao.insert(teacher);
    await loadTeachers();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _teacherDao.update(teacher);
    await loadTeachers();
  }

  Future<void> deleteTeacher(int id) async {
    await _teacherDao.delete(id);
    await loadTeachers();
  }
}
