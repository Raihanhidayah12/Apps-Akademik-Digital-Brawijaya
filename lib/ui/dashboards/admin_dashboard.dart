import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Removed local DAO imports — dashboard reads counts from Firestore now
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/announcement_provider.dart';
import '../home_page.dart';

// Import halaman CRUD admin
import '../admin/crud_siswa_page.dart';
import '../admin/crud_guru_page.dart';
import '../admin/crud_jadwal_page.dart';
import '../admin/crud_pengumuman_page.dart';
import '../admin/crud_user_page.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  late StreamSubscription<QuerySnapshot> _studentSubscription;
  late StreamSubscription<QuerySnapshot> _teacherSubscription;
  late StreamSubscription<QuerySnapshot> _userSubscription;

  int _studentCount = 0;
  int _teacherCount = 0;
  int _userCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    setState(() => _loading = true);

    // Listener for siswa collection
    _studentSubscription = _fs
        .collection('siswa')
        .snapshots()
        .listen(
          (snapshot) {
            setState(() => _studentCount = snapshot.docs.length);
            _checkLoadingComplete();
          },
          onError: (error) {
            setState(() => _loading = false);
          },
        );

    // Listener for guru collection
    _teacherSubscription = _fs
        .collection('guru')
        .snapshots()
        .listen(
          (snapshot) {
            setState(() => _teacherCount = snapshot.docs.length);
            _checkLoadingComplete();
          },
          onError: (error) {
            setState(() => _loading = false);
          },
        );

    // Listener for users collection
    _userSubscription = _fs
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            setState(() => _userCount = snapshot.docs.length);
            _checkLoadingComplete();
          },
          onError: (error) {
            setState(() => _loading = false);
          },
        );
  }

  void _checkLoadingComplete() {
    // Set loading to false once all counts have been loaded at least once
    if (_studentCount >= 0 && _teacherCount >= 0 && _userCount >= 0) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _studentSubscription.cancel();
    _teacherSubscription.cancel();
    _userSubscription.cancel();
    super.dispose();
  }

  Widget _buildStatisticsCard({
    required Color color,
    required IconData icon,
    required String title,
    required String count,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.blueGrey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.6), color.withOpacity(0.95)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.cyan[100] : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo,
              Colors.blueAccent,
              Colors.cyanAccent.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(.19),
              offset: const Offset(0, 11),
              blurRadius: 34,
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 37,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue[700], size: 46),
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Welcome, Admin!",
                    style: TextStyle(
                      color: Colors.blue[50],
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                splashColor: Colors.white30,
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
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.logout,
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

    Widget _buildMenuCard({
      required Color color,
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: color.withOpacity(.15),
        child: Card(
          color: isDark ? Colors.blueGrey[900] : Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 7),
            child: ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.53), color.withOpacity(0.95)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Colors.white, size: 31),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  color: isDark ? Colors.cyan[100] : color,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.3,
                  color: isDark ? Colors.blueGrey[100] : Colors.grey[700],
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 31,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE),
      body: SafeArea(
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
                    "Statistik",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Expanded(
                              child: _buildStatisticsCard(
                                color: Colors.blue,
                                icon: Icons.school,
                                title: "Total Siswa",
                                count: _studentCount.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatisticsCard(
                                color: Colors.green,
                                icon: Icons.person,
                                title: "Total Guru",
                                count: _teacherCount.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatisticsCard(
                                color: Colors.purple,
                                icon: Icons.account_circle,
                                title: "Total Akun",
                                count: _userCount.toString(),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 32),
                  Consumer<AnnouncementProvider>(
                    builder: (context, announcementProvider, child) {
                      if (announcementProvider.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final userRole =
                          context.read<app_auth.AuthProvider>().current?.role ??
                          'admin';
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: isMobile ? 170 : 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: announcements.length,
                              padding: const EdgeInsets.only(right: 16),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final announcement = announcements[index];
                                final cardWidth = isMobile
                                    ? MediaQuery.of(context).size.width * 0.78
                                    : (MediaQuery.of(context).size.width - 96) /
                                          3;
                                return SizedBox(
                                  width: cardWidth,
                                  child: Card(
                                    color: isDark
                                        ? Colors.blueGrey[900]
                                        : Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.zero,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  Colors.blueGrey[900]!,
                                                  Colors.blueGrey[800]!,
                                                ]
                                              : [
                                                  Colors.white,
                                                  Colors.grey[50]!,
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  child: Icon(
                                                    Icons.campaign,
                                                    color: Colors.teal,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    announcement['title'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDark
                                                          ? Colors.cyan[100]
                                                          : Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Text(
                                                announcement['content'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 4,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: isDark
                                                      ? Colors.blueGrey[300]
                                                      : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  announcement['created_at'] !=
                                                          null
                                                      ? DateTime.fromMillisecondsSinceEpoch(
                                                          (announcement['created_at']
                                                                  as Timestamp)
                                                              .millisecondsSinceEpoch,
                                                        ).toString().split(
                                                          ' ',
                                                        )[0]
                                                      : '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.blueGrey[300]
                                                        : Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    color: Colors.indigo,
                    icon: Icons.school,
                    title: "Kelola Data Siswa",
                    subtitle: "Lihat, tambah, edit, dan hapus data siswa",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudSiswaPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.green,
                    icon: Icons.person,
                    title: "Kelola Data Guru",
                    subtitle: "Lihat, tambah, edit, dan hapus data guru",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudGuruPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.purple,
                    icon: Icons.manage_accounts,
                    title: "Kelola Akun",
                    subtitle:
                        "Kelola akun siswa dan guru (edit role & password)",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudUserPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.orange,
                    icon: Icons.schedule,
                    title: "Kelola Jadwal",
                    subtitle: "Manajemen jadwal pelajaran dan kelas",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudJadwalPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.redAccent,
                    icon: Icons.campaign_rounded,
                    title: "Kelola Pengumuman",
                    subtitle:
                        "Kelola pengumuman sekolah (Info penting dan event!)",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CrudPengumumanPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "© 2025 Admin Panel Brawijaya",
                      style: TextStyle(
                        color: isDark ? Colors.blueGrey[300] : Colors.grey[700],
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
    );
  }
}