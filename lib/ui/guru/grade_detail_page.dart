import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradeDetailPage extends StatefulWidget {
  final String gradeDocId;
  const GradeDetailPage({super.key, required this.gradeDocId});

  @override
  State<GradeDetailPage> createState() => _GradeDetailPageState();
}

class _GradeDetailPageState extends State<GradeDetailPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tugasC = TextEditingController();
  final TextEditingController _utsC = TextEditingController();
  final TextEditingController _uasC = TextEditingController();
  final TextEditingController _akhirC = TextEditingController();
  final TextEditingController _predikatC = TextEditingController();

  bool _initialized = false;
  bool _saving = false;

  String _formatDate(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '';
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

  Future<void> _save(DocumentSnapshot doc) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final docRef = _fs.collection('grade').doc(widget.gradeDocId);
    final Map<String, dynamic> update = {};

    void putParsed(String key, TextEditingController c) {
      final v = c.text.trim();
      if (v.isEmpty) return;
      final parsed = num.tryParse(v);
      update[key] = parsed ?? v;
    }

    putParsed('tugas', _tugasC);
    putParsed('uts', _utsC);
    putParsed('uas', _uasC);
    putParsed('akhir', _akhirC);
    update['predikat'] = _predikatC.text.trim();

    try {
      if (update.isNotEmpty) {
        await docRef.update(update);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perubahan tersimpan')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _tugasC.dispose();
    _utsC.dispose();
    _uasC.dispose();
    _akhirC.dispose();
    _predikatC.dispose();
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
                    child: Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
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
              "Detail / Edit Nilai",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Kelola dan tinjau performa siswa",
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: _fs.collection('grade').doc(widget.gradeDocId).snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  _buildHeader(),
                  const Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            if (!snap.hasData || !snap.data!.exists) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Data nilai tidak ditemukan.',
                        style: GoogleFonts.outfit(color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ),
                ],
              );
            }
            final doc = snap.data!;
            final data = doc.data() as Map<String, dynamic>? ?? {};

            if (!_initialized) {
              _tugasC.text = (data['tugas'] ?? data['tugas_nilai'] ?? '').toString();
              _utsC.text = (data['uts'] ?? '').toString();
              _uasC.text = (data['uas'] ?? '').toString();
              _akhirC.text = (data['akhir'] ?? data['final'] ?? data['score'] ?? data['nilai'] ?? '').toString();
              _predikatC.text = (data['predikat'] ?? data['grade_predikat'] ?? '').toString();
              _initialized = true;
            }

            final subject = (data['subject'] ?? data['mapel'] ?? '').toString();
            final student = (data['student_name'] ?? data['student'] ?? data['student_id'] ?? doc.id).toString();
            final created = _formatDate(data['created_at']);

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded, color: Colors.cyan, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      student,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.book_outlined, color: Colors.cyan, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    subject,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              _buildInputField(
                                controller: _tugasC,
                                label: 'Nilai Tugas',
                                icon: Icons.assignment_rounded,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _utsC,
                                label: 'Nilai UTS',
                                icon: Icons.quiz_rounded,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _uasC,
                                label: 'Nilai UAS',
                                icon: Icons.assessment_rounded,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _akhirC,
                                label: 'Nilai Akhir',
                                icon: Icons.grade_rounded,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _predikatC,
                                label: 'Predikat (A/B/C/D/E)',
                                icon: Icons.text_snippet_rounded,
                                isDark: isDark,
                                isNumeric: false,
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _saving ? null : () => _save(doc),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyanAccent.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      ),
                                      child: _saving
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : Text('SIMPAN', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Material(
                                    color: Colors.cyan.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    child: InkWell(
                                      onTap: () {
                                        final computed = _computePredikatFromScore(_akhirC.text.trim());
                                        setState(() => _predikatC.text = computed);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Icon(Icons.calculate_rounded, color: Colors.cyan),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isNumeric = true,
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
      keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (v) {
        if (!isNumeric) return null;
        if (v == null || v.trim().isEmpty) return null;
        final n = num.tryParse(v);
        if (n == null) return 'Angka tidak valid';
        if (n > 100) return 'Max 100';
        return null;
      },
    );
  }
}