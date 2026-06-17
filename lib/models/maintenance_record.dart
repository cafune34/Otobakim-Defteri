class MaintenanceRecord {
  const MaintenanceRecord({
    this.id,
    required this.vehicleId,
    required this.title,
    this.description,
    required this.km,
    required this.date,
    required this.cost,
    required this.createdAt,
  });

  final int? id;
  final int vehicleId;
  final String title;
  final String? description;
  final int km;
  final String date;
  final double cost;
  final String createdAt;

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      km: map['km'] as int,
      date: map['date'] as String,
      cost: (map['cost'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'description': description,
      'km': km,
      'date': date,
      'cost': cost,
      'created_at': createdAt,
    };
  }

  MaintenanceRecord copyWith({
    int? id,
    int? vehicleId,
    String? title,
    String? description,
    int? km,
    String? date,
    double? cost,
    String? createdAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      km: km ?? this.km,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
