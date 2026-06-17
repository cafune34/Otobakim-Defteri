import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense_record.dart';
import '../models/vehicle.dart';

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({super.key, required this.vehicle, this.record});

  final Vehicle vehicle;
  final ExpenseRecord? record;

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _categories = const [
    'Yakıt',
    'Sigorta',
    'Vergi',
    'Tamir',
    'Lastik',
    'Yıkama',
    'Otopark',
    'Diğer',
  ];

  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isSaving = false;

  bool get _isEditMode => widget.record != null;

  @override
  void initState() {
    super.initState();

    final record = widget.record;
    if (record != null) {
      _selectedCategory = record.category;
      _descriptionController.text = record.description ?? '';
      _amountController.text = record.amount.toStringAsFixed(2);
      _selectedDate = DateTime.tryParse(record.date)?.toLocal();
    } else {
      _selectedDate = DateTime.now().toLocal();
    }

    _dateController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
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
      _showMessage('Masraf kaydı için araç seçilmeli');
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
    final record = ExpenseRecord(
      id: currentRecord?.id,
      vehicleId: currentRecord?.vehicleId ?? widget.vehicle.id!,
      category: _selectedCategory!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      amount: double.parse(_normalizeDecimal(_amountController.text.trim())),
      date: selectedDate.toIso8601String(),
      createdAt:
          currentRecord?.createdAt ??
          DateTime.now().toLocal().toIso8601String(),
    );

    try {
      if (_isEditMode) {
        await DatabaseHelper.instance.updateExpenseRecord(record);
      } else {
        await DatabaseHelper.instance.insertExpenseRecord(record);
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        _isEditMode ? 'Masraf kaydı güncellendi' : 'Masraf kaydı eklendi',
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

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tutar boş olamaz';
    }

    final amount = double.tryParse(_normalizeDecimal(value.trim()));
    if (amount == null) {
      return 'Tutar sayı olmalı';
    }

    if (amount < 0) {
      return 'Tutar negatif olamaz';
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
      appBar: AppBar(
        title: Text(_isEditMode ? 'Masraf Düzenle' : 'Masraf Ekle'),
      ),
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
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Kategori seçilmeli';
                    }

                    return null;
                  },
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
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Tutar',
                    prefixIcon: Icon(Icons.payments),
                    suffixText: 'TL',
                  ),
                  validator: _amountValidator,
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
