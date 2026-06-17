import 'package:flutter_test/flutter_test.dart';
import 'package:otobakim_defteri/models/expense_record.dart';
import 'package:otobakim_defteri/models/maintenance_record.dart';
import 'package:otobakim_defteri/models/vehicle.dart';

void main() {
  group('Vehicle model conversion', () {
    test('toMap and fromMap use SQLite column names', () {
      const vehicle = Vehicle(
        id: 1,
        brand: 'Toyota',
        model: 'Corolla',
        plate: '34 ABC 123',
        year: 2020,
        currentKm: 45000,
        fuelType: 'Benzin',
        createdAt: '2026-06-17T10:00:00',
      );

      final map = vehicle.toMap();

      expect(map['id'], 1);
      expect(map['current_km'], 45000);
      expect(map['fuel_type'], 'Benzin');
      expect(map.containsKey('currentKm'), isFalse);
      expect(map.containsKey('fuelType'), isFalse);

      final converted = Vehicle.fromMap(map);

      expect(converted.id, vehicle.id);
      expect(converted.brand, vehicle.brand);
      expect(converted.model, vehicle.model);
      expect(converted.plate, vehicle.plate);
      expect(converted.year, vehicle.year);
      expect(converted.currentKm, vehicle.currentKm);
      expect(converted.fuelType, vehicle.fuelType);
      expect(converted.createdAt, vehicle.createdAt);
    });

    test('nullable id remains null', () {
      const vehicle = Vehicle(
        brand: 'Renault',
        model: 'Clio',
        plate: '06 DEF 456',
        year: 2018,
        currentKm: 72000,
        fuelType: 'Dizel',
        createdAt: '2026-06-17T11:00:00',
      );

      final converted = Vehicle.fromMap(vehicle.toMap());

      expect(vehicle.toMap()['id'], isNull);
      expect(converted.id, isNull);
    });
  });

  group('MaintenanceRecord model conversion', () {
    test('toMap and fromMap use SQLite column names', () {
      const record = MaintenanceRecord(
        id: 2,
        vehicleId: 1,
        title: 'Yağ değişimi',
        description: 'Motor yağı ve filtre değişti',
        km: 45000,
        date: '2026-06-17',
        cost: 1200.5,
        createdAt: '2026-06-17T12:00:00',
      );

      final map = record.toMap();

      expect(map['id'], 2);
      expect(map['vehicle_id'], 1);
      expect(map['cost'], 1200.5);
      expect(map.containsKey('vehicleId'), isFalse);

      final converted = MaintenanceRecord.fromMap(map);

      expect(converted.id, record.id);
      expect(converted.vehicleId, record.vehicleId);
      expect(converted.title, record.title);
      expect(converted.description, record.description);
      expect(converted.km, record.km);
      expect(converted.date, record.date);
      expect(converted.cost, record.cost);
      expect(converted.createdAt, record.createdAt);
    });

    test('nullable id and description remain null', () {
      const record = MaintenanceRecord(
        vehicleId: 3,
        title: 'Lastik kontrolü',
        km: 50000,
        date: '2026-06-18',
        cost: 0,
        createdAt: '2026-06-18T09:00:00',
      );

      final converted = MaintenanceRecord.fromMap(record.toMap());

      expect(record.toMap()['id'], isNull);
      expect(converted.id, isNull);
      expect(converted.description, isNull);
      expect(converted.vehicleId, 3);
    });
  });

  group('ExpenseRecord model conversion', () {
    test('toMap and fromMap use SQLite column names', () {
      const record = ExpenseRecord(
        id: 4,
        vehicleId: 2,
        category: 'Yakıt',
        description: 'Depo dolumu',
        amount: 1850.75,
        date: '2026-06-17',
        createdAt: '2026-06-17T13:00:00',
      );

      final map = record.toMap();

      expect(map['id'], 4);
      expect(map['vehicle_id'], 2);
      expect(map['amount'], 1850.75);
      expect(map.containsKey('vehicleId'), isFalse);

      final converted = ExpenseRecord.fromMap(map);

      expect(converted.id, record.id);
      expect(converted.vehicleId, record.vehicleId);
      expect(converted.category, record.category);
      expect(converted.description, record.description);
      expect(converted.amount, record.amount);
      expect(converted.date, record.date);
      expect(converted.createdAt, record.createdAt);
    });

    test('nullable id and description remain null', () {
      const record = ExpenseRecord(
        vehicleId: 5,
        category: 'Otopark',
        amount: 120,
        date: '2026-06-18',
        createdAt: '2026-06-18T10:00:00',
      );

      final converted = ExpenseRecord.fromMap(record.toMap());

      expect(record.toMap()['id'], isNull);
      expect(converted.id, isNull);
      expect(converted.description, isNull);
      expect(converted.vehicleId, 5);
    });
  });
}
