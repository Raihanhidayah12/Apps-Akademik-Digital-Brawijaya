class Grade {
  final int id;
  final int studentId;
  final String subject;
  final double tugas;
  final double uts;
  final double uas;
  final double finalScore;
  final String grade;

  Grade({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.tugas,
    required this.uts,
    required this.uas,
    required this.finalScore,
    required this.grade,
  });

  factory Grade.fromMap(Map<String, dynamic> map) => Grade(
        id: map['id'],
        studentId: map['student_id'],
        subject: map['subject'],
        tugas: map['tugas'] ?? 0.0,
        uts: map['uts'] ?? 0.0,
        uas: map['uas'] ?? 0.0,
        finalScore: map['final_score'] ?? 0.0,
        grade: map['grade'] ?? "-",
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'student_id': studentId,
        'subject': subject,
        'tugas': tugas,
        'uts': uts,
        'uas': uas,
        'final_score': finalScore,
        'grade': grade,
      };
}
