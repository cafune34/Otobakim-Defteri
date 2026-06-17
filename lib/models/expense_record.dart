class ExpenseRecord {
  const ExpenseRecord({
    this.id,
    required this.vehicleId,
    required this.category,
    this.description,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  final int? id;
  final int vehicleId;
  final String category;
  final String? description;
  final double amount;
  final String date;
  final String createdAt;

  factory ExpenseRecord.fromMap(Map<String, dynamic> map) {
    return ExpenseRecord(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      category: map['category'] as String,
      description: map['description'] as String?,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date,
      'created_at': createdAt,
    };
  }

  ExpenseRecord copyWith({
    int? id,
    int? vehicleId,
    String? category,
    String? description,
    double? amount,
    String? date,
    String? createdAt,
  }) {
    return ExpenseRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
