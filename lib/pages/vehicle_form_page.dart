import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/vehicle.dart';

class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _yearController = TextEditingController();
  final _currentKmController = TextEditingController();
  final _fuelTypes = const ['Benzin', 'Dizel', 'LPG', 'Hibrit', 'Elektrik'];

  String? _selectedFuelType;
  bool _isSaving = false;

  bool get _isEditMode => widget.vehicle != null;

  @override
  void initState() {
    super.initState();

    final vehicle = widget.vehicle;
    if (vehicle != null) {
      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _plateController.text = vehicle.plate;
      _yearController.text = vehicle.year.toString();
      _currentKmController.text = vehicle.currentKm.toString();
      _selectedFuelType = vehicle.fuelType;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _yearController.dispose();
    _currentKmController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final currentVehicle = widget.vehicle;
    final vehicle = Vehicle(
      id: currentVehicle?.id,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      plate: _plateController.text.trim().toUpperCase(),
      year: int.parse(_yearController.text.trim()),
      currentKm: int.parse(_currentKmController.text.trim()),
      fuelType: _selectedFuelType!,
      createdAt:
          currentVehicle?.createdAt ??
          DateTime.now().toLocal().toIso8601String(),
    );

    try {
      if (_isEditMode) {
        await DatabaseHelper.instance.updateVehicle(vehicle);
      } else {
        await DatabaseHelper.instance.insertVehicle(vehicle);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Araç güncellendi' : 'Araç kaydedildi'),
        ),
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem sırasında hata oluştu')),
      );
    }
  }

  String? _requiredTextValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş olamaz';
    }

    return null;
  }

  String? _yearValidator(String? value) {
    final requiredError = _requiredTextValidator(value, 'Yıl');
    if (requiredError != null) {
      return requiredError;
    }

    final year = int.tryParse(value!.trim());
    if (year == null) {
      return 'Yıl sayı olmalı';
    }

    if (year < 1900 || year > 2100) {
      return 'Yıl 1900 ile 2100 arasında olmalı';
    }

    return null;
  }

  String? _kmValidator(String? value) {
    final requiredError = _requiredTextValidator(value, 'Mevcut KM');
    if (requiredError != null) {
      return requiredError;
    }

    final km = int.tryParse(value!.trim());
    if (km == null) {
      return 'Mevcut KM sayı olmalı';
    }

    if (km < 0) {
      return 'Mevcut KM negatif olamaz';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Araç Düzenle' : 'Araç Ekle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _brandController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Marka',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  validator: (value) => _requiredTextValidator(value, 'Marka'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _modelController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) => _requiredTextValidator(value, 'Model'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Plaka',
                    prefixIcon: Icon(Icons.pin),
                  ),
                  validator: (value) => _requiredTextValidator(value, 'Plaka'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Yıl',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  validator: _yearValidator,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _currentKmController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Mevcut KM',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  validator: _kmValidator,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedFuelType,
                  decoration: const InputDecoration(
                    labelText: 'Yakıt Türü',
                    prefixIcon: Icon(Icons.local_gas_station),
                  ),
                  items: _fuelTypes
                      .map(
                        (fuelType) => DropdownMenuItem<String>(
                          value: fuelType,
                          child: Text(fuelType),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedFuelType = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Yakıt türü seçilmeli';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveVehicle,
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
