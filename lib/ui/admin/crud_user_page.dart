import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrudUserPage extends StatefulWidget {
  const CrudUserPage({super.key});
  @override
  State<CrudUserPage> createState() => _CrudUserPageState();
}

class _CrudUserPageState extends State<CrudUserPage> {
  final _fs = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  static const String domain = "@Brawijaya.com";

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Color getTextColor(Color bg) =>
      bg.computeLuminance() < 0.5 ? Colors.white : Colors.black;

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
              child: Icon(
                Icons.manage_accounts,
                color: Colors.blue[700],
                size: 46,
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelola Akun",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Manage user accounts efficiently",
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

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final snap = await _fs
        .collection('users')
        .orderBy('created_at', descending: false)
        .get();
    final users = snap.docs.map((d) {
      final m = d.data();
      m['uid'] = d.id;
      return m;
    }).toList();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  Future<void> _addUserDialog() async {
    final nameCtrl = TextEditingController();
    String role = "siswa";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 29, horizontal: 28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tambah Akun Baru",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: isDark
                          ? Colors.blueGrey[800]
                          : Colors.blue[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(
                      labelText: "Role",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(Icons.person_3_rounded),
                      filled: true,
                      fillColor: isDark
                          ? Colors.blueGrey[800]
                          : Colors.blue[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "siswa", child: Text("Siswa")),
                      DropdownMenuItem(value: "guru", child: Text("Guru")),
                    ],
                    onChanged: (val) => setState(() {
                      role = val ?? "siswa";
                    }),
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
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "Simpan",
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                          final userName = nameCtrl.text
                              .trim()
                              .toLowerCase()
                              .replaceAll(RegExp(r'\s+'), '');
                          final email = "$userName$domain";
                          final existedQuery = await _fs
                              .collection('users')
                              .where('email', isEqualTo: email)
                              .limit(1)
                              .get();
                          if (existedQuery.docs.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "⚠️ Email $email sudah terdaftar",
                                ),
                              ),
                            );
                            return;
                          }
                          // generate numeric id (nis/nip) by checking latest document
                          String numberId = await _generateNextNumber(
                            role == 'siswa' ? 'siswa' : 'guru',
                          );
                          final password = numberId;

