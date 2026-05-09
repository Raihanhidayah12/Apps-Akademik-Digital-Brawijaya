import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../pengumuman_detail_page.dart';

class PengumumanSiswaPage extends StatelessWidget {
  const PengumumanSiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.loading)
            return const Center(child: CircularProgressIndicator());
          final items = provider.items;
          if (items.isEmpty)
            return const Center(child: Text('Belum ada pengumuman'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final a = items[index];
              return Card(
                child: ListTile(
                  title: Text(a['title'] ?? ''),
                  subtitle: Text(a['content'] ?? ''),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PengumumanDetailPage(announcement: a),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}