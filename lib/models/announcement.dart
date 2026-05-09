class Announcement {
  final int? id;
  final String title;
  final String content;
  final String createdAt;

  Announcement({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
        id: map['id'],
        title: map['title'] ?? '',
        content: map['content'] ?? '',
        createdAt: map['created_at'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt,
      };
}
