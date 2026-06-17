import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense_record.dart';
import '../models/vehicle.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_card.dart';
import 'expense_form_page.dart';

class ExpenseRecordsPage extends StatefulWidget {
  const ExpenseRecordsPage({super.key, this.initialVehicleId});

  final int? initialVehicleId;

  @override
  State<ExpenseRecordsPage> createState() => _ExpenseRecordsPageState();
}

class _ExpenseRecordsPageState extends State<ExpenseRecordsPage> {
  List<Vehicle> _vehicles = [];
  List<ExpenseRecord> _records = [];
  int? _selectedVehicleId;
  bool _isLoadingVehicles = true;
  bool _isLoadingRecords = false;
  double _totalAmount = 0.0;

  Vehicle? get _selectedVehicle {
    for (final vehicle in _vehicles) {
      if (vehicle.id == _selectedVehicleId) {
        return vehicle;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
    });

    try {
      final vehicles = await DatabaseHelper.instance.getVehicles();

      if (!mounted) {
        return;
      }

      final selectedVehicleId = _resolveSelectedVehicleId(vehicles);

      setState(() {
        _vehicles = vehicles;
        _selectedVehicleId = selectedVehicleId;
        _isLoadingVehicles = false;
      });

      if (selectedVehicleId != null) {
        await _loadRecords();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingVehicles = false;
      });
      _showMessage('Araçlar yüklenirken hata oluştu');
    }
  }

  int? _resolveSelectedVehicleId(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) {
      return null;
    }

    final initialVehicleId = widget.initialVehicleId;
    if (initialVehicleId != null &&
        vehicles.any((vehicle) => vehicle.id == initialVehicleId)) {
      return initialVehicleId;
    }

    return vehicles.first.id;
  }

  Future<void> _loadRecords() async {
    final selectedVehicleId = _selectedVehicleId;
    if (selectedVehicleId == null) {
      return;
    }

    setState(() {
      _isLoadingRecords = true;
    });

    try {
      final records = await DatabaseHelper.instance
          .getExpenseRecordsByVehicleId(selectedVehicleId);
      final totalAmount = await DatabaseHelper.instance
          .getTotalExpenseAmountByVehicleId(selectedVehicleId);

      if (!mounted) {
        return;
      }

      setState(() {
        _records = records;
        _totalAmount = totalAmount;
        _isLoadingRecords = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingRecords = false;
      });
      _showMessage('Masraf kayıtları yüklenirken hata oluştu');
    }
  }

  Future<void> _openExpenseForm({ExpenseRecord? record}) async {
    final selectedVehicle = _selectedVehicle;
    if (selectedVehicle == null || selectedVehicle.id == null) {
      _showMessage('Masraf kaydı için araç seçilmeli');
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) =>
            ExpenseFormPage(vehicle: selectedVehicle, record: record),
      ),
    );

    if (!mounted) {
      return;
    }

    if (saved == true) {
      await _loadRecords();
    }
  }

  Future<void> _confirmDelete(ExpenseRecord record) async {
    if (record.id == null) {
      _showMessage('Masraf kaydı bulunamadı');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masraf kaydı silinsin mi?'),
          content: const Text('Bu işlem geri alınamaz.'),
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

    await _deleteRecord(record.id!);
  }

  Future<void> _deleteRecord(int id) async {
    try {
      await DatabaseHelper.instance.deleteExpenseRecord(id);

      if (!mounted) {
        return;
      }

      _showMessage('Masraf kaydı silindi');
      await _loadRecords();
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('Silme sırasında hata oluştu');
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
      appBar: AppBar(title: const Text('Masraf Kayıtları')),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _vehicles.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _isLoadingRecords ? null : () => _openExpenseForm(),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingVehicles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vehicles.isEmpty) {
      return const EmptyState(
        icon: Icons.directions_car_outlined,
        title: 'Henüz araç eklenmedi',
        message: 'Masraf kaydı eklemek için önce bir araç eklemelisin.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selectedVehicleId,
          decoration: const InputDecoration(
            labelText: 'Araç',
            prefixIcon: Icon(Icons.directions_car),
          ),
          items: _vehicles
              .where((vehicle) => vehicle.id != null)
              .map(
                (vehicle) => DropdownMenuItem<int>(
                  value: vehicle.id,
                  child: Text(
                    '${vehicle.brand} ${vehicle.model} - ${vehicle.plate}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _isLoadingRecords
              ? null
              : (vehicleId) async {
                  setState(() {
                    _selectedVehicleId = vehicleId;
                  });
                  await _loadRecords();
                },
        ),
        const SizedBox(height: 12),
        _TotalAmountCard(totalAmount: _totalAmount),
        const SizedBox(height: 16),
        if (_isLoadingRecords)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_records.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long,
            title: 'Henüz masraf kaydı yok',
            message:
                'Bu araç için ilk masraf kaydını eklemek için + butonunu kullan.',
          )
        else
          ..._records.map(
            (record) => ExpenseCard(
              record: record,
              onEdit: () => _openExpenseForm(record: record),
              onDelete: () => _confirmDelete(record),
            ),
          ),
      ],
    );
  }
}

class _TotalAmountCard extends StatelessWidget {
  const _TotalAmountCard({required this.totalAmount});

  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.payments, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Toplam Masraf: ${totalAmount.toStringAsFixed(2)} TL',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
