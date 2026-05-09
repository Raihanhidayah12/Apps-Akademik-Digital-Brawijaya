import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LihatJadwalPage extends StatefulWidget {
  const LihatJadwalPage({super.key});

  @override
  State<LihatJadwalPage> createState() => _LihatJadwalPageState();
}

class _LihatJadwalPageState extends State<LihatJadwalPage> {
  List<Map<String, dynamic>> _schedules = [];
  bool _loading = true;
  String? _error;
  String _teacherName = '';
  String _teacherSubject = '';

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User tidak ditemukan';
          _loading = false;
        });
        return;
      }

      // Find teacher document
      final teacherSnap = await FirebaseFirestore.instance
          .collection('guru')
          .where('user_id', isEqualTo: user.uid)
          .get();

      if (teacherSnap.docs.isEmpty) {
        setState(() {
          _error = 'Data guru tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final teacherData = teacherSnap.docs.first.data();
      _teacherName = teacherData['name'] ?? 'Guru';
      _teacherSubject = teacherData['subject'] ?? '';

      final teacherId = teacherSnap.docs.first.id;

      // Load schedules for this teacher. Avoid server-side composite index
      // requirement by fetching then sorting client-side.
      final scheduleSnap = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('teacher_id', isEqualTo: teacherId)
          .get();

      _schedules = scheduleSnap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      // Sort by weekday order (Senin..Jumat) so UI is predictable without
      // requiring Firestore composite indexes. If a day isn't recognized,
      // fall back to string compare.
      final dayOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
      _schedules.sort((a, b) {
        final da = (a['day'] ?? '') as String;
        final db = (b['day'] ?? '') as String;
        final ia = dayOrder.indexOf(da);
        final ib = dayOrder.indexOf(db);
        if (ia == -1 && ib == -1) return da.compareTo(db);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat jadwal: $e';
        _loading = false;
      });
    }
  }

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
                  child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 28),
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
            _teacherSubject.isNotEmpty ? "Jadwal $_teacherSubject" : "Jadwal Mengajar",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: Colors.cyanAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Halo, $_teacherName!",
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Daftar Jadwal",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.sort_rounded, color: Colors.cyan[700], size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _loading
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: CircularProgressIndicator(),
                        ))
                      : _error != null
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      : _schedules.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(Icons.event_busy_rounded, size: 80, color: isDark ? Colors.white10 : Colors.black12),
                              const SizedBox(height: 16),
                              Text(
                                "Belum ada jadwal mengajar",
                                style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white38 : Colors.black38,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final sched = _schedules[index];
                            final day = sched['day'] ?? '-';
                            final time = sched['time'] ?? '-';
                            final kelas = sched['kelas'] ?? '-';
                            final jurusan = sched['jurusan'] ?? '';
                            
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        color: Colors.cyanAccent.shade700,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    day,
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 18,
                                                      color: isDark ? Colors.cyanAccent : Colors.cyan[800],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.cyan.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      "Kelas $kelas $jurusan",
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.cyan[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time_rounded, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    time,
                                                    style: GoogleFonts.outfit(
                                                      color: isDark ? Colors.white70 : Colors.black87,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.subject_rounded, size: 16, color: isDark ? Colors.white54 : Colors.black45),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    sched['subject'] ?? '-',
                                                    style: GoogleFonts.outfit(
                                                      color: isDark ? Colors.white70 : Colors.black87,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "© 2025 Dashboard Guru Brawijaya",
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
