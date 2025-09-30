import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Basit veri tipleri
class ServiceItem {
  final String id;
  final String name;
  final String? districtCity; // "Sancaktepe/İstanbul" gibi
  final double? distanceKm; // RPC varsa gelir
  final double? rating; // 0..5
  final int? ratingCount;

  ServiceItem({
    required this.id,
    required this.name,
    this.districtCity,
    this.distanceKm,
    this.rating,
    this.ratingCount,
  });

  static ServiceItem fromMap(Map<String, dynamic> m) {
    return ServiceItem(
      id: '${m['id']}',
      name: '${m['name'] ?? ''}',
      districtCity: m['district_city'] as String?,
      distanceKm: (m['distance_km'] as num?)?.toDouble(),
      rating: (m['rating'] as num?)?.toDouble(),
      ratingCount: m['rating_count'] as int?,
    );
  }
}

class AppointmentItem {
  final String id;
  final String serviceName;
  final String plate;
  final String model;
  final DateTime createdAt;
  final String status; // örn: pending/confirmed/completed
  final String? districtCity;

  AppointmentItem({
    required this.id,
    required this.serviceName,
    required this.plate,
    required this.model,
    required this.createdAt,
    required this.status,
    this.districtCity,
  });

  static AppointmentItem fromMap(Map<String, dynamic> m) {
    return AppointmentItem(
      id: '${m['id']}',
      serviceName: '${m['service_name'] ?? ''}',
      plate: '${m['plate'] ?? ''}',
      model: '${m['model'] ?? ''}',
      createdAt: DateTime.parse('${m['created_at']}'),
      status: '${m['status'] ?? 'pending'}',
      districtCity: m['district_city'] as String?,
    );
  }
}

class HomeRepository {
  HomeRepository(this._client);
  final SupabaseClient _client;

  /// Konuma göre önerilen servisler:
  /// - PostGIS yoksa: RPC `nearby_services(lat, lng, radius_km)`
  /// - Yoksa fallback: en yüksek puanlı ilk N servis
  Future<List<ServiceItem>> fetchRecommendedServices({
    double? lat,
    double? lng,
    double radiusKm = 25,
    int limit = 10,
  }) async {
    try {
      if (lat != null && lng != null) {
        // RPC varsa çalışır; yoksa Supabase hata döndürür → catch ile fallback
        final res = await _client.rpc(
          'nearby_services',
          params: {
            'in_lat': lat,
            'in_lng': lng,
            'in_radius_km': radiusKm,
            'in_limit': limit,
          },
        );
        final List data = (res as List?) ?? const [];
        return data
            .map((e) => ServiceItem.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      }

      // Fallback: rating’e göre sırala
      final res = await _client
          .from('services')
          .select('id,name,district_city,rating,rating_count')
          .order('rating', ascending: false)
          .limit(limit);
      final List data = (res as List?) ?? const [];
      return data
          .map((e) => ServiceItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      // Son çare: boş
      return [];
    }
  }

  /// Kullanıcının randevuları (realtime stream)
  Stream<List<AppointmentItem>> streamAppointments({required String userId}) {
    // Supabase 2.x stream
    final stream = _client
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at');

    return stream.map((rows) {
      return rows
          .map((e) => AppointmentItem.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        // en yeni üstte
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Tek seferlik randevu listesi (isteğe bağlı)
  Future<List<AppointmentItem>> fetchAppointmentsOnce(
      {required String userId}) async {
    final res = await _client
        .from('appointments')
        .select('id,service_name,plate,model,created_at,status,district_city')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final List data = (res as List?) ?? const [];
    return data
        .map((e) => AppointmentItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Aktif kullanıcı id
  String? get currentUserId => _client.auth.currentUser?.id;
}
