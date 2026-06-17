import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _AboutTile(
              icon: Icons.assignment,
              title: 'Proje Adı',
              value: 'OtoBakım Defteri: Araç Bakım ve Masraf Takip Uygulaması',
            ),
            _AboutTile(
              icon: Icons.school,
              title: 'Ders Adı',
              value: 'EFC304 Mobil Uygulama Tasarımı ve Geliştirme',
            ),
            _AboutTile(
              icon: Icons.code,
              title: 'Kullanılan Teknolojiler',
              value: 'Dart, Flutter, SQLite',
            ),
            _AboutTile(
              icon: Icons.info_outline,
              title: 'Açıklama',
              value:
                  'Araç bakım ve masraf kayıtlarını takip etmek için geliştirilen final projesi.',
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
