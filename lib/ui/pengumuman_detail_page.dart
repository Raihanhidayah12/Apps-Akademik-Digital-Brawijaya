import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PengumumanDetailPage extends StatelessWidget {
  final Map<String, dynamic>? announcement;

  const PengumumanDetailPage({Key? key, this.announcement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = announcement?['title'] ?? 'Pengumuman';
    final content = announcement?['content'] ?? '';
    String dateText = '';
    if (announcement?['created_at'] != null) {
      try {
        final ts = announcement!['created_at'] as Timestamp;
        dateText = DateTime.fromMillisecondsSinceEpoch(
          ts.millisecondsSinceEpoch,
        ).toString().split(' ')[0];
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.cyan[100] : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (dateText.isNotEmpty)
              Text(
                'Dibuat: $dateText',
                style: TextStyle(
                  color: isDark ? Colors.blueGrey[300] : Colors.grey[700],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}