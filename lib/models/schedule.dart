class Schedule {
  final int? id;
  final String day;
  final String time;
  final String subject;
  final int teacherId;
  final String kelas;
  final String jurusan;

  Schedule({
    this.id,
    required this.day,
    required this.time,
    required this.subject,
    required this.teacherId,
    required this.kelas,
    required this.jurusan, required String grade,
  });

  factory Schedule.fromMap(Map<String, Object?> map) => Schedule(
    id: map['id'] as int?,
    day: map['day'] as String,
    time: map['time'] as String,
    subject: map['subject'] as String,
    teacherId: map['teacher_id'] as int,
    kelas: map['kelas'] as String,
    jurusan: map['jurusan'] as String, grade: '',
  );

  get grade => null;

  Map<String, Object?> toMap() => {
    'id': id,
    'day': day,
    'time': time,
    'subject': subject,
    'teacher_id': teacherId,
    'kelas': kelas,
    'jurusan': jurusan,
  };
}
