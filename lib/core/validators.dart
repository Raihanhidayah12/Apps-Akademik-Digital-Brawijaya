class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Format email tidak valid';
  }

  static String? password(String? v, {int min = 6}) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < min) return 'Minimal $min karakter';
    return null;
  }

  static String? confirm(String? v, String original) {
    if (v == null || v.isEmpty) return 'Konfirmasi wajib diisi';
    if (v != original) return 'Konfirmasi tidak sama';
    return null;
  }
}