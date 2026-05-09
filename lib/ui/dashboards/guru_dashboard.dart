import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../guru/input_nilai_page.dart';
import '../guru/lihat_jadwal_page.dart';
import '../guru/data_siswa_dinilai_page.dart';
import '../home_page.dart';

class DashboardGuru extends StatefulWidget {
  const DashboardGuru({super.key});

  @override
  State<DashboardGuru> createState() => _DashboardGuruState();
}

class _DashboardGuruState extends State<DashboardGuru> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _scheduleSubscription;

  Map<String, int> _schedulesPerDay = {};
  bool _loading = true;
  String _teacherName = '';
  String _teacherSubject = '';

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() async {
    if (!mounted) return;
    setState(() => _loading = true);

    // Get current firebase user (we need uid to match 'user_id')
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    // Get teacher data by uid
    final teacherSnap = await _fs
        .collection('guru')
        .where('user_id', isEqualTo: firebaseUser.uid)
        .get();

    if (teacherSnap.docs.isNotEmpty) {
      final teacherData = teacherSnap.docs.first.data();
      if (!mounted) return;
      setState(() {
        _teacherName = teacherData['name'] ?? 'Guru';
        _teacherSubject = teacherData['subject'] ?? '';
      });

      // Listener for schedules
      _scheduleSubscription = _fs
          .collection('jadwal')
          .where('teacher_id', isEqualTo: teacherSnap.docs.first.id)
          .snapshots()
          .listen(
            (snapshot) {
              final schedules = snapshot.docs;
              final Map<String, int> schedulesPerDay = {
                'Senin': 0,
                'Selasa': 0,
                'Rabu': 0,
                'Kamis': 0,
                'Jumat': 0,
              };
              for (var doc in schedules) {
                final day = doc.data()['day'] as String?;
                if (day != null && schedulesPerDay.containsKey(day)) {
                  schedulesPerDay[day] = schedulesPerDay[day]! + 1;
                }
              }
              if (!mounted) return;
              setState(() => _schedulesPerDay = schedulesPerDay);
              _checkLoadingComplete();
            },
            onError: (error) {
              if (!mounted) return;
              setState(() => _loading = false);
            },
          );
    } else {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _checkLoadingComplete() {
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }

  Widget _buildStatisticsCard({
    required Color color,
    required IconData icon,
    required String title,
    required String count,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

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
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
                  ),
                ),
                Material(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: () async {
                      await context.read<app_auth.AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => false,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "Halo, Guru!",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Selamat datang kembali, $_teacherName",
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (_teacherSubject.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _teacherSubject,
                  style: GoogleFonts.outfit(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget _buildMenuCard({
      required Color color,
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black12),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                children: [
                  Text(
                    "Jadwal Mengajar",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ["Senin", "Selasa", "Rabu", "Kamis", "Jumat"].map((day) {
                              return Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 16),
                                child: _buildStatisticsCard(
                                  color: Colors.cyan,
                                  icon: Icons.calendar_today_rounded,
                                  title: day,
                                  count: (_schedulesPerDay[day] ?? 0).toString(),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                  const SizedBox(height: 40),
                  Consumer<AnnouncementProvider>(
                    builder: (context, announcementProvider, child) {
                      if (announcementProvider.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final userRole = context.read<app_auth.AuthProvider>().current?.role ?? 'siswa';
                      final announcements = announcementProvider.items.where((a) {
                        final aud = (a['audience'] ?? 'all') as String;
                        return aud == 'all' || aud == userRole;
                      }).take(5).toList();
                      if (announcements.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pengumuman Terbaru",
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: announcements.length,
                              itemBuilder: (context, index) {
                                final a = announcements[index];
                                return Container(
                                  width: 280,
                                  margin: const EdgeInsets.only(right: 16),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [const Color(0xFF2C5364), const Color(0xFF203A43)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a['title'] ?? '',
                                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        a['content'] ?? '',
                                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  ),
                  Text(
                    "Layanan Guru",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuCard(
                    color: Colors.cyanAccent.shade700,
                    icon: Icons.edit_note_rounded,
                    title: "Input Nilai Siswa",
                    subtitle: "Kelola nilai tugas, UTS, dan UAS",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InputNilaiPage())),
                  ),
                  _buildMenuCard(
                    color: Colors.indigoAccent,
                    icon: Icons.calendar_month_rounded,
                    title: "Jadwal Mengajar",
                    subtitle: "Lihat jadwal pelajaran mingguan",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LihatJadwalPage())),
                  ),
                  _buildMenuCard(
                    color: Colors.blueAccent,
                    icon: Icons.assignment_ind_rounded,
                    title: "Data Siswa Dinilai",
                    subtitle: "Riwayat penilaian siswa",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataSiswaDinilaiPage())),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "© 2025 Dashboard Guru Brawijaya",
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontSize: 13,
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