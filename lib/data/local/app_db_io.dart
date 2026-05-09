import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uasmobile/core/hashing.dart';

class AppDb {
  static final AppDb _i = AppDb._();
  AppDb._();
  factory AppDb() => _i;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    String path;

    if (kIsWeb) {
      path = 'akademik_web.db';
    } else if (Platform.isAndroid || Platform.isIOS) {
      final docsDir = await getApplicationDocumentsDirectory();
      final dbDir = Directory(p.join(docsDir.path, 'db'));
      if (!await dbDir.exists()) await dbDir.create(recursive: true);
      path = p.join(dbDir.path, 'akademik.db');
    } else {
      final projectDir = Directory.current.path;
      final dbDir = Directory(p.join(projectDir, 'data', 'db'));
      if (!await dbDir.exists()) await dbDir.create(recursive: true);
      path = p.join(dbDir.path, 'akademik.db');
    }

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            nis TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            kelas TEXT NOT NULL,
            jurusan TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS teachers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            nip TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            subject TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS schedules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day TEXT NOT NULL,
            time TEXT NOT NULL,
            subject TEXT NOT NULL,
            teacher_id INTEGER,
            kelas TEXT NOT NULL,
            jurusan TEXT NOT NULL,
            FOREIGN KEY (teacher_id) REFERENCES teachers(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS announcements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        const rawPass = 'admin123';
        const salt = 'default';
        final hash = hashPassword(rawPass, salt);
        await db.insert('users', {
          'email': 'admin@Brawijaya.com',
          'password_hash': hash,
          'salt': salt,
          'role': 'admin',
        });
      },
    );

    return _db!;
  }
}