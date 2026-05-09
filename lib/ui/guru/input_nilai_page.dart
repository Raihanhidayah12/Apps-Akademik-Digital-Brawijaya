import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InputNilaiPage extends StatefulWidget {
  const InputNilaiPage({super.key});

  @override
  State<InputNilaiPage> createState() => _InputNilaiPageState();
}

class _InputNilaiPageState extends State<InputNilaiPage> {
  final _fs = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // selections
  String? _selectedKelas;
  String? _selectedJurusan;
  Map<String, dynamic>? _selectedSiswa;

  // teacher info
  String _teacherSubject = '-';
  String? _teacherId;

  // UI state
  bool _loading = true;

  // controllers
  final _tugasCtrl = TextEditingController();
  final _utsCtrl = TextEditingController();
  final _uasCtrl = TextEditingController();

  // choices
  final List<String> _kelasList = ['X', 'XI', 'XII'];
  final List<String> _jurusanList = ['RPL', 'TKJ', 'MM', 'DKV'];
  List<Map<String, dynamic>> _siswaList = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final teacherSnap = await _fs
        .collection('guru')
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (teacherSnap.docs.isNotEmpty) {
      final t = teacherSnap.docs.first;
      setState(() {
        _teacherSubject = (t.data()['subject'] ?? '-') as String;
        _teacherId = t.id;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadSiswaByKelasJurusan() async {
    if (_selectedKelas == null || _selectedJurusan == null) return;

    setState(() {
      _selectedSiswa = null;
      _siswaList = [];
      _loading = true;
    });

    try {
      final snap = await _fs
          .collection('siswa')
          .where('kelas', isEqualTo: _selectedKelas)
          .where('jurusan', isEqualTo: _selectedJurusan)
          .get();

      final list = snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data() as Map);
        m['id'] = d.id;
        return m;
      }).toList();

      // Query existing grades for this teacher, subject, class, and major
      final gradeSnap = await _fs
          .collection('grade')
          .where('teacher_id', isEqualTo: _teacherId)
          .where('subject', isEqualTo: _teacherSubject)
          .where('kelas', isEqualTo: _selectedKelas)
          .where('jurusan', isEqualTo: _selectedJurusan)
          .get();

      final gradedStudentIds = gradeSnap.docs
          .map((d) => d['student_id'] as String)
          .toSet();

      // Filter out students who have already been graded
      final filteredList = list
          .where((s) => !gradedStudentIds.contains(s['id']))
          .toList();

      setState(() {
        _siswaList = filteredList;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat siswa: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _predikatFromScore(double akhir) {
    if (akhir >= 85) return 'A';
    if (akhir >= 75) return 'B';
    if (akhir >= 65) return 'C';
    return 'D';
  }

  Future<void> _saveNilai() async {
    if (!_formKey.currentState!.validate()) return;

    final tugas = int.tryParse(_tugasCtrl.text) ?? 0;
    final uts = int.tryParse(_utsCtrl.text) ?? 0;
    final uas = int.tryParse(_uasCtrl.text) ?? 0;
    final akhir = (tugas * 0.3) + (uts * 0.3) + (uas * 0.4);
    final predikat = _predikatFromScore(akhir);

    if (_selectedSiswa == null ||
        _teacherId == null ||
        _selectedKelas == null ||
        _selectedJurusan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi pilihan siswa/kelas/jurusan terlebih dahulu'),
        ),
      );
      return;
    }

    try {
      await _fs.collection('grade').add({
        'student_id': _selectedSiswa!['id'],
        'student_name': _selectedSiswa!['name'],
        'teacher_id': _teacherId,
        'subject': _teacherSubject,
        'kelas': _selectedKelas,
        'jurusan': _selectedJurusan,
        'tugas': tugas,
        'uts': uts,
        'uas': uas,
        'akhir': akhir,
        'predikat': predikat,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Nilai berhasil disimpan')),
      );

      _tugasCtrl.clear();
      _utsCtrl.clear();
      _uasCtrl.clear();
      setState(() => _selectedSiswa = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan nilai: $e')));
    }
  }

  @override
  void dispose() {
    _tugasCtrl.dispose();
    _utsCtrl.dispose();
    _uasCtrl.dispose();
    super.dispose();
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
                    child: Icon(Icons.grade_rounded, color: Colors.white, size: 28),
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
              "Input Nilai Siswa",
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
                const Icon(Icons.book_rounded, color: Colors.cyanAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Mata Pelajaran: $_teacherSubject",
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
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      children: [
                        Text(
                          'Konfigurasi Siswa',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSelectionCard(
                                      isDark: isDark,
                                      label: 'Kelas',
                                      value: _selectedKelas,
                                      items: _kelasList,
                                      onChanged: (v) {
                                        setState(() => _selectedKelas = v);
                                        _loadSiswaByKelasJurusan();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildSelectionCard(
                                      isDark: isDark,
                                      label: 'Jurusan',
                                      value: _selectedJurusan,
                                      items: _jurusanList,
                                      onChanged: (v) {
                                        setState(() => _selectedJurusan = v);
                                        _loadSiswaByKelasJurusan();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_siswaList.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    child: DropdownButtonFormField<Map<String, dynamic>>(
                                      value: _selectedSiswa,
                                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Pilih Siswa',
                                        labelStyle: GoogleFonts.outfit(color: Colors.cyan[700], fontWeight: FontWeight.w600),
                                      ),
                                      items: _siswaList
                                          .map((s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(
                                                  '${s['name']} (${s['nis']})',
                                                  style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (v) => setState(() => _selectedSiswa = v),
                                    ),
                                  ),
                                ),
                              if (_selectedKelas != null && _selectedJurusan != null && _siswaList.isEmpty && !_loading)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Semua siswa di kelas ini sudah dinilai.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(color: Colors.orange[800], fontWeight: FontWeight.w500),
                                  ),
                                ),
                              const SizedBox(height: 30),
                              if (_selectedSiswa != null) ...[
                                Text(
                                  'Formulir Nilai',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(24),
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
                                    children: [
                                      _buildInputField(
                                        controller: _tugasCtrl,
                                        label: 'Nilai Tugas (30%)',
                                        icon: Icons.assignment_rounded,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInputField(
                                        controller: _utsCtrl,
                                        label: 'Nilai UTS (30%)',
                                        icon: Icons.quiz_rounded,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInputField(
                                        controller: _uasCtrl,
                                        label: 'Nilai UAS (40%)',
                                        icon: Icons.assessment_rounded,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _saveNilai,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.cyanAccent.shade700,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 18),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                            elevation: 5,
                                            shadowColor: Colors.cyanAccent.withOpacity(0.4),
                                          ),
                                          child: Text(
                                            'SIMPAN NILAI',
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSelectionCard({
    required bool isDark,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonFormField<String>(
          value: value,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: GoogleFonts.outfit(color: Colors.cyan[700], fontWeight: FontWeight.w600, fontSize: 14),
          ),
          items: items.map((k) => DropdownMenuItem(value: k, child: Text(k, style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: isDark ? Colors.white54 : Colors.black45),
        prefixIcon: Icon(icon, color: Colors.cyanAccent.shade700),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.cyanAccent.shade700, width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Masukkan nilai';
        final n = int.tryParse(v);
        if (n == null) return 'Angka tidak valid';
        if (n < 0 || n > 100) return 'Range 0-100';
        return null;
      },
    );
  }
}