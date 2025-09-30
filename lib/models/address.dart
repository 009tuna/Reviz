class Address {
  final String id;
  final String title; // Ev, İş vb.
  final String line;
  final double? lat;
  final double? lng;

  Address({
    required this.id,
    required this.title,
    required this.line,
    this.lat,
    this.lng,
  });

  factory Address.fromMap(Map<String, dynamic> m) => Address(
        id: m['id'].toString(),
        title: m['title'] ?? 'Adres',
        line: m['line'] ?? '',
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
      );
}
