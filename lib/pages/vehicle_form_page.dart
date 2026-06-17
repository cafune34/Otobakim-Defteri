import 'package:flutter/material.dart';

class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({super.key});

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fuelTypes = const ['Benzin', 'Dizel', 'LPG', 'Hibrit', 'Elektrik'];
  String? _selectedFuelType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Araç Ekle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Marka',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Model',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Plaka',
                    prefixIcon: Icon(Icons.pin),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Yıl',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                ),
                const SizedBox(height: 14),
                const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mevcut KM',
                    prefixIcon: Icon(Icons.speed),
                  ),
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
                  onChanged: (value) {
                    setState(() {
                      _selectedFuelType = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Sprint 2'de SQLite bağlantısı eklenecek",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
