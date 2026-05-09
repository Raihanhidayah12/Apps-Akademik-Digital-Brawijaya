import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';
import 'login_page.dart';

// Import dashboard sesuai role
import 'dashboards/admin_dashboard.dart';
import 'dashboards/guru_dashboard.dart';
import 'dashboards/siswa_dashboard.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// Development helpers removed (unused)

    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        // 🌀 Tampilkan loading saat inisialisasi AuthProvider
        if (auth.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🏠 Jika belum login → tampilkan HomePage (landing page)
        if (auth.current == null) {
          return const HomePage();
        }

        // ✅ Jika sudah login → arahkan ke dashboard sesuai role
        final user = auth.current!;
        switch (user.role) {
          case 'admin':
            return const DashboardAdmin();
          case 'guru':
            return const DashboardGuru();
          case 'siswa':
            return const DashboardSiswa();
          default:
            // Jika role tidak dikenali, arahkan ke Login
            return const LoginPage();
        }
      },
    );
  }
}