                          try {
                            // create Firebase Auth user with generated password
                            final cred = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                            final uid = cred.user!.uid;

                            // create user profile in Firestore
                            await _fs.collection('users').doc(uid).set({
                              'email': email,
                              'role': role,
                              'username': userName,
                              'created_at': FieldValue.serverTimestamp(),
                            });

                            if (role == 'siswa') {
                              await _fs.collection('siswa').add({
                                'user_id': uid,
                                'nis': numberId,
                                'name': nameCtrl.text,
                                'kelas': '-',
                                'jurusan': '-',
                                'created_at': FieldValue.serverTimestamp(),
                              });
                            } else {
                              await _fs.collection('guru').add({
                                'user_id': uid,
                                'nip': numberId,
                                'name': nameCtrl.text,
                                'subject': '-',
                                'email': email,
                                'created_at': FieldValue.serverTimestamp(),
                              });
                            }

                            if (!mounted) return;
                            Navigator.pop(context);
                            _loadUsers();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "✅ Akun ${role.toUpperCase()} berhasil dibuat ($email / $password)",
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Gagal menambah user: $e'),
                              ),
                            );
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
      ),
    );
  }

  Future<String> _generateNextNumber(String collection) async {
    try {
      if (collection == 'siswa') {
        final snap = await _fs
            .collection('siswa')
            .orderBy('nis', descending: true)
            .limit(1)
            .get();
        if (snap.docs.isEmpty)
          return DateTime.now().millisecondsSinceEpoch.toString().substring(4);
        final last = snap.docs.first.data()['nis']?.toString() ?? '';
        final lastNum =
            int.tryParse(last) ??
            DateTime.now().millisecondsSinceEpoch % 100000;
        return (lastNum + 1).toString();
      } else {
        final snap = await _fs
            .collection('guru')
            .orderBy('nip', descending: true)
            .limit(1)
            .get();
        if (snap.docs.isEmpty)
          return DateTime.now().millisecondsSinceEpoch.toString().substring(4);
        final last = snap.docs.first.data()['nip']?.toString() ?? '';
        final lastNum =
            int.tryParse(last) ??
            DateTime.now().millisecondsSinceEpoch % 100000;
        return (lastNum + 1).toString();
      }
    } catch (_) {
      return DateTime.now().millisecondsSinceEpoch.toString().substring(4);
    }
  }

  // Role-change helper removed (inline dialogs used in UI)

  // Delete helper removed (inline delete used in UI)

  Future<void> updateRoleAndSync(
    int userId,
    String newRole,
    String name, {
    required String kelas,
    required String jurusan,
    required String subject,
  }) async {
    // Deprecated — role sync now handled via Firestore flows
  }

  Widget _buildUserList(
    String title,
    List<Map<String, dynamic>> users,
    String role,
  ) {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.people_alt_rounded, color: Colors.blueAccent),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.5),
      ),
      children: users.map((u) {
        final roleField = u['role'] as String? ?? 'siswa';
        final isPending = roleField == "siswa_pending";
        final userColor = roleField == "guru"
            ? const Color(0xFFD7C8EF).withOpacity(0.92)
            : roleField == "siswa"
            ? const Color(0xFFD9F3FF).withOpacity(0.92)
            : const Color(0xFFFFEDD6).withOpacity(0.93);
        final textColor = getTextColor(userColor);

        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.4, sigmaY: 3.4),
            child: Card(
              color: userColor,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: isPending
                      ? Colors.orange.withOpacity(0.38)
                      : Colors.grey[300]!,
                  width: isPending ? 2.2 : 1,
                ),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 15,
                ),
                leading: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (isPending
                                ? Colors.orange
                                : roleField == "guru"
                                ? Colors.deepPurple
                                : Colors.blue)
                            .withOpacity(0.53),
                        (isPending
                                ? Colors.orange
                                : roleField == "guru"
                                ? Colors.deepPurple
                                : Colors.blue)
                            .withOpacity(0.95),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isPending
                        ? Icons.hourglass_bottom_rounded
                        : roleField == "guru"
                        ? Icons.school
                        : Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  u['email'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3.5),
                  child: Text(
                    isPending ? "MENUNGGU VERIFIKASI" : "Role: ${roleField}",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isPending
                          ? Colors.deepOrange[700]
                          : textColor.withOpacity(0.80),
                      fontWeight: isPending ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.02,
                    ),
                  ),
                ),
                trailing: isPending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.green[100]!.withOpacity(
                                0.60,
                              ),
                            ),
                            child: const Text(
                              "YES",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                // find user doc by email
                                final q = await _fs
                                    .collection('users')
                                    .where('email', isEqualTo: u['email'])
                                    .limit(1)
                                    .get();
                                if (q.docs.isEmpty) throw 'User doc not found';
                                final uid = q.docs.first.id;
                                await _fs.collection('users').doc(uid).update({
                                  'role': 'siswa',
                                });
                                // create siswa record
                                final nis = await _generateNextNumber('siswa');
                                await _fs.collection('siswa').add({
                                  'user_id': uid,
                                  'nis': nis,
                                  'name': (u['email'] ?? '')
                                      .toString()
                                      .split('@')
                                      .first,
                                  'kelas': '-',
                                  'jurusan': '-',
                                  'created_at': FieldValue.serverTimestamp(),
                                });
                                _loadUsers();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          color: Colors.greenAccent,
                                          size: 21,
                                        ),
                                        SizedBox(width: 7),
                                        Text(
                                          "Aktivasi berhasil: user ini jadi Siswa",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.black87,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal aktivasi: $e')),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 5),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red[700],
                              backgroundColor: Colors.red[100]!.withOpacity(
                                0.45,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "NO",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final q = await _fs
                                    .collection('users')
                                    .where('email', isEqualTo: u['email'])
                                    .limit(1)
                                    .get();
                                if (q.docs.isNotEmpty) {
                                  final uid = q.docs.first.id;
                                  await _fs
                                      .collection('users')
                                      .doc(uid)
                                      .delete();
                                }
                                _loadUsers();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_forever,
                                          color: Colors.redAccent,
                                          size: 21,
                                        ),
                                        SizedBox(width: 7),
                                        Text(
                                          "Akun pending telah DIHAPUS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.black87,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal hapus: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                              size: 22,
                            ),
                            tooltip: "Edit Role",
                            onPressed: () async {
                              // open simple role-change dialog (email/username not editable)
                              final q = await _fs
                                  .collection('users')
                                  .where('email', isEqualTo: u['email'])
                                  .limit(1)
                                  .get();
                              if (q.docs.isEmpty) return;
                              final doc = q.docs.first;
                              String newRole = (u['role'] ?? 'siswa') as String;
                              final isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              await showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  backgroundColor: isDark
                                      ? Colors.blueGrey[900]
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 29,
                                      horizontal: 28,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Ubah Role",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 19,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          DropdownButtonFormField<String>(
                                            value: newRole,
                                            decoration: InputDecoration(
                                              labelText: "Role",
                                              labelStyle: TextStyle(
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.blueGrey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.person_3_rounded,
                                              ),
                                              filled: true,
                                              fillColor: isDark
                                                  ? Colors.blueGrey[800]
                                                  : Colors.blue[50],
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'siswa',
                                                child: Text('Siswa'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'guru',
                                                child: Text('Guru'),
                                              ),
                                            ],
                                            onChanged: (v) =>
                                                newRole = v ?? newRole,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: isDark
                                                      ? Colors.cyan[200]
                                                      : Colors.blueGrey,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text(
                                                  "Batal",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 13),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blueAccent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          13,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 11,
                                                        horizontal: 20,
                                                      ),
                                                ),
                                                icon: const Icon(Icons.save),
                                                label: const Text(
                                                  "Simpan",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  try {
                                                    await _fs
                                                        .collection('users')
                                                        .doc(doc.id)
                                                        .update({
                                                          'role': newRole,
                                                        });
                                                    if (newRole == 'siswa') {
                                                      // create siswa if not exists
                                                      final exists = await _fs
                                                          .collection('siswa')
                                                          .where(
                                                            'user_id',
                                                            isEqualTo: doc.id,
                                                          )
                                                          .limit(1)
                                                          .get();
                                                      if (exists.docs.isEmpty) {
                                                        final nis =
                                                            await _generateNextNumber(
                                                              'siswa',
                                                            );
                                                        await _fs
                                                            .collection('siswa')
                                                            .add({
                                                              'user_id': doc.id,
                                                              'nis': nis,
                                                              'name':
                                                                  (u['email'] ??
                                                                          '')
                                                                      .toString()
                                                                      .split(
                                                                        '@',
                                                                      )
                                                                      .first,
                                                              'kelas': '-',
                                                              'jurusan': '-',
                                                              'created_at':
                                                                  FieldValue.serverTimestamp(),
                                                            });
                                                      }
                                                      // remove guru records
                                                      final g = await _fs
                                                          .collection('guru')
                                                          .where(
                                                            'user_id',
                                                            isEqualTo: doc.id,
                                                          )
                                                          .get();
                                                      for (final d in g.docs)
                                                        await d.reference
                                                            .delete();
                                                    } else if (newRole ==
                                                        'guru') {
                                                      final exists = await _fs
                                                          .collection('guru')
                                                          .where(
                                                            'user_id',
                                                            isEqualTo: doc.id,
                                                          )
                                                          .limit(1)
                                                          .get();
                                                      if (exists.docs.isEmpty) {
                                                        final nip =
                                                            await _generateNextNumber(
                                                              'guru',
                                                            );
                                                        await _fs
                                                            .collection('guru')
                                                            .add({
                                                              'user_id': doc.id,
                                                              'nip': nip,
                                                              'name':
                                                                  (u['email'] ??
                                                                          '')
                                                                      .toString()
                                                                      .split(
                                                                        '@',
                                                                      )
                                                                      .first,
                                                              'subject': '-',
                                                              'email':
                                                                  u['email'] ??
                                                                  '',
                                                              'created_at':
                                                                  FieldValue.serverTimestamp(),
                                                            });
                                                      }
                                                      final s = await _fs
                                                          .collection('siswa')
                                                          .where(
                                                            'user_id',
                                                            isEqualTo: doc.id,
                                                          )
                                                          .get();
                                                      for (final d in s.docs)
                                                        await d.reference
                                                            .delete();
                                                    }
                                                    Navigator.pop(context);
                                                    _loadUsers();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          '✅ Role berhasil diperbarui',
                                                        ),
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Gagal update role: $e',
                                                        ),
                                                      ),
                                                    );
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
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 22,
                            ),
                            tooltip: "Hapus User",
                            onPressed: () async {
                              final isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  backgroundColor: isDark
                                      ? Colors.blueGrey[900]
                                      : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 29,
                                      horizontal: 28,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          Text(
                                            'Yakin ingin menghapus user ${u['email']} dari Firestore? (catatan: akun Firebase Auth mungkin masih ada)',
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: isDark
                                                      ? Colors.cyan[200]
                                                      : Colors.blueGrey,
                                                ),
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text(
                                                  "Batal",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 13),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          13,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 11,
                                                        horizontal: 20,
                                                      ),
                                                ),
                                                icon: const Icon(Icons.delete),
                                                label: const Text(
                                                  "Hapus",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
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
                              if (confirm == true) {
                                try {
                                  final q = await _fs
                                      .collection('users')
                                      .where('email', isEqualTo: u['email'])
                                      .limit(1)
                                      .get();
                                  if (q.docs.isNotEmpty) {
                                    final uid = q.docs.first.id;
                                    await _fs
                                        .collection('users')
                                        .doc(uid)
                                        .delete();
                                    final s = await _fs
                                        .collection('siswa')
                                        .where('user_id', isEqualTo: uid)
                                        .get();
                                    for (final d in s.docs)
                                      await d.reference.delete();
                                    final g = await _fs
                                        .collection('guru')
                                        .where('user_id', isEqualTo: uid)
                                        .get();
                                    for (final d in g.docs)
                                      await d.reference.delete();
                                  }
                                  _loadUsers();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "🗑️ User & data akun berhasil dihapus",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal hapus: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final siswaUsers = _users.where((u) {
      final r = (u['role'] ?? '') as String;
      return r == 'siswa' || r == 'siswa_pending';
    }).toList();
    final guruUsers = _users.where((u) => (u['role'] ?? '') == 'guru').toList();
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
          onPressed: _addUserDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.person_add, color: Colors.white),
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
                  : _users.isEmpty
                  ? const Center(child: Text("Belum ada user terdaftar"))
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: [
                        _buildUserList("Akun Siswa", siswaUsers, "siswa"),
                        _buildUserList("Akun Guru", guruUsers, "guru"),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}