import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../providers/auth_provider.dart';
import 'widgets/app_text_field.dart';
import 'widgets/app_button.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;

  // state untuk show/hide password
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool _isDarkLocal = false;

  final String _role = 'siswa_pending';

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.11),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutQuart));
          final fade = Tween<double>(
            begin: 0,
            end: 1,
          ).chain(CurveTween(curve: Curves.easeIn));
          return SlideTransition(
            position: animation.drive(slide),
            child: FadeTransition(opacity: animation.drive(fade), child: child),
          );
        },
      ),
    );
  }

  void _showSnack(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red[600] : Colors.green[600],
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final bool isDark = _isDarkLocal;
    final Color primaryColor = isDark
        ? const Color(0xFF8E9BFF)
        : const Color(0xFF3F51B5);
    final Color cardTint = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.25);
    final Color borderTint = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.30);
    final Color titleColor = isDark
        ? Colors.white.withOpacity(0.95)
        : const Color(0xFF1A237E);

    final labelColor = isDark
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.8);
    final inputColor = isDark
        ? Colors.white.withOpacity(0.95)
        : Colors.black.withOpacity(0.9);

    return Scaffold(
      body: Stack(
        children: [
          // background + blur dekor
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF050816),
                        Color(0xFF151A30),
                        Color(0xFF232946),
                      ]
                    : const [
                        Color(0xFFB3E5FC),
                        Color(0xFFD1C4E9),
                        Color(0xFFF3E5F5),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  left: -30,
                  child: _BlurBubble(
                    size: 140,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  right: -50,
                  child: _BlurBubble(
                    size: 190,
                    color: primaryColor.withOpacity(0.30),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutQuad,
                        constraints: const BoxConstraints(maxWidth: 420),
                        decoration: BoxDecoration(
                          color: cardTint,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.45)
                                  : Colors.blueGrey.withOpacity(0.32),
                              blurRadius: 34,
                              offset: const Offset(0, 18),
                            ),
                          ],
                          border: Border.all(color: borderTint, width: 1.2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 43,
                                      backgroundColor: primaryColor.withOpacity(
                                        0.14,
                                      ),
                                      child: Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 45,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "Buat Akun Baru",
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: titleColor,
                                            letterSpacing: 0.4,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    AppTextField(
                                      controller: _username,
                                      label: 'Username',
                                      keyboardType: TextInputType.text,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return "Username wajib diisi";
                                        }
                                        if (v.contains("@")) {
                                          return "Jangan pakai @, cukup username saja";
                                        }
                                        return null;
                                      },
                                      labelStyle: TextStyle(color: labelColor),
                                      textStyle: TextStyle(color: inputColor),
                                    ),
                                    const SizedBox(height: 16),

                                    // PASSWORD
                                    AppTextField(
                                      controller: _pass,
                                      label: 'Password',
                                      obscure: !_showPassword,
                                      validator: (v) =>
                                          Validators.password(v, min: 6),
                                      labelStyle: TextStyle(color: labelColor),
                                      textStyle: TextStyle(color: inputColor),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: IconButton(
                                          splashRadius: 20,
                                          icon: Icon(
                                            _showPassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            size: 22,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.9)
                                                : Colors.black,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // KONFIRMASI PASSWORD
                                    AppTextField(
                                      controller: _confirm,
                                      label: 'Konfirmasi Password',
                                      obscure: !_showConfirmPassword,
                                      validator: (v) =>
                                          Validators.confirm(v, _pass.text),
                                      labelStyle: TextStyle(color: labelColor),
                                      textStyle: TextStyle(color: inputColor),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: IconButton(
                                          splashRadius: 20,
                                          icon: Icon(
                                            _showConfirmPassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            size: 22,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.9)
                                                : Colors.black,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showConfirmPassword =
                                                  !_showConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    if (auth.error != null)
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.45),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                auth.error!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    const SizedBox(height: 16),
                                    AppButton(
                                      text: 'Daftar',
                                      loading: _submitting,
                                      onPressed: _submitting
                                          ? null
                                          : () async {
                                              if (!_formKey.currentState!
                                                  .validate()) {
                                                return;
                                              }
                                              setState(
                                                () => _submitting = true,
                                              );

                                              final email =
                                                  "${_username.text.trim()}@Brawijaya.com";

                                              final ok = await context
                                                  .read<AuthProvider>()
                                                  .register(
                                                    email,
                                                    _pass.text,
                                                    role: _role,
                                                  );

                                              if (!mounted) return;
                                              setState(
                                                () => _submitting = false,
                                              );

                                              if (ok) {
                                                _showSnack(
                                                  context,
                                                  'Registrasi berhasil! Akun Anda menunggu verifikasi admin.',
                                                  error: false,
                                                );
                                                _navigateToLogin(context);
                                              } else {
                                                _showSnack(
                                                  context,
                                                  auth.error ??
                                                      'Gagal daftar, coba lagi.',
                                                  error: true,
                                                );
                                              }
                                            },
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("Sudah punya akun? "),
                                        TextButton(
                                          onPressed: () =>
                                              _navigateToLogin(context),
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // toggle dark / light
          Positioned(
            top: 19,
            right: 15,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: _isDarkLocal
                    ? Colors.white12
                    : Colors.deepPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                tooltip: _isDarkLocal ? 'Mode terang' : 'Mode gelap',
                icon: Icon(
                  _isDarkLocal
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: _isDarkLocal
                      ? Colors.amberAccent[200]
                      : Colors.deepPurple.shade400,
                ),
                onPressed: () {
                  setState(() {
                    _isDarkLocal = !_isDarkLocal;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }
}
