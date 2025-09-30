class Service {
  final String id;
  final String name;
  final double distanceKm;
  final double rating; // 0–5
  final int ratingCount;
  final String district; // “Sancaktepe/İstanbul”
  final List<String> brands; // ["KUBA","VOLTA","ARORA"]
  final String heroAsset; // Ana görsel (assets/...png)

  Service({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.rating,
    required this.ratingCount,
    required this.district,
    required this.brands,
    required this.heroAsset,
  });

  factory Service.fromMap(Map<String, dynamic> m) => Service(
        id: m['id'].toString(),
        name: m['name'] ?? '',
        distanceKm: (m['distance_km'] as num?)?.toDouble() ?? 0,
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        ratingCount: m['rating_count'] ?? 0,
        district: m['district'] ?? '',
        brands: (m['brands'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        heroAsset: m['hero_asset'] ?? 'assets/mage1@2x.png',
      );
}
