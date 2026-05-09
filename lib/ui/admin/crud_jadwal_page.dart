import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrudJadwalPage extends StatefulWidget {
  const CrudJadwalPage({super.key});
  @override
  State<CrudJadwalPage> createState() => _CrudJadwalPageState();
}

class _CrudJadwalPageState extends State<CrudJadwalPage> {
  final _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _teachers = [];
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  final List<String> _times = [
    '07.00-09.00',
    '09.00-11.00',
    '13.00-15.00',
    '15.00-17.00',
  ];
  final List<String> _kelasList = ['X', 'XI', 'XII'];
  final List<String> _jurusanList = ['RPL', 'TKJ', 'MM', 'DKV'];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final tSnap = await _fs.collection('guru').get();
    _teachers = tSnap.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();

    final sSnap = await _fs.collection('jadwal').orderBy('day').get();
    _schedules = sSnap.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();
    setState(() => _loading = false);
  }

  void _showForm([Map<String, dynamic>? sched]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayController = TextEditingController(
      text: sched != null ? sched['day'] ?? _days.first : _days.first,
    );
    String selectedTime = sched != null
        ? (sched['time'] ?? _times.first)
        : _times.first;
    String selectedKelas = sched != null
        ? (sched['kelas'] ?? _kelasList.first)
        : _kelasList.first;
    String selectedJurusan = sched != null
        ? (sched['jurusan'] ?? _jurusanList.first)
        : _jurusanList.first;
    Map<String, dynamic>? selectedTeacher = sched != null
        ? _teachers.firstWhere(
            (t) => t['id'] == sched['teacher_id'],
            orElse: () => _teachers.isNotEmpty ? _teachers.first : {},
          )
        : (_teachers.isNotEmpty ? _teachers.first : null);
    // *** Gunakan ValueNotifier untuk mapel biar auto-rebuild ***
    final ValueNotifier<String> selectedMapel = ValueNotifier<String>(
      selectedTeacher?['subject'] ?? "-",
    );

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          insetPadding: const EdgeInsets.all(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sched == null ? '➕ Tambah Jadwal' : '✏ Edit Jadwal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue[700],
                      letterSpacing: .7,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: dayController.text,
                    icon: const Icon(Icons.arrow_drop_down),
                    dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Hari',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: _days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) dayController.text = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<String>(
                    value: selectedTime,
                    decoration: InputDecoration(
                      labelText: 'Jam',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.access_time_rounded),
                    dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                    items: _times
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) selectedTime = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<String>(
                    value: selectedKelas,
                    decoration: InputDecoration(
                      labelText: "Kelas",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: _kelasList
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) selectedKelas = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<String>(
                    value: selectedJurusan,
                    decoration: InputDecoration(
                      labelText: "Jurusan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: _jurusanList
                        .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) selectedJurusan = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedTeacher,
                    decoration: InputDecoration(
                      labelText: "Guru",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.person),
                    dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                    items: _teachers
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t['name'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) {
                        selectedTeacher = val;
                        selectedMapel.value = val['subject'] ?? '-';
                      }
                    }),
                  ),
                  const SizedBox(height: 13),

                  // Gunakan ValueListenableBuilder untuk update mapel instan!
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder(
                      valueListenable: selectedMapel,
                      builder: (context, value, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mata Pelajaran (otomatis dari guru)",
                            style: TextStyle(
                              color: isDark ? Colors.teal[50] : Colors.indigo,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            value,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.teal[100]
                                  : Colors.indigo[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                              letterSpacing: .1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
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
                          'Batal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 13,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        onPressed: () async {
                          if (selectedTeacher == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih guru dulu')),
                            );
                            return;
                          }
                          if (dayController.text.isEmpty ||
                              selectedTime.isEmpty ||
                              selectedKelas.isEmpty ||
                              selectedJurusan.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lengkapi semua data'),
                              ),
                            );
                            return;
                          }
                          if (selectedTeacher == null) return;
                          if (sched == null) {
                            await _fs.collection('jadwal').add({
                              'day': dayController.text,
                              'time': selectedTime,
                              'teacher_id': selectedTeacher!['id'],
                              'subject': selectedMapel.value,
                              'kelas': selectedKelas,
                              'jurusan': selectedJurusan,
                              'created_at': FieldValue.serverTimestamp(),
                            });
                          } else {
                            await _fs
                                .collection('jadwal')
                                .doc(sched['id'])
                                .update({
                                  'day': dayController.text,
                                  'time': selectedTime,
                                  'teacher_id': selectedTeacher!['id'],
                                  'subject': selectedMapel.value,
                                  'kelas': selectedKelas,
                                  'jurusan': selectedJurusan,
                                  'updated_at': FieldValue.serverTimestamp(),
                                });
                          }
                          Navigator.pop(context);
                          _loadData();
                        },
                        child: Text(sched == null ? 'Tambah' : 'Simpan'),
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

  Future<void> _deleteSchedule(String id) async {
    await _fs.collection('jadwal').doc(id).delete();
    _loadData();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jadwal berhasil dihapus')));
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
              child: Icon(Icons.schedule, color: Colors.blue[700], size: 46),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelola Jadwal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Manage schedule data efficiently",
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

  Map<String, List<Map<String, dynamic>>> _groupByDay(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var s in data) {
      final key = s['day'] ?? 'Unknown';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(s);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = _groupByDay(_schedules);

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
                  : _schedules.isEmpty
                  ? const Center(child: Text("Belum ada data jadwal"))
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: grouped.entries.map((entry) {
                        final day = entry.key;
                        final schedules = entry.value;
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
                              "Hari $day (${schedules.length} jadwal)",
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
                                    Colors.orange.withOpacity(0.53),
                                    Colors.orange.withOpacity(0.95),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.calendar_today,
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
                            children: schedules.map((sched) {
                              final teacher = _teachers.firstWhere(
                                (t) => t['id'] == sched['teacher_id'],
                                orElse: () => {},
                              );
                              final teacherName = teacher['name'] ?? '-';
                              final subject = sched['subject'] ?? '-';
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
                                      Icons.schedule,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    "${sched['time']} - ${sched['kelas']} ${sched['jurusan']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Guru: $teacherName | Mapel: $subject",
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
                                        onPressed: () => _showForm(sched),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteSchedule(sched['id']),
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