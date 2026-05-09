import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/notification_service.dart';
import '../utils/app_navigator.dart';
import '../utils/in_app_banner.dart';
import '../ui/pengumuman_detail_page.dart';

class AnnouncementProvider extends ChangeNotifier {
  final _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;
  StreamSubscription<QuerySnapshot>? _sub;
  String _role = 'siswa';
  bool _initialized = false;

  List<Map<String, dynamic>> get items => _items;
  bool get loading => _loading;

  AnnouncementProvider() {
    _startRealtime();
  }

  Future<void> _startRealtime() async {
    _loading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _fs.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _role = (doc.data()?['role'] ?? 'siswa') as String;
      }
    }

    _sub = _fs
        .collection('pengumuman')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            // First snapshot: just populate items without firing notifications
            if (!_initialized) {
              _items = snapshot.docs.map((d) {
                final data = d.data();
                if (data == null) return <String, dynamic>{};
                final m = Map<String, dynamic>.from(data);
                m['id'] = d.id;
                return m;
              }).toList();
              _initialized = true;
              _loading = false;
              notifyListeners();
              return;
            }

            // For subsequent snapshots, process document changes
            for (final change in snapshot.docChanges) {
              final data = change.doc.data();
              if (data == null) continue;
              final m = Map<String, dynamic>.from(data);
              m['id'] = change.doc.id;

              if (change.type == DocumentChangeType.added) {
                // Add new item at the beginning (since ordered by created_at descending)
                _items.insert(0, m);

                // Show notification only when audience matches user's role or 'all'
                final audience = (m['audience'] ?? 'all') as String;
                if (audience == 'all' || audience == _role) {
                  try {
                    NotificationService.show(
                      title: m['title'] ?? 'Pengumuman baru',
                      body: m['content'] ?? '',
                    );
                    // Also show an in-app popup dialog when app is in foreground
                    try {
                      // show a modern in-app banner using Overlay
                      // avoid calling UI APIs synchronously inside the listener
                      final payload = Map<String, dynamic>.from(m);
                      Future.microtask(() {
                        showInAppAnnouncement(
                          title: payload['title'] ?? 'Pengumuman baru',
                          body: payload['content'] ?? '',
                          onTap: () {
                            try {
                              appNavigatorKey.currentState?.push(
                                MaterialPageRoute(
                                  builder: (_) => PengumumanDetailPage(
                                    announcement: payload,
                                  ),
                                ),
                              );
                            } catch (_) {}
                          },
                        );
                      });
                    } catch (_) {
                      // ignore UI errors
                    }
                  } catch (_) {
                    // ignore notification errors silently
                  }
                }
              } else if (change.type == DocumentChangeType.modified) {
                // Update existing item
                final index = _items.indexWhere(
                  (item) => item['id'] == change.doc.id,
                );
                if (index != -1) {
                  _items[index] = m;
                }
              } else if (change.type == DocumentChangeType.removed) {
                // Remove item
                _items.removeWhere((item) => item['id'] == change.doc.id);
              }
            }

            _loading = false;
            notifyListeners();
          },
          onError: (err) {
            _loading = false;
            notifyListeners();
          },
        );
  }

  Future<void> disposeListener() async {
    await _sub?.cancel();
    _sub = null;
  }

  @override
  void dispose() {
    disposeListener();
    super.dispose();
  }

  // Keep these helper methods for CRUD operations if needed by UI
  Future<void> add(String judul, String isi, {String audience = 'all'}) async {
    await _fs.collection('pengumuman').add({
      'title': judul,
      'content': isi,
      'audience': audience,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(
    String id,
    String judul,
    String isi, {
    String audience = 'all',
  }) async {
    await _fs.collection('pengumuman').doc(id).update({
      'title': judul,
      'content': isi,
      'audience': audience,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) async {
    await _fs.collection('pengumuman').doc(id).delete();
  }
}