import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LihatJadwalSiswaPage extends StatefulWidget {
  const LihatJadwalSiswaPage({super.key});

  @override
  State<LihatJadwalSiswaPage> createState() => _LihatJadwalSiswaPageState();
}

class _LihatJadwalSiswaPageState extends State<LihatJadwalSiswaPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _schedules = [];
  bool _loading = true;
  String? _error;
  String? _kelas;
  String? _jurusan;
  Map<String, String> _teacherNames = {};

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo,
            Colors.deepPurpleAccent,
            Colors.purpleAccent.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(.12),
            offset: const Offset(0, 11),
            blurRadius: 34,
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 37,
              backgroundColor: Colors.white,
              child: Icon(Icons.schedule, color: Colors.indigo[700], size: 46),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Jadwal Pelajaran",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 19 : 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Lihat jadwal pelajaran Anda",
                  style: TextStyle(
                    color: Colors.purple[50],
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              splashColor: Colors.white30,
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User tidak ditemukan';
          _loading = false;
        });
        return;
      }

      String? kelas;
      String? jurusan;
      // prefer 'siswa' collection where students are stored with user_id
      final sSnap = await _fs
          .collection('siswa')
          .where('user_id', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (sSnap.docs.isNotEmpty) {
        final data = sSnap.docs.first.data();
        kelas = (data['kelas'] ?? data['kelas_siswa']) as String?;
        jurusan = (data['jurusan'] ?? data['jurusan_siswa']) as String?;
      } else {
        // fallback to 'users' doc
        final userDoc = await _fs.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          kelas = data?['kelas'] as String?;
          jurusan = data?['jurusan'] as String?;
        }
      }

      QuerySnapshot snap;
      if (kelas != null && jurusan != null) {
        snap = await _fs
            .collection('jadwal')
            .where('kelas', isEqualTo: kelas)
            .where('jurusan', isEqualTo: jurusan)
            .get();
      } else if (kelas != null) {
        snap = await _fs
            .collection('jadwal')
            .where('kelas', isEqualTo: kelas)
            .get();
      } else {
        // fallback: return all jadwal (admin may filter later)
        snap = await _fs.collection('jadwal').orderBy('day').get();
      }

      _schedules = snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
        m['id'] = d.id;
        return m;
      }).toList();

      // fetch teachers map for displaying names
      try {
        final tSnap = await _fs.collection('guru').get();
        final Map<String, String> tMap = {};
        for (var d in tSnap.docs) {
          final data = d.data() as Map<String, dynamic>;
          tMap[d.id] = (data['name'] ?? '') as String;
        }
        _teacherNames = tMap;
      } catch (_) {
        _teacherNames = {};
      }

      // filter again as safety: only keep entries matching kelas/jurusan
      if (kelas != null) {
        _schedules = _schedules
            .where((s) => (s['kelas'] ?? '') == kelas)
            .toList();
      }
      if (jurusan != null) {
        _schedules = _schedules
            .where((s) => (s['jurusan'] ?? '') == jurusan)
            .toList();
      }

      // sort by day order
      final dayOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      _schedules.sort((a, b) {
        final da = (a['day'] ?? '') as String;
        final db = (b['day'] ?? '') as String;
        final ia = dayOrder.indexOf(da);
        final ib = dayOrder.indexOf(db);
        if (ia == -1 && ib == -1) return da.compareTo(db);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        final cmp = ia.compareTo(ib);
        if (cmp != 0) return cmp;
        // optional: sort by time if available
        final ta = (a['time'] ?? '') as String;
        final tb = (b['time'] ?? '') as String;
        return ta.compareTo(tb);
      });

      // update kelas/jurusan state and loading together
      setState(() {
        _kelas = kelas;
        _jurusan = jurusan;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat jadwal: $e';
        _loading = false;
      });
    }
  }

  String _getTeacherName(Map<String, dynamic> s) {
    if (s['teacher_name'] != null &&
        s['teacher_name'] is String &&
        (s['teacher_name'] as String).trim().isNotEmpty) {
      return s['teacher_name'] as String;
    }
    if (s['teacher'] != null &&
        s['teacher'] is String &&
        (s['teacher'] as String).trim().isNotEmpty) {
      return s['teacher'] as String;
    }
    final tid = s['teacher_id'] as String?;
    if (tid != null &&
        _teacherNames.containsKey(tid) &&
        (_teacherNames[tid] ?? '').isNotEmpty) {
      return _teacherNames[tid]!;
    }
    return s['room'] ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // group schedules by day
    final Map<String, List<Map<String, dynamic>>> byDay = {};
    for (final s in _schedules) {
      final day = (s['day'] ?? 'Umum') as String;
      byDay.putIfAbsent(day, () => []).add(s);
    }

    final dayOrder = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final orderedDays = byDay.keys.toList()
      ..sort((a, b) {
        final ia = dayOrder.indexOf(a);
        final ib = dayOrder.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

    // Build content widgets so we can use RefreshIndicator on the ListView
    final List<Widget> content = [];

    // class header card
    content.add(
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.class_, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kelas',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_kelas ?? '-'} ${_jurusan != null ? ' / $_jurusan' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadSchedules,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
    );

    if (_loading) {
      content.add(const SizedBox(height: 24));
      content.add(const Center(child: CircularProgressIndicator()));
    } else if (_error != null) {
      content.add(const SizedBox(height: 12));
      content.add(
        Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    } else if (_schedules.isEmpty) {
      content.add(const SizedBox(height: 12));
      content.add(const Center(child: Text('Belum ada jadwal untuk Anda')));
    } else {
      // add day sections
      for (final day in orderedDays) {
        final items = byDay[day]!
          ..sort(
            (a, b) => ((a['time'] ?? '') as String).compareTo(
              (b['time'] ?? '') as String,
            ),
          );
        content.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              day,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );

        for (final s in items) {
          content.add(
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                leading: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.deepPurpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.white),
                ),
                title: Text(
                  '${s['subject'] ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text('${s['time'] ?? '-'} • Guru ${_getTeacherName(s)}'),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSchedules,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jadwal Pelajaran",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...content,
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        "© 2025 Aplikasi Sekolah",
                        style: TextStyle(
                          color: isDark
                              ? Colors.blueGrey[300]
                              : Colors.grey[700],
                          fontSize: 13,
                          letterSpacing: 0.15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}