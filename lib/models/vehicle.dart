class Vehicle {
  final String id;
  final String userId;
  final String plate;
  final String brand;
  final String model;
  final int year;
  final DateTime? purchaseDate;
  final int? km;

  Vehicle({
    required this.id,
    required this.userId,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    this.purchaseDate,
    this.km,
  });

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        plate: m['plate'] as String,
        brand: m['brand'] as String,
        model: m['model'] as String,
        year: (m['year'] as num).toInt(),
        purchaseDate: m['purchase_date'] == null
            ? null
            : DateTime.parse(m['purchase_date'] as String),
        km: m['km'] == null ? null : (m['km'] as num).toInt(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'plate': plate,
        'brand': brand,
        'model': model,
        'year': year,
        'purchase_date': purchaseDate?.toIso8601String(),
        'km': km,
      };
}
