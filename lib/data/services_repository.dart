import '../models/service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesRepository {
  final SupabaseClient sb;
  ServicesRepository(this.sb);

  Future<List<Service>> fetchNearby(
      {required double lat, required double lng, int limit = 20}) async {
    final res = await sb
        .from('services_with_distance')
        .select()
        .order('distance_km')
        .limit(limit);
    return (res as List).map((e) => Service.fromMap(e)).toList();
  }

  /// Önerilen servisler (kullanıcı, araç ve hizmet tipine göre)
  Future<List<Service>> fetchRecommended({
    required String userId,
    required String vehicleId,
    required String serviceType, // 'onarim' | 'bakim' | 'ekspertiz'
    int limit = 20,
  }) async {
    // Örnek kullanım: view veya rpc
    final res = await sb.rpc('recommended_services', params: {
      'p_user_id': userId,
      'p_vehicle_id': vehicleId,
      'p_service_type': serviceType,
      'p_limit': limit,
    });
    return (res as List).map((e) => Service.fromMap(e)).toList();
  }
}
