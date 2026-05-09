import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudGuruPage extends StatefulWidget {
  const CrudGuruPage({super.key});

  @override
  State<CrudGuruPage> createState() => _CrudGuruPageState();
}

class _CrudGuruPageState extends State<CrudGuruPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _guruList = [];
  bool _loading = true;

  final List<String> mapelList = [
    "Matematika",
    "Bahasa Indonesia",
    "Bahasa Inggris",
    "IPA",
    "IPS",
    "PKN",
    "Seni Budaya",
    "Penjaskes",
    "Agama",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      final snapshot = await _firestore.collection('guru').get();
      _guruList = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      _guruList.sort((a, b) {
        final sa = (a['subject'] ?? '').toString();
        final sb = (b['subject'] ?? '').toString();
        final cmpS = sa.compareTo(sb);
        if (cmpS != 0) return cmpS;
        final na = (a['name'] ?? '').toString();
        final nb = (b['name'] ?? '').toString();
        return na.compareTo(nb);
      });
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Gagal memuat data: $e")));
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupBySubject(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var g in data) {
      final key = g['subject'] ?? 'Tidak Diketahui';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(g);
    }
    return grouped;
  }

  Future<String> _generateNextNIP() async {
    try {
      final snapshot = await _firestore.collection('guru').get();
      int maxNum = 0;
      for (var doc in snapshot.docs) {
        final nipStr = doc['nip'] as String? ?? '';
        final numStr = nipStr.replaceAll(RegExp(r'\D'), '');
        if (numStr.isNotEmpty) {
          final num = int.tryParse(numStr) ?? 0;
          if (num > maxNum) maxNum = num;
        }
      }
      final nextNum = maxNum + 1;
      return nextNum.toString().padLeft(6, '0');
    } catch (e) {
      return (DateTime.now().millisecondsSinceEpoch % 1000000)
          .toString()
          .padLeft(6, '0');
    }
  }

  Future<void> _showForm([Map<String, dynamic>? guru]) async {
    final nameCtrl = TextEditingController(text: guru?['name'] ?? "");
    String subject = (guru != null && mapelList.contains(guru['subject']))
        ? guru['subject']
        : mapelList.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(27),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 29, horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  guru == null ? "Tambah Guru" : "Edit Guru",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap Guru",
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
                  value: subject,
                  icon: const Icon(Icons.arrow_drop_down),
                  dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                  decoration: InputDecoration(
                    labelText: "Mata Pelajaran",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.book_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: mapelList
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    subject = val ?? mapelList.first;
                  }),
                ),
                if (guru != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Text(
                      "UID: ${guru['user_id']}\nNIP: ${guru['nip']}",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.cyan[100] : Colors.grey[700],
                      ),
                    ),
                  ),
                const SizedBox(height: 21),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.blue[100]
                            : Colors.blueGrey,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 9),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                      ),
                      icon: const Icon(Icons.save, size: 20),
                      label: Text(
                        guru == null ? "Tambah" : "Simpan",
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
                        if (guru == null) {
                          try {
                            final email =
                                "${nameCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '')}@brawijaya.com";
                            final existingUser = await _firestore
                                .collection('users')
                                .where('email', isEqualTo: email)
                                .get();
                            if (existingUser.docs.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("⚠️ Email sudah terdaftar."),
                                ),
                              );
                              return;
                            }
                            final nipBaru = await _generateNextNIP();
                            final pass = nipBaru;
                            final userCred = await _auth
                                .createUserWithEmailAndPassword(
                                  email: email,
                                  password: pass,
                                );
                            final uid = userCred.user!.uid;
                            await _firestore.collection('users').doc(uid).set({
                              'email': email,
                              'username': email.split('@')[0],
                              'role': 'guru',
                              'created_at': FieldValue.serverTimestamp(),
                            });
                            await _firestore.collection('guru').add({
                              'user_id': uid,
                              'nip': nipBaru,
                              'name': nameCtrl.text,
                              'subject': subject,
                              'email': email,
                              'created_at': FieldValue.serverTimestamp(),
                            });
                            Navigator.pop(context);
                            _loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "✅ Guru & akun berhasil dibuat ($email / $pass)",
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("❌ Gagal memperbarui data: $e"),
                              ),
                            );
                          }
                        } else {
                          try {
                            await _firestore
                                .collection('guru')
                                .doc(guru['id'])
                                .update({
                                  'name': nameCtrl.text,
                                  'subject': subject,
                                });
                            // Update all schedules with this teacher to reflect new subject
                            final schedulesSnap = await _firestore
                                .collection('jadwal')
                                .where('teacher_id', isEqualTo: guru['id'])
                                .get();
                            for (var doc in schedulesSnap.docs) {
                              await doc.reference.update({
                                'subject': subject,
                                'updated_at': FieldValue.serverTimestamp(),
                              });
                            }
                            Navigator.pop(context);
                            _loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Data guru diperbarui"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("❌ Gagal memperbarui data: $e"),
                              ),
                            );
                          }
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

  Future<void> _deleteGuru(Map<String, dynamic> g) async {
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
                Text('Yakin ingin menghapus guru ${g['name']}?'),
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
        final uid = g['user_id'];
        // Delete guru record
        await _firestore.collection('guru').doc(g['id']).delete();
        // Delete user account from Firestore (not Firebase Auth - needs admin)
        if (uid != null) {
          await _firestore.collection('users').doc(uid).delete();
        }
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🗑️ Guru & data akun berhasil dihapus"),
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
              child: Icon(Icons.person, color: Colors.blue[700], size: 46),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelola Data Guru",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Manage teacher data efficiently",
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
    final grouped = _groupBySubject(_guruList);
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
                  : _guruList.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada data guru",
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: grouped.entries.map((entry) {
                        final key = entry.key;
                        final gurus = entry.value;
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
                              "$key (${gurus.length})",
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
                                    Colors.green.withOpacity(0.53),
                                    Colors.green.withOpacity(0.95),
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
                            children: gurus.map((g) {
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
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    "${g['name']} (${g['nip']})",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${g['email']}",
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
                                        onPressed: () => _showForm(g),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteGuru(g),
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