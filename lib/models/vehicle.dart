class Vehicle {
  const Vehicle({
    this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.year,
    required this.currentKm,
    required this.fuelType,
    required this.createdAt,
  });

  final int? id;
  final String brand;
  final String model;
  final String plate;
  final int year;
  final int currentKm;
  final String fuelType;
  final String createdAt;

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      model: map['model'] as String,
      plate: map['plate'] as String,
      year: map['year'] as int,
      currentKm: map['current_km'] as int,
      fuelType: map['fuel_type'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'plate': plate,
      'year': year,
      'current_km': currentKm,
      'fuel_type': fuelType,
      'created_at': createdAt,
    };
  }

  Vehicle copyWith({
    int? id,
    String? brand,
    String? model,
    String? plate,
    int? year,
    int? currentKm,
    String? fuelType,
    String? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      year: year ?? this.year,
      currentKm: currentKm ?? this.currentKm,
      fuelType: fuelType ?? this.fuelType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
