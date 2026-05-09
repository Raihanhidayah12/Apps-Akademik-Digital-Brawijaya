import 'package:flutter/material.dart';
import '../../data/local/dao/student_dao.dart';
import '../../models/student.dart';

class CrudSiswaPage extends StatefulWidget {
  const CrudSiswaPage({super.key});

  @override
  State<CrudSiswaPage> createState() => _CrudSiswaPageState();
}

class _CrudSiswaPageState extends State<CrudSiswaPage> {
  final _dao = StudentDao();
  List<Student> siswaList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await _dao.getAll();
    setState(() {
      siswaList = data;
      _loading = false;
    });
  }

  void _showForm([Student? student]) {
    final nisCtrl = TextEditingController(text: student?.nis ?? "");
    final nameCtrl = TextEditingController(text: student?.name ?? "");
    final kelasCtrl = TextEditingController(text: student?.kelas ?? "");
    final jurusanCtrl = TextEditingController(text: student?.jurusan ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(student == null ? "Tambah Siswa" : "Edit Siswa"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nisCtrl,
                decoration: const InputDecoration(
                  labelText: "NIS",
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              TextField(
                controller: kelasCtrl,
                decoration: const InputDecoration(
                  labelText: "Kelas",
                  prefixIcon: Icon(Icons.class_),
                ),
              ),
              TextField(
                controller: jurusanCtrl,
                decoration: const InputDecoration(
                  labelText: "Jurusan",
                  prefixIcon: Icon(Icons.book),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Simpan"),
            onPressed: () async {
              if (nisCtrl.text.isEmpty ||
                  nameCtrl.text.isEmpty ||
                  kelasCtrl.text.isEmpty ||
                  jurusanCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("⚠️ Semua field wajib diisi")),
                );
                return;
              }

              if (student == null) {
                await _dao.insert(Student(
                  id: null,
                  userId: 0, // default sementara, nanti bisa diisi sesuai user
                  nis: nisCtrl.text,
                  name: nameCtrl.text,
                  kelas: kelasCtrl.text,
                  jurusan: jurusanCtrl.text,
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Siswa berhasil ditambahkan")),
                );
              } else {
                await _dao.update(Student(
                  id: student.id,
                  userId: student.userId,
                  nis: nisCtrl.text,
                  name: nameCtrl.text,
                  kelas: kelasCtrl.text,
                  jurusan: jurusanCtrl.text,
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Data siswa diperbarui")),
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
    );
  }

  Future<void> _deleteStudent(int id) async {
    await _dao.delete(id);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Siswa berhasil dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Data Siswa")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : siswaList.isEmpty
              ? const Center(child: Text("Belum ada data siswa"))
              : ListView.builder(
                  itemCount: siswaList.length,
                  itemBuilder: (_, i) {
                    final s = siswaList[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.school, color: Colors.blue),
                        title: Text("${s.name} (${s.nis})"),
                        subtitle: Text("${s.kelas} - ${s.jurusan}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showForm(s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: s.id == null
                                  ? null
                                  : () => _deleteStudent(s.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
