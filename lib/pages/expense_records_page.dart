import 'package:flutter/material.dart';

import 'expense_form_page.dart';

class ExpenseRecordsPage extends StatelessWidget {
  const ExpenseRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Masraf Kayıtları')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Masraf Kayıtları',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yakıt, parça ve servis masrafları bu sayfada listelenecek.',
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
              builder: (context) => const ExpenseFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
