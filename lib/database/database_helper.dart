import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/expense_record.dart';
import '../models/maintenance_record.dart';
import '../models/vehicle.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String databaseName = 'otobakim_defteri.db';
  static const int databaseVersion = 1;

  static const String vehiclesTable = 'vehicles';
  static const String maintenanceRecordsTable = 'maintenance_records';
  static const String expenseRecordsTable = 'expense_records';

  static const String columnId = 'id';
  static const String columnBrand = 'brand';
  static const String columnModel = 'model';
  static const String columnPlate = 'plate';
  static const String columnYear = 'year';
  static const String columnCurrentKm = 'current_km';
  static const String columnFuelType = 'fuel_type';
  static const String columnCreatedAt = 'created_at';
  static const String columnVehicleId = 'vehicle_id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnKm = 'km';
  static const String columnDate = 'date';
  static const String columnCost = 'cost';
  static const String columnCategory = 'category';
  static const String columnAmount = 'amount';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final fullPath = path.join(databasePath, databaseName);

    return openDatabase(
      fullPath,
      version: databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $vehiclesTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnBrand TEXT NOT NULL,
        $columnModel TEXT NOT NULL,
        $columnPlate TEXT NOT NULL,
        $columnYear INTEGER NOT NULL,
        $columnCurrentKm INTEGER NOT NULL,
        $columnFuelType TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $maintenanceRecordsTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnVehicleId INTEGER NOT NULL,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnKm INTEGER NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnCost REAL NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnVehicleId) REFERENCES $vehiclesTable ($columnId)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $expenseRecordsTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnVehicleId INTEGER NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnDescription TEXT,
        $columnAmount REAL NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnVehicleId) REFERENCES $vehiclesTable ($columnId)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return db.insert(vehiclesTable, vehicle.toMap());
  }

  Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final maps = await db.query(vehiclesTable);
    return maps.map(Vehicle.fromMap).toList();
  }

  Future<Vehicle?> getVehicleById(int id) async {
    final db = await database;
    final maps = await db.query(
      vehiclesTable,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Vehicle.fromMap(maps.first);
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return db.update(
      vehiclesTable,
      vehicle.toMap(),
      where: '$columnId = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return db.delete(vehiclesTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> getVehicleCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $vehiclesTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> insertMaintenanceRecord(MaintenanceRecord record) async {
    final db = await database;
    return db.insert(maintenanceRecordsTable, record.toMap());
  }

  Future<List<MaintenanceRecord>> getMaintenanceRecordsByVehicleId(
    int vehicleId,
  ) async {
    final db = await database;
    final maps = await db.query(
      maintenanceRecordsTable,
      where: '$columnVehicleId = ?',
      whereArgs: [vehicleId],
    );
    return maps.map(MaintenanceRecord.fromMap).toList();
  }

  Future<int> updateMaintenanceRecord(MaintenanceRecord record) async {
    final db = await database;
    return db.update(
      maintenanceRecordsTable,
      record.toMap(),
      where: '$columnId = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteMaintenanceRecord(int id) async {
    final db = await database;
    return db.delete(
      maintenanceRecordsTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> getMaintenanceCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $maintenanceRecordsTable',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalMaintenanceCostByVehicleId(int vehicleId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM($columnCost) AS total
      FROM $maintenanceRecordsTable
      WHERE $columnVehicleId = ?
      ''',
      [vehicleId],
    );
    return _readTotal(result);
  }

  Future<double> getTotalMaintenanceCost() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM($columnCost) AS total FROM $maintenanceRecordsTable',
    );
    return _readTotal(result);
  }

  Future<int> insertExpenseRecord(ExpenseRecord record) async {
    final db = await database;
    return db.insert(expenseRecordsTable, record.toMap());
  }

  Future<List<ExpenseRecord>> getExpenseRecordsByVehicleId(
    int vehicleId,
  ) async {
    final db = await database;
    final maps = await db.query(
      expenseRecordsTable,
      where: '$columnVehicleId = ?',
      whereArgs: [vehicleId],
    );
    return maps.map(ExpenseRecord.fromMap).toList();
  }

  Future<int> updateExpenseRecord(ExpenseRecord record) async {
    final db = await database;
    return db.update(
      expenseRecordsTable,
      record.toMap(),
      where: '$columnId = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteExpenseRecord(int id) async {
    final db = await database;
    return db.delete(
      expenseRecordsTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> getExpenseCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $expenseRecordsTable',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalExpenseAmountByVehicleId(int vehicleId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM($columnAmount) AS total
      FROM $expenseRecordsTable
      WHERE $columnVehicleId = ?
      ''',
      [vehicleId],
    );
    return _readTotal(result);
  }

  Future<double> getTotalExpenseAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM($columnAmount) AS total FROM $expenseRecordsTable',
    );
    return _readTotal(result);
  }

  Future<double> getGrandTotalCost() async {
    final db = await database;
    final maintenanceResult = await db.rawQuery(
      'SELECT SUM($columnCost) AS total FROM $maintenanceRecordsTable',
    );
    final expenseResult = await db.rawQuery(
      'SELECT SUM($columnAmount) AS total FROM $expenseRecordsTable',
    );

    return _readTotal(maintenanceResult) + _readTotal(expenseResult);
  }

  double _readTotal(List<Map<String, Object?>> result) {
    if (result.isEmpty || result.first['total'] == null) {
      return 0.0;
    }

    return (result.first['total'] as num).toDouble();
  }
}
