import 'package:flutter/material.dart';

import '../widgets/app_summary_card.dart';
import '../widgets/section_title.dart';
import 'about_page.dart';
import 'expense_records_page.dart';
import 'maintenance_records_page.dart';
import 'vehicles_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OtoBakım Defteri'),
        actions: [
          IconButton(
            tooltip: 'Hakkında',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Özet'),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 640 ? 1 : 3;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: crossAxisCount == 1 ? 3.2 : 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      AppSummaryCard(
                        title: 'Araçlar',
                        value: '0',
                        icon: Icons.directions_car,
                      ),
                      AppSummaryCard(
                        title: 'Bakımlar',
                        value: '0',
                        icon: Icons.build,
                      ),
                      AppSummaryCard(
                        title: 'Masraflar',
                        value: '0 TL',
                        icon: Icons.payments,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const SectionTitle('Menü'),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'Araçlarım',
                description: 'Araç bilgilerini görüntüle ve yeni araç ekle.',
                icon: Icons.garage,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const VehiclesPage(),
                    ),
                  );
                },
              ),
              _MenuCard(
                title: 'Bakım Kayıtları',
                description: 'Bakım geçmişi için kayıt ekranını aç.',
                icon: Icons.car_repair,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const MaintenanceRecordsPage(),
                    ),
                  );
                },
              ),
              _MenuCard(
                title: 'Masraf Kayıtları',
                description: 'Araç masrafları için kayıt ekranını aç.',
                icon: Icons.receipt_long,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ExpenseRecordsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 34),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
