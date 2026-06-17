import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/maintenance_record.dart';
import '../models/vehicle.dart';

class MaintenanceFormPage extends StatefulWidget {
  const MaintenanceFormPage({super.key, required this.vehicle, this.record});

  final Vehicle vehicle;
  final MaintenanceRecord? record;

  @override
  State<MaintenanceFormPage> createState() => _MaintenanceFormPageState();
}

class _MaintenanceFormPageState extends State<MaintenanceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _kmController = TextEditingController();
  final _costController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  bool get _isEditMode => widget.record != null;

  @override
  void initState() {
    super.initState();

    final record = widget.record;
    if (record != null) {
      _titleController.text = record.title;
      _descriptionController.text = record.description ?? '';
      _kmController.text = record.km.toString();
      _costController.text = record.cost.toStringAsFixed(2);
      _selectedDate = DateTime.tryParse(record.date)?.toLocal();
    } else {
      _kmController.text = widget.vehicle.currentKm.toString();
      _selectedDate = DateTime.now().toLocal();
    }

    _dateController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _kmController.dispose();
    _costController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now().toLocal();
    final initialDate = _selectedDate ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
      _dateController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _saveRecord() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (widget.vehicle.id == null) {
      _showMessage('Bakım kaydı için araç seçilmeli');
      return;
    }

    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      _showMessage('Tarih seçilmeli');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final currentRecord = widget.record;
    final record = MaintenanceRecord(
      id: currentRecord?.id,
      vehicleId: currentRecord?.vehicleId ?? widget.vehicle.id!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      km: int.parse(_kmController.text.trim()),
      date: selectedDate.toIso8601String(),
      cost: double.parse(_normalizeDecimal(_costController.text.trim())),
      createdAt:
          currentRecord?.createdAt ??
          DateTime.now().toLocal().toIso8601String(),
    );

    try {
      if (_isEditMode) {
        await DatabaseHelper.instance.updateMaintenanceRecord(record);
      } else {
        await DatabaseHelper.instance.insertMaintenanceRecord(record);
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        _isEditMode ? 'Bakım kaydı güncellendi' : 'Bakım kaydı eklendi',
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });
      _showMessage('İşlem sırasında hata oluştu');
    }
  }

  String? _requiredTextValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş olamaz';
    }

    return null;
  }

  String? _kmValidator(String? value) {
    final requiredError = _requiredTextValidator(value, 'Kilometre');
    if (requiredError != null) {
      return requiredError;
    }

    final km = int.tryParse(value!.trim());
    if (km == null) {
      return 'Kilometre sayı olmalı';
    }

    if (km < 0) {
      return 'Kilometre negatif olamaz';
    }

    return null;
  }

  String? _costValidator(String? value) {
    final requiredError = _requiredTextValidator(value, 'Ücret');
    if (requiredError != null) {
      return requiredError;
    }

    final cost = double.tryParse(_normalizeDecimal(value!.trim()));
    if (cost == null) {
      return 'Ücret sayı olmalı';
    }

    if (cost < 0) {
      return 'Ücret negatif olamaz';
    }

    return null;
  }

  String? _dateValidator(String? value) {
    if (_selectedDate == null) {
      return 'Tarih seçilmeli';
    }

    return null;
  }

  String _normalizeDecimal(String value) {
    return value.replaceAll(',', '.');
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Bakım Düzenle' : 'Bakım Ekle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _VehicleInfoCard(vehicle: widget.vehicle),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Bakım Başlığı',
                    prefixIcon: Icon(Icons.build),
                  ),
                  validator: (value) =>
                      _requiredTextValidator(value, 'Bakım başlığı'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _kmController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Kilometre',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  validator: _kmValidator,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  readOnly: true,
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Tarih',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: _isSaving ? null : _pickDate,
                  validator: _dateValidator,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Ücret',
                    prefixIcon: Icon(Icons.payments),
                    suffixText: 'TL',
                  ),
                  validator: _costValidator,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveRecord,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Kaydediliyor' : 'Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  const _VehicleInfoCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.directions_car, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${vehicle.brand} ${vehicle.model} - ${vehicle.plate}',
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
