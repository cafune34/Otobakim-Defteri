import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';
import 'vehicle_form_page.dart';

class VehiclesPage extends StatelessWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Araçlarım')),
      body: const EmptyState(
        icon: Icons.directions_car_outlined,
        title: 'Henüz araç eklenmedi',
        message: 'Araç kayıtları Sprint 2 ile SQLite veritabanına bağlanacak.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const VehicleFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
