import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDark = false;

  Color getTitleColor() =>
      isDark ? Colors.white.withOpacity(0.96) : Colors.deepPurple[700]!;
  Color getBodyColor() =>
      isDark ? Colors.white70 : Colors.grey[900]!;
  Color getHighlightColor() =>
      isDark ? Colors.indigoAccent[100]! : Colors.indigo[700]!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF151A30),
                    Color(0xFF232946),
                    Color(0xFF050816),
                  ]
                : const [
                    Color(0xFF6E9FFF),
                    Color(0xFFC9D4FF),
                    Color(0xFFFDFBFF),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // soft circles dekoratif
              Positioned(
                top: -40,
                left: -40,
                child: _BlurCircle(
                  size: 160,
                  color: Colors.white.withOpacity(0.23),
                ),
              ),
              Positioned(
                bottom: -60,
                right: -50,
                child: _BlurCircle(
                  size: 200,
                  color: Colors.deepPurpleAccent.withOpacity(0.25),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubicEmphasized,
                        padding: const EdgeInsets.symmetric(
                            vertical: 42, horizontal: 32),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.09)
                                : Colors.white.withOpacity(0.18),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.blueGrey.withOpacity(0.24)
                                  : Colors.blueGrey.withOpacity(0.15),
                              offset: const Offset(0, 14),
                              blurRadius: 38,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hero supaya icon “terbang” ke halaman login
                            Hero(
                              tag: 'app-logo',
                              child: CircleAvatar(
                                radius: 54,
                                backgroundColor: isDark
                                    ? Colors.white.withOpacity(0.10)
                                    : Colors.deepPurple[100]!
                                        .withOpacity(0.17),
                                child: Icon(
                                  Icons.school_rounded,
                                  size: 63,
                                  color: getHighlightColor(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 23),
                            Text(
                              'Akademik Digital\nBrawijaya',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: getTitleColor(),
                                letterSpacing: 0.7,
                              ),
                            ),
                            const SizedBox(height: 13),
                            Text(
                              "Kelola jadwal, nilai, presensi, dan pengumuman\nlangsung dari satu aplikasi.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: getBodyColor(),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // chip info kecil
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 18,
                                    color: getHighlightColor(),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Terhubung dengan akun sekolah resmi",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: getBodyColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            // Glass highlight
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.12)
                                        : Colors.white.withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Realtime  •  Aman  •  Multi Peran",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: getHighlightColor(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 27),
                            // Tombol login
                            SizedBox(
                              width: 230,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: isDark
                                      ? Colors.blue[800]
                                      : Colors.deepPurple[400],
                                  foregroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor: Colors.black.withOpacity(0.35),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 550),
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const LoginPage(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        final curve = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        );
                                        return FadeTransition(
                                          opacity: curve,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.08),
                                              end: Offset.zero,
                                            ).animate(curve),
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.login_rounded),
                                    SizedBox(width: 8),
                                    Text(
                                      'Masuk ke Sistem',
                                      style: TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: .2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Fitur utama
                            AnimatedOpacity(
                              opacity: 1,
                              duration: const Duration(milliseconds: 600),
                              child: Column(
                                children: [
                                  Text(
                                    'Fitur Utama',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: getTitleColor().withOpacity(0.88),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _FeatureCard(
                                        icon: Icons.schedule_rounded,
                                        label: 'Jadwal',
                                        description: 'Lihat jadwal lengkapmu',
                                        color: getHighlightColor(),
                                        isDark: isDark,
                                      ),
                                      _FeatureCard(
                                        icon: Icons.bar_chart_rounded,
                                        label: 'Nilai',
                                        description: 'Pantau perkembangan akademik',
                                        color: getHighlightColor(),
                                        isDark: isDark,
                                      ),
                                      _FeatureCard(
                                        icon: Icons.check_circle_rounded,
                                        label: 'Presensi',
                                        description: 'Catat kehadiran dengan cepat',
                                        color: getHighlightColor(),
                                        isDark: isDark,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.39)
                              : Colors.blueGrey.withOpacity(0.69),
                          fontSize: 13,
                        ),
                        child:
                            const Text("© 2025 Brawijaya Akademik App"),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol theme switch
              Positioned(
                top: 19,
                right: 15,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.white10 : Colors.deepPurple.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    tooltip: isDark ? "Mode terang" : "Mode gelap",
                    icon: Icon(
                      isDark
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      color: isDark
                          ? Colors.amberAccent[200]
                          : Colors.deepPurple.shade400,
                    ),
                    onPressed: () {
                      setState(() => isDark = !isDark);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget dekoratif blur circle untuk background
class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: size,
          height: size,
          color: color,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool isDark;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white10 : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? Colors.white70
                      : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
