import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/vehicle.dart';
import 'expense_records_page.dart';
import 'maintenance_records_page.dart';
import 'vehicle_form_page.dart';

class VehicleDetailPage extends StatefulWidget {
  const VehicleDetailPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  late Vehicle _vehicle;
  bool _hasChanges = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  Future<void> _editVehicle() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => VehicleFormPage(vehicle: _vehicle),
      ),
    );

    if (!mounted || updated != true || _vehicle.id == null) {
      return;
    }

    try {
      final freshVehicle = await DatabaseHelper.instance.getVehicleById(
        _vehicle.id!,
      );

      if (!mounted) {
        return;
      }

      if (freshVehicle != null) {
        setState(() {
          _vehicle = freshVehicle;
          _hasChanges = true;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('Araç bilgileri güncellenirken hata oluştu');
    }
  }

  Future<void> _confirmDelete() async {
    if (_vehicle.id == null || _isDeleting) {
      _showMessage('Araç kaydı bulunamadı');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Araç silinsin mi?'),
          content: const Text(
            'Bu araca bağlı bakım ve masraf kayıtları da silinebilir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await _deleteVehicle();
  }

  Future<void> _deleteVehicle() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await DatabaseHelper.instance.deleteVehicle(_vehicle.id!);

      if (!mounted) {
        return;
      }

      _showMessage('Araç silindi');
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDeleting = false;
      });
      _showMessage('Silme sırasında hata oluştu');
    }
  }

  void _openMaintenanceRecords() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            MaintenanceRecordsPage(initialVehicleId: _vehicle.id),
      ),
    );
  }

  void _openExpenseRecords() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ExpenseRecordsPage(initialVehicleId: _vehicle.id),
      ),
    );
  }

  void _closePage() {
    Navigator.pop(context, _hasChanges);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatCreatedAt(String value) {
    late final DateTime dateTime;

    try {
      dateTime = DateTime.parse(value).toLocal();
    } catch (_) {
      return value;
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _closePage();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Araç Detayı'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closePage,
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_vehicle.brand} ${_vehicle.model}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _vehicle.plate,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _DetailTile(
                icon: Icons.calendar_month,
                title: 'Yıl',
                value: _vehicle.year.toString(),
              ),
              _DetailTile(
                icon: Icons.speed,
                title: 'Mevcut KM',
                value: '${_vehicle.currentKm} KM',
              ),
              _DetailTile(
                icon: Icons.local_gas_station,
                title: 'Yakıt Türü',
                value: _vehicle.fuelType,
              ),
              _DetailTile(
                icon: Icons.access_time,
                title: 'Oluşturulma Tarihi',
                value: _formatCreatedAt(_vehicle.createdAt),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _vehicle.id == null ? null : _openMaintenanceRecords,
                icon: const Icon(Icons.car_repair),
                label: const Text('Bakım Kayıtları'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _vehicle.id == null ? null : _openExpenseRecords,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Masraf Kayıtları'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _isDeleting ? null : _editVehicle,
                icon: const Icon(Icons.edit),
                label: const Text('Düzenle'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isDeleting ? null : _confirmDelete,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(_isDeleting ? 'Siliniyor' : 'Sil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
