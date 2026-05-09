import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/announcement_provider.dart';
import '../home_page.dart';
import '../siswa/rapor_page.dart';
import '../siswa/lihat_jadwal_page.dart';
import '../siswa/pengumuman_page.dart';
import '../../models/grade.dart';
import '../widgets/grade_chart.dart';

class DashboardSiswa extends StatefulWidget {
  const DashboardSiswa({super.key});

  @override
  State<DashboardSiswa> createState() => _DashboardSiswaState();
}

class _DashboardSiswaState extends State<DashboardSiswa> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePref();
  }

  Future<void> _loadThemePref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool('isDarkMode');
      if (saved != null) {
        setState(() => isDarkMode = saved);
      } else {
        // default to system brightness if no pref is stored
        final platformBrightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        setState(() => isDarkMode = platformBrightness == Brightness.dark);
      }
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> _saveThemePref(bool dark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', dark);
    } catch (_) {
      // ignore
    }
  }

  String _formatNameFromEmail(String email) {
    if (email.isEmpty) return '';
    final local = email.split('@').first;
    final parts = local.replaceAll(RegExp(r'[._]'), ' ').split(' ');
    return parts
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  Future<List<Grade>> _fetchGrades() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final fs = FirebaseFirestore.instance;
    final sSnap = await fs
        .collection('siswa')
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (sSnap.docs.isEmpty) return [];

    final siswaId = sSnap.docs.first.id;
    final gSnap = await fs
        .collection('grade')
        .where('student_id', isEqualTo: siswaId)
        .get();

    return gSnap.docs.map((d) {
      final data = d.data();
      final subject = (data['subject'] ?? 'Umum') as String;
      final akhir =
          (data['akhir'] ?? data['final'] ?? data['final_score'] ?? 0) as num;
      return Grade(
        id: (data['id'] is int) ? data['id'] as int : 0,
        studentId: (data['student_id'] is int) ? data['student_id'] as int : 0,
        subject: subject,
        tugas: (data['tugas'] is num) ? (data['tugas'] as num).toDouble() : 0.0,
        uts: (data['uts'] is num) ? (data['uts'] as num).toDouble() : 0.0,
        uas: (data['uas'] is num) ? (data['uas'] as num).toDouble() : 0.0,
        finalScore: akhir.toDouble(),
        grade: (data['grade'] ?? '-') as String,
      );
    }).toList();
  }

  Widget _buildHeader(bool isMobile, ThemeData theme) {
    final auth = context.watch<app_auth.AuthProvider>();
    final user = auth.current;
    String studentName;
    if (user != null && (user.username ?? '').trim().isNotEmpty) {
      studentName = user.username!;
    } else {
      final email = user?.email ?? '';
      studentName = _formatNameFromEmail(email);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [Colors.deepPurple.shade700, Colors.indigo.shade700]
              : [
                  Colors.indigo,
                  Colors.deepPurpleAccent,
                  Colors.purpleAccent.shade100,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black54
                : Colors.purpleAccent.withOpacity(.15),
            offset: const Offset(0, 12),
            blurRadius: 25,
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: theme.brightness == Brightness.dark
                    ? [Colors.deepPurple.shade300, Colors.indigo.shade300]
                    : [Colors.purpleAccent, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.indigo.withOpacity(.9)
                      : Colors.deepPurple.withOpacity(.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $studentName",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  "Selamat datang di dashboard siswa",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
              color: Colors.white,
              size: 30,
            ),
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
            onPressed: () async {
              setState(() {
                isDarkMode = !isDarkMode;
              });
              await _saveThemePref(isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 30),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<app_auth.AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              }
            },
          ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: color.withOpacity(.12),
      child: Card(
        color: isDark ? Colors.grey[850] : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: ListTile(
            leading: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.7), color],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 19,
                color: isDark ? Colors.cyan[100] : color,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13.7,
                color: isDark ? Colors.blueGrey[100] : Colors.grey[700],
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              size: 32,
              color: Colors.deepPurpleAccent.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikPreview(bool isMobile) {
    return FutureBuilder<List<Grade>>(
      future: _fetchGrades(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Gagal memuat grafik: ${snap.error}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          );
        }

        final grades = snap.data ?? [];
        if (grades.isEmpty) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Belum ada data nilai untuk ditampilkan.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafik Nilai',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            GradeChart(grades: grades),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    // For demo, override theme based on isDarkMode
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme),
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.indigoAccent,
        ),
      ),
      child: Scaffold(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF121212)
            : const Color(0xFFF7F8FF),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(isMobile, theme),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AnnouncementProvider>(
                      builder: (context, announcementProvider, child) {
                        if (announcementProvider.loading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final userRole =
                            context
                                .read<app_auth.AuthProvider>()
                                .current
                                ?.role ??
                            'siswa';
                        final announcements = announcementProvider.items
                            .where((a) {
                              final aud = (a['audience'] ?? 'all') as String;
                              return aud == 'all' || aud == userRole;
                            })
                            .take(5)
                            .toList();
                        if (announcements.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pengumuman",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: isMobile ? 170 : 220,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: announcements.length,
                                padding: const EdgeInsets.only(right: 16),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final a = announcements[index];
                                  final cardWidth = isMobile
                                      ? MediaQuery.of(context).size.width * 0.78
                                      : (MediaQuery.of(context).size.width -
                                                96) /
                                            3;
                                  return SizedBox(
                                    width: cardWidth,
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              a['title'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: Text(
                                                a['content'] ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color:
                                                      theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    _buildGrafikPreview(isMobile),
                    const SizedBox(height: 28),
                    Text(
                      "Menu",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildMenuCard(
                      color: Colors.indigo,
                      icon: Icons.schedule,
                      title: "Lihat Jadwal",
                      subtitle: "Lihat jadwal pelajaran Anda",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LihatJadwalSiswaPage(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      color: Colors.indigo,
                      icon: Icons.receipt_long,
                      title: "Lihat Nilai / Rapor",
                      subtitle: "Lihat rapor dan detail nilai Anda",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RaporPage()),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: Text(
                        "© 2025 Aplikasi Sekolah",
                        style: GoogleFonts.poppins(
                          color: theme.brightness == Brightness.dark
                              ? Colors.blueGrey[300]
                              : Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
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