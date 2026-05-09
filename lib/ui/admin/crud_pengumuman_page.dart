import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrudPengumumanPage extends StatefulWidget {
  const CrudPengumumanPage({super.key});

  @override
  State<CrudPengumumanPage> createState() => _CrudPengumumanPageState();
}

class _CrudPengumumanPageState extends State<CrudPengumumanPage> {
  final _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final snap = await _fs
        .collection('pengumuman')
        .orderBy('created_at', descending: true)
        .get();
    _items = snap.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();
    setState(() => _loading = false);
  }

  void _showForm([Map<String, dynamic>? data]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data != null) {
      _judulCtrl.text = data['title'] ?? '';
      _isiCtrl.text = data['content'] ?? '';
    } else {
      _judulCtrl.clear();
      _isiCtrl.clear();
    }
    String selectedAudience = data != null
        ? (data['audience'] ?? 'all')
        : 'all';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            insetPadding: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data == null
                        ? "📝 Tambah Pengumuman"
                        : "✍️ Edit Pengumuman",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: isDark ? Colors.white : Colors.blueAccent,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _judulCtrl,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: "Judul Pengumuman",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.blueGrey[800]
                          : Colors.blue[50],
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _isiCtrl,
                    minLines: 3,
                    maxLines: 5,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Tulis isi pengumuman di sini...",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[700],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.blueGrey[800]
                          : Colors.blue[50],
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedAudience,
                    decoration: InputDecoration(
                      labelText: "Target Audience",
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.blueGrey[800]
                          : Colors.blue[50],
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua')),
                      DropdownMenuItem(value: 'guru', child: Text('Guru Saja')),
                      DropdownMenuItem(
                        value: 'siswa',
                        child: Text('Siswa Saja'),
                      ),
                    ],
                    onChanged: (val) => setStateDialog(() {
                      selectedAudience = val ?? 'all';
                    }),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white70
                              : Colors.blueGrey,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        onPressed: () async {
                          if (_judulCtrl.text.isEmpty ||
                              _isiCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Judul dan isi wajib diisi!"),
                              ),
                            );
                            return;
                          }
                          if (data == null) {
                            await _fs.collection('pengumuman').add({
                              'title': _judulCtrl.text,
                              'content': _isiCtrl.text,
                              'audience': selectedAudience,
                              'created_at': FieldValue.serverTimestamp(),
                            });
                          } else {
                            await _fs
                                .collection('pengumuman')
                                .doc(data['id'])
                                .update({
                                  'title': _judulCtrl.text,
                                  'content': _isiCtrl.text,
                                  'audience': selectedAudience,
                                  'updated_at': FieldValue.serverTimestamp(),
                                });
                          }
                          Navigator.pop(context);
                          _loadData();
                        },
                        child: Text(data == null ? "Tambah" : "Simpan"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deletePengumuman(String id) async {
    await _fs.collection('pengumuman').doc(id).delete();
    _loadData();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Pengumuman dihapus")));
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
              child: Icon(
                Icons.campaign_rounded,
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
                  "Kelola Pengumuman",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Info penting and event sekolah",
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
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada pengumuman",
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final a = _items[i];
                        final ts = a['created_at'] as Timestamp?;
                        final date = ts != null ? ts.toDate().toLocal() : null;
                        final prettyDate = date != null
                            ? "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute}"
                            : "-";
                        return InkWell(
                          onTap: () => _showForm(a),
                          borderRadius: BorderRadius.circular(22),
                          splashColor: Colors.redAccent.withOpacity(.15),
                          child: Card(
                            color: isDark ? Colors.blueGrey[900] : Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 21,
                                horizontal: 7,
                              ),
                              child: ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.redAccent.withOpacity(0.53),
                                        Colors.redAccent.withOpacity(0.95),
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: const Icon(
                                    Icons.campaign_rounded,
                                    color: Colors.white,
                                    size: 31,
                                  ),
                                ),
                                title: Text(
                                  a['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 19,
                                    color: isDark
                                        ? Colors.cyan[100]
                                        : Colors.redAccent,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a['content'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13.3,
                                        color: isDark
                                            ? Colors.blueGrey[100]
                                            : Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      prettyDate,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.blueGrey[300]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      "Target: ${a['audience'] == 'all'
                                          ? 'Semua'
                                          : a['audience'] == 'guru'
                                          ? 'Guru'
                                          : 'Siswa'}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.teal[200]
                                            : Colors.teal[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () => _showForm(a),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deletePengumuman(a['id']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _showForm(),
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}