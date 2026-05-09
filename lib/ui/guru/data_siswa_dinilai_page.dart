import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'grade_detail_page.dart';

class DataSiswaDinilaiPage extends StatefulWidget {
  const DataSiswaDinilaiPage({super.key});

  @override
  State<DataSiswaDinilaiPage> createState() => _DataSiswaDinilaiPageState();
}

class _DataSiswaDinilaiPageState extends State<DataSiswaDinilaiPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  String? _teacherDocId;
  bool _loadingTeacher = true;

  // no grouping — show flat list like CRUD siswa design
  final Map<String, Map<String, dynamic>> _studentCache = {};

  // fetch students by ids (chunked whereIn on documentId, then fallback to field 'student_id')
  Future<void> _ensureStudents(List<String> ids) async {
    final missing = ids.where((id) => !_studentCache.containsKey(id)).toList();
    if (missing.isEmpty) return;

    // helper to chunk list
    Iterable<List<T>> _chunks<T>(List<T> list, int size) sync* {
      for (var i = 0; i < list.length; i += size) {
        yield list.sublist(i, i + size > list.length ? list.length : i + size);
      }
    }

    // First try fetching by document ID
    final notFound = <String>[];
    for (var chunk in _chunks<String>(missing, 10)) {
      try {
        final snap = await _fs
            .collection('siswa')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        final foundIds = <String>{};
        for (var doc in snap.docs) {
          _studentCache[doc.id] = doc.data();
          foundIds.add(doc.id);
        }
        for (var id in chunk) {
          if (!foundIds.contains(id)) notFound.add(id);
        }
      } catch (_) {
        // if whereIn on documentId fails for any reason, mark all as not found
        notFound.addAll(chunk);
      }
    }

    // Fallback: query by field 'student_id'
    if (notFound.isNotEmpty) {
      for (var chunk in _chunks<String>(notFound, 10)) {
        try {
          final snap = await _fs
              .collection('siswa')
              .where('student_id', whereIn: chunk)
              .get();
          final foundIds = <String>{};
          for (var doc in snap.docs) {
            // try to get id from field or doc id
            final sid = (doc.data())['student_id']?.toString() ?? doc.id;
            _studentCache[sid] = doc.data();
            foundIds.add(sid);
          }
          // remaining not found will be left absent
        } catch (_) {
          // ignore
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTeacherDocId();
  }

  Future<void> _loadTeacherDocId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _teacherDocId = null;
        _loadingTeacher = false;
      });
      return;
    }

    try {
      final snap = await _fs
          .collection('guru')
          .where('user_id', isEqualTo: user.uid)
          .get();
      if (snap.docs.isNotEmpty) {
        setState(() {
          _teacherDocId = snap.docs.first.id;
          _loadingTeacher = false;
        });
      } else {
        setState(() {
          _teacherDocId = null;
          _loadingTeacher = false;
        });
      }
    } catch (_) {
      setState(() {
        _teacherDocId = null;
        _loadingTeacher = false;
      });
    }
  }

  String _computePredikatFromScore(String scoreStr) {
    if (scoreStr.isEmpty ||
        scoreStr == '-' ||
        scoreStr.toLowerCase() == 'null') {
      return 'Tidak Dinilai';
    }
    final num? score = num.tryParse(scoreStr);
    if (score == null) return 'Tidak Dinilai';
    if (score >= 85) return 'A';
    if (score >= 70) return 'B';
    if (score >= 55) return 'C';
    if (score >= 40) return 'D';
    return 'E';
  }

  String _getStudentNameFromCache(String studentId) {
    final data = _studentCache[studentId];
    if (data == null) return 'Nama siswa tidak tersedia';
    return (data['name'] ?? data['nama'] ?? data['student_name'] ?? studentId)
        .toString();
  }

  String _getClassFromCache(String studentId) {
    final data = _studentCache[studentId];
    if (data == null) return '';
    return (data['class'] ?? data['kelas'] ?? '').toString();
  }

  String _getMajorFromCache(String studentId) {
    final data = _studentCache[studentId];
    if (data == null) return '';
    return (data['major'] ?? data['jurusan'] ?? '').toString();
  }

  String _getStudentName(Map<String, dynamic> data) {
    return (data['student_name'] ??
            data['student'] ??
            'Nama siswa tidak tersedia')
        .toString();
  }

  String _extractStudentId(Map<String, dynamic> data, String docId) {
    return (data['student_id'] ?? data['student'] ?? data['studentId'] ?? docId)
        .toString();
  }

  String _getSubject(Map<String, dynamic> data) {
    return (data['subject'] ?? data['mapel'] ?? '').toString();
  }

  String _formatDate(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget _buildHeader() {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.person_search_rounded, color: Colors.white, size: 28),
                  ),
                ),
                Material(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "Data Siswa Dinilai",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pantau perkembangan nilai siswa Anda",
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_loadingTeacher) {
              return Column(
                children: [
                  _buildHeader(),
                  const Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }

            if (_teacherDocId == null) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Data guru tidak ditemukan.',
                        style: GoogleFonts.outfit(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _fs
                        .collection('grade')
                        .where('teacher_id', isEqualTo: _teacherDocId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fact_check_rounded, size: 80, color: isDark ? Colors.white10 : Colors.black12),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada siswa yang dinilai.',
                                style: GoogleFonts.outfit(color: isDark ? Colors.white38 : Colors.black38),
                              ),
                            ],
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      final ids = docs
                          .map((d) => _extractStudentId(d.data() as Map<String, dynamic>? ?? {}, d.id))
                          .toSet()
                          .toList();
                      _ensureStudents(ids);

                      final sorted = docs.toList()
                        ..sort((a, b) {
                          final ma = _getSubject(a.data() as Map<String, dynamic>? ?? {});
                          final mb = _getSubject(b.data() as Map<String, dynamic>? ?? {});
                          final cmp = ma.compareTo(mb);
                          if (cmp != 0) return cmp;
                          final na = _extractStudentId(a.data() as Map<String, dynamic>? ?? {}, a.id);
                          final nb = _extractStudentId(b.data() as Map<String, dynamic>? ?? {}, b.id);
                          final sa = _studentCache.containsKey(na) ? _getStudentNameFromCache(na) : _getStudentName(a.data() as Map<String, dynamic>? ?? {});
                          final sb = _studentCache.containsKey(nb) ? _getStudentNameFromCache(nb) : _getStudentName(b.data() as Map<String, dynamic>? ?? {});
                          return sa.compareTo(sb);
                        });

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        itemCount: sorted.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Daftar Nilai",
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    "${sorted.length} Siswa",
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.cyan[700],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final doc = sorted[index - 1];
                          final data = doc.data() as Map<String, dynamic>? ?? {};
                          final studentId = _extractStudentId(data, doc.id);
                          final name = _studentCache.containsKey(studentId) ? _getStudentNameFromCache(studentId) : _getStudentName(data);
                          final kelas = _studentCache.containsKey(studentId) ? _getClassFromCache(studentId) : (data['kelas'] ?? data['class'] ?? '').toString();
                          final jurusan = data['jurusan']?.toString() ?? data['major']?.toString() ?? _getMajorFromCache(studentId);
                          final subject = _getSubject(data);
                          final createdAt = _formatDate(data['created_at']);
                          final akhir = (data['akhir'] ?? data['final'] ?? data['score'] ?? data['nilai'])?.toString() ?? '-';
                          final predikat = (data['predikat'] ?? data['grade_predikat'])?.toString() ?? _computePredikatFromScore(akhir);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.cyanAccent.shade700, Colors.cyan.shade900],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    predikat,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "$subject • Kelas $kelas $jurusan",
                                    style: GoogleFonts.outfit(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 12, color: isDark ? Colors.white38 : Colors.black38),
                                      const SizedBox(width: 4),
                                      Text(
                                        createdAt,
                                        style: GoogleFonts.outfit(
                                          color: isDark ? Colors.white38 : Colors.black38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Material(
                                color: Colors.cyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute<bool>(
                                        builder: (_) => GradeDetailPage(gradeDocId: doc.id),
                                      ),
                                    );
                                    if (result == true && mounted) setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(Icons.edit_note_rounded, color: Colors.cyan, size: 24),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}