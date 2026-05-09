import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uasmobile/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  AppUser? _current;
  AppUser? get current => _current;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = _auth.currentUser; // [web:32]
      if (user != null) {
        // start a realtime listener so changes (e.g. admin updating username)
        // are reflected immediately in the app
        _userSub?.cancel();
        _userSub = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen(
              (doc) {
                if (doc.exists && doc.data() != null) {
                  final data = doc.data()!;
                  _current = AppUser(
                    id: null,
                    email: (data['email'] ?? user.email ?? '') as String,
                    passwordHash: '',
                    salt: '',
                    role: (data['role'] ?? 'siswa') as String,
                    username: (data['username'] ?? data['name']) as String?,
                  );
                } else {
                  _current = null;
                }
                _loading = false;
                notifyListeners();
              },
              onError: (err) {
                _error = 'Gagal memuat profil: $err';
                _loading = false;
                notifyListeners();
              },
            );
      } else {
        _current = null;
        _loading = false;
        notifyListeners();
      }
    } catch (e) {
      _loading = false;
      _error = 'Gagal memuat sesi: $e';
      notifyListeners();
    }
  }

  // ================== REGISTER ==================
  Future<bool> register(
    String email,
    String password, {
    String role = "siswa_pending",
  }) async {
    _error = null;
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ); // [web:32]

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _error = 'Gagal membuat akun Firebase Auth';
        notifyListeners();
        return false;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
            'email': email.trim(),
            'role': role,
            'username': email.split('@')[0],
            'created_at': FieldValue.serverTimestamp(),
          });

      _current = AppUser(
        id: null,
        email: email.trim(),
        passwordHash: '',
        salt: '',
        role: role,
        username: email.split('@')[0],
      );
      // start realtime listener for this new user
      try {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          _userSub?.cancel();
          _userSub = FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots()
              .listen((doc) {
                if (doc.exists && doc.data() != null) {
                  final data = doc.data()!;
                  _current = AppUser(
                    id: null,
                    email:
                        (data['email'] ?? firebaseUser.email ?? '') as String,
                    passwordHash: '',
                    salt: '',
                    role: (data['role'] ?? role) as String,
                    username: (data['username'] ?? data['name']) as String?,
                  );
                }
                notifyListeners();
              });
        }
      } catch (_) {}
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapRegisterError(e);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      notifyListeners();
      return false;
    }
  }

  String _mapRegisterError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      default:
        return 'Gagal register. Coba lagi.';
    }
  }

  // ================== LOGIN ==================
  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ); // [web:32]
      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        _error = 'Gagal login: user tidak ditemukan';
        notifyListeners();
        return false;
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
      final doc = await docRef.get();

      String role;
      String emailStored;

      if (doc.exists) {
        final data = doc.data()!;
        role = (data['role'] ?? 'siswa') as String;
        emailStored = data['email'] ?? firebaseUser.email ?? '';
        if (role == 'siswa_pending') {
          _error = 'Akun Anda menunggu verifikasi admin';
          notifyListeners();
          return false;
        }
        // if doc exists try to get username too
        final username = (data['username'] ?? data['name']) as String?;
        _current = AppUser(
          id: null,
          email: emailStored,
          passwordHash: '',
          salt: '',
          role: role,
          username: username,
        );
      } else {
        final local = (firebaseUser.email ?? '').split('@').first.toLowerCase();
        if (local.contains('admin')) {
          role = 'admin';
        } else {
          role = 'siswa';
        }
        emailStored = firebaseUser.email ?? '';
      }
      // if _current wasn't set from doc above, set it now
      _current ??= AppUser(
        id: null,
        email: emailStored,
        passwordHash: '',
        salt: '',
        role: role,
        username: (emailStored.split('@').first),
      );
      // start realtime listener for logged-in user
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          _userSub?.cancel();
          _userSub = FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots()
              .listen((doc) {
                if (doc.exists && doc.data() != null) {
                  final data = doc.data()!;
                  _current = AppUser(
                    id: null,
                    email:
                        (data['email'] ?? firebaseUser.email ?? '') as String,
                    passwordHash: '',
                    salt: '',
                    role: (data['role'] ?? role) as String,
                    username: (data['username'] ?? data['name']) as String?,
                  );
                }
                notifyListeners();
              });
        }
      } catch (_) {}
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // mapping error login di sini
      _error = _mapLoginError(e);
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Coba lagi.';
      notifyListeners();
      return false;
    }
  }

  String _mapLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Email belum terdaftar.';
      case 'wrong-password':
        return 'Password salah. Coba lagi.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'invalid-credential':
        // sering muncul ketika email/password salah pada beberapa project. [web:44][web:47]
        return 'Email atau password tidak cocok.';
      default:
        return 'Gagal login. Periksa data lalu coba lagi.';
    }
  }

  // ================== LOGOUT ==================
  Future<void> logout() async {
    _current = null;
    // cancel realtime listener
    try {
      await _userSub?.cancel();
    } catch (_) {}
    _userSub = null;
    await _auth.signOut(); // [web:32]
    notifyListeners();
  }
}
