import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/vehicle.dart';
import '../widgets/empty_state.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_detail_page.dart';
import 'vehicle_form_page.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicles = await DatabaseHelper.instance.getVehicles();

      if (!mounted) {
        return;
      }

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      _showMessage('Araçlar yüklenirken hata oluştu');
    }
  }

  Future<void> _openVehicleForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (context) => const VehicleFormPage()),
    );

    if (!mounted) {
      return;
    }

    if (saved == true) {
      await _loadVehicles();
    }
  }

  Future<void> _openVehicleDetail(Vehicle vehicle) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => VehicleDetailPage(vehicle: vehicle),
      ),
    );

    if (!mounted) {
      return;
    }

    if (changed == true) {
      await _loadVehicles();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Araçlarım')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openVehicleForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vehicles.isEmpty) {
      return const EmptyState(
        icon: Icons.directions_car_outlined,
        title: 'Henüz araç eklenmedi',
        message: 'İlk aracını eklemek için sağ alttaki + butonunu kullan.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];

        return VehicleCard(
          vehicle: vehicle,
          onTap: () => _openVehicleDetail(vehicle),
        );
      },
    );
  }
}
