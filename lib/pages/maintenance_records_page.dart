import 'package:flutter/material.dart';

import 'maintenance_form_page.dart';

class MaintenanceRecordsPage extends StatelessWidget {
  const MaintenanceRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bakım Kayıtları')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.car_repair, size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Bakım Kayıtları',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Periyodik bakım ve servis kayıtları bu sayfada listelenecek.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const MaintenanceFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
