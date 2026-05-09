import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../utils/pdf_helper.dart';

class RaporPage extends StatefulWidget {
  const RaporPage({super.key});

  @override
  State<RaporPage> createState() => _RaporPageState();
}

class _RaporPageState extends State<RaporPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  bool _loading = true;
  String _nama = '';
  String _nis = '';
  List<Map<String, dynamic>> _nilai = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'User tidak ditemukan';
        _loading = false;
      });
      return;
    }

    try {
      final sSnap = await _fs
          .collection('siswa')
          .where('user_id', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (sSnap.docs.isEmpty) {
        setState(() {
          _error = 'Data siswa tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final s = sSnap.docs.first.data();
      final siswaId = sSnap.docs.first.id;
      _nama = (s['name'] ?? s['nama'] ?? '') as String;
      _nis = (s['nis'] ?? '') as String;

      final gSnap = await _fs
          .collection('grade')
          .where('student_id', isEqualTo: siswaId)
          .get();

      _nilai = gSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(
          d.data() as Map<String, dynamic>,
        );
        return {
          'subject': data['subject'] ?? '',
          'tugas': data['tugas'] ?? 0,
          'uts': data['uts'] ?? 0,
          'uas': data['uas'] ?? 0,
          'final': data['akhir'] ?? data['final'] ?? 0,
          'predikat': data['predikat'] ?? '',
        };
      }).toList();

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat rapor: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // STATE: Loading
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rapor Siswa'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // STATE: Error
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rapor Siswa'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Card(
            color: colorScheme.errorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // STATE: Data siap
    final displayNama = _nama.isNotEmpty
        ? _nama
        : (FirebaseAuth.instance.currentUser?.email ?? 'Tidak diketahui');
    final displayNis = _nis.isNotEmpty ? _nis : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor Siswa'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Kartu profil siswa
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                color: colorScheme.surfaceVariant,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: colorScheme.onPrimaryContainer,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayNama,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIS: $displayNis',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Kartu preview rapor
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header rapor + tombol aksi
                    Container(
                      color: colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pratinjau Rapor',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          FilledButton.tonalIcon(
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            onPressed: () async {
                              await Printing.layoutPdf(
                                onLayout: (format) =>
                                    PdfHelper.generateRapor(
                                  nama: displayNama,
                                  nis: displayNis,
                                  nilai: _nilai,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Isi PdfPreview
                    SizedBox(
                      height: 520,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: PdfPreview(
                          padding: const EdgeInsets.all(8),
                          canDebug: false,
                          useActions: true,
                          build: (format) => PdfHelper.generateRapor(
                            nama: displayNama,
                            nis: displayNis,
                            nilai: _nilai,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}