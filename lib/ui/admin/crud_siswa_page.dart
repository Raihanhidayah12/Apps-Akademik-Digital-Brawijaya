import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudSiswaPage extends StatefulWidget {
  const CrudSiswaPage({super.key});

  @override
  State<CrudSiswaPage> createState() => _CrudSiswaPageState();
}

class _CrudSiswaPageState extends State<CrudSiswaPage> {
  final _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _siswaList = [];
  bool _loading = true;

  final List<String> _kelasList = ['X', 'XI', 'XII'];
  final List<String> _jurusanList = ['RPL', 'TKJ', 'MM', 'DKV'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      // Avoid composite queries that may require a Firestore index on web.
      // Fetch all siswa and sort locally by kelas then name.
      final snap = await _fs.collection('siswa').get();
      _siswaList = snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id;
        return m;
      }).toList();
      _siswaList.sort((a, b) {
        final ka = (a['kelas'] ?? '').toString();
        final kb = (b['kelas'] ?? '').toString();
        final cmpK = ka.compareTo(kb);
        if (cmpK != 0) return cmpK;
        final na = (a['name'] ?? '').toString();
        final nb = (b['name'] ?? '').toString();
        return na.compareTo(nb);
      });
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByKelas(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var s in data) {
      final key = '${s['kelas']}-${s['jurusan']}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(s);
    }
    return grouped;
  }

  Future<String> _generateNextNIS() async {
    try {
      // Retrieve all NIS values and compute the next number locally to avoid
      // depending on Firestore indexes for ordered queries.
      final snap = await _fs.collection('siswa').get();
      int maxNum = 0;
      for (var d in snap.docs) {
        final nisStr = d.data()['nis']?.toString() ?? '';
        final num = int.tryParse(nisStr) ?? 0;
        if (num > maxNum) maxNum = num;
      }
      if (maxNum == 0) {
        return DateTime.now().millisecondsSinceEpoch.toString().substring(4);
      }
      return (maxNum + 1).toString();
    } catch (_) {
      return DateTime.now().millisecondsSinceEpoch.toString().substring(4);
    }
  }

  void _showForm([Map<String, dynamic>? siswa]) {
    final nisCtrl = TextEditingController(text: siswa?['nis'] ?? "");
    final nameCtrl = TextEditingController(text: siswa?['name'] ?? "");
    String selectedKelas = _kelasList.contains(siswa?['kelas'])
        ? (siswa?['kelas'] ?? _kelasList.first)
        : _kelasList.first;
    String selectedJurusan = _jurusanList.contains(siswa?['jurusan'])
        ? (siswa?['jurusan'] ?? _jurusanList.first)
        : _jurusanList.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 29, horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa == null ? "Tambah Siswa" : "Edit Siswa",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nisCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "NIS (auto jika kosong)",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.confirmation_number),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Nama",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                DropdownButtonFormField<String>(
                  value: selectedKelas,
                  decoration: InputDecoration(
                    labelText: "Kelas",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.class_),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: _kelasList
                      .map(
                        (kelas) =>
                            DropdownMenuItem(value: kelas, child: Text(kelas)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedKelas = val;
                  },
                ),
                const SizedBox(height: 13),
                DropdownButtonFormField<String>(
                  value: selectedJurusan,
                  decoration: InputDecoration(
                    labelText: "Jurusan",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.book),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: _jurusanList
                      .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedJurusan = val;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.cyan[200]
                            : Colors.blueGrey,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 13),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 20,
                        ),
                      ),
                      icon: Icon(siswa == null ? Icons.add : Icons.save),
                      label: Text(
                        siswa == null ? "Tambah" : "Simpan",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⚠️ Nama wajib diisi"),
                            ),
                          );
                          return;
                        }

                        // Check class capacity (max 30 per class-jurusan)
                        if (siswa == null) {
                          final countSnap = await _fs
                              .collection('siswa')
                              .where('kelas', isEqualTo: selectedKelas)
                              .where('jurusan', isEqualTo: selectedJurusan)
                              .get();
                          if (countSnap.docs.length >= 30) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "🚫 Kelas $selectedKelas - $selectedJurusan sudah penuh (30 siswa)",
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        if (siswa == null) {
                          // Create new siswa + user account
                          final username = nameCtrl.text
                              .trim()
                              .toLowerCase()
                              .replaceAll(RegExp(r'\s+'), '');
                          final email = '$username@Brawijaya.com';

                          // Check if email already exists
                          final existsSnap = await _fs
                              .collection('users')
                              .where('email', isEqualTo: email)
                              .limit(1)
                              .get();
                          if (existsSnap.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "⚠️ Email $email sudah terdaftar",
                                ),
                              ),
                            );
                            return;
                          }

                          // Generate NIS
                          final nis = nisCtrl.text.isEmpty
                              ? await _generateNextNIS()
                              : nisCtrl.text;

                          try {
                            // Create Firebase Auth user
                            final cred = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: email,
                                  password: nis,
                                );
                            final uid = cred.user!.uid;

                            // Create user profile in Firestore
                            await _fs.collection('users').doc(uid).set({
                              'email': email,
                              'role': 'siswa',
                              'username': username,
                              'created_at': FieldValue.serverTimestamp(),
                            });

                            // Create siswa record
                            await _fs.collection('siswa').add({
                              'user_id': uid,
                              'nis': nis,
                              'name': nameCtrl.text,
                              'kelas': selectedKelas,
                              'jurusan': selectedJurusan,
                              'created_at': FieldValue.serverTimestamp(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "✅ Siswa & akun berhasil dibuat ($email / $nis)",
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Gagal membuat akun: $e'),
                              ),
                            );
                            return;
                          }
                        } else {
                          // Update existing siswa
                          await _fs
                              .collection('siswa')
                              .doc(siswa['id'])
                              .update({
                                'nis': nisCtrl.text,
                                'name': nameCtrl.text,
                                'kelas': selectedKelas,
                                'jurusan': selectedJurusan,
                                'updated_at': FieldValue.serverTimestamp(),
                              });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ Data siswa diperbarui"),
                            ),
                          );
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          _loadData();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSiswa(Map<String, dynamic> s) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 29, horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Konfirmasi Hapus",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 18),
                Text('Yakin ingin menghapus siswa ${s['name']}?'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.cyan[200]
                            : Colors.blueGrey,
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 13),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 20,
                        ),
                      ),
                      icon: Icon(Icons.delete),
                      label: Text(
                        "Hapus",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        final uid = s['user_id'];
        // Delete siswa record
        await _fs.collection('siswa').doc(s['id']).delete();
        // Delete user account from Firestore (not Firebase Auth - needs admin)
        if (uid != null) {
          await _fs.collection('users').doc(uid).delete();
        }
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🗑️ Siswa & data akun berhasil dihapus"),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Gagal hapus: $e')));
      }
    }
  }

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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
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
              child: Icon(Icons.school, color: Colors.blue[700], size: 46),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelola Data Siswa",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Manage student data efficiently",
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
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.arrow_back,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = _groupByKelas(_siswaList);

    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showForm(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _siswaList.isEmpty
                  ? const Center(child: Text("Belum ada data siswa"))
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: grouped.entries.map((entry) {
                        final key = entry.key;
                        final siswas = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.blueGrey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            title: Text(
                              "Kelas $key (${siswas.length}/30)",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: isDark
                                    ? Colors.cyan[100]
                                    : Colors.indigo,
                              ),
                            ),
                            leading: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.indigo.withOpacity(0.53),
                                    Colors.indigo.withOpacity(0.95),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.people_alt_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.expand_more,
                              color: Colors.blueAccent,
                            ),
                            childrenPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            children: siswas.map((s) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.blueGrey[800]
                                      : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(
                                        0.05,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.withOpacity(0.53),
                                          Colors.blue.withOpacity(0.95),
                                        ],
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    "${s['name']} (${s['nis']})",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${s['kelas']} - ${s['jurusan']}",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.blueGrey[200]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () => _showForm(s),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteSiswa(s),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}