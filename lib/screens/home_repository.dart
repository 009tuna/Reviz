import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  HomeRepository(this.client);
  final SupabaseClient client;

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> getVehicles(String userId) async {
    final res = await client
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getNearbyServices({
    required double lat,
    required double lng,
    int limit = 6,
  }) async {
    // PostGIS varsa:
    try {
      final res = await client.from('services').select("""
            id,name,city,district,rating,rating_count,hero_image_url,lat,lng,
            distance: st_distance(geom, geography(st_setsrid(st_makepoint($lng,$lat),4326)))
          """).order('distance').limit(limit);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      // yoksa RPC fallback
      final res = await client.rpc('nearby_services', params: {
        'plat': lat,
        'plng': lng,
        'plimit': limit,
      });
      return List<Map<String, dynamic>>.from(res);
    }
  }

  Future<List<Map<String, dynamic>>> getServicesByCityDistrict({
    required String city,
    required String district,
    int limit = 6,
  }) async {
    final res = await client
        .from('services')
        .select()
        .eq('city', city)
        .eq('district', district)
        .order('rating', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getAppointments(String userId) async {
    final res = await client
        .from('appointments')
        .select()
        .eq('user_id', userId)
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  RealtimeChannel listenAppointments(void Function() onAnyChange) {
    final ch = client.channel('public:appointments')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'appointments',
        callback: (_) => onAnyChange(),
      )
      ..subscribe();
    return ch;
  }

  Future<void> createAppointment({
    required String userId,
    required String title,
    required DateTime startTime,
    String? vehicleId,
  }) async {
    await client.from('appointments').insert({
      'user_id': userId,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'status': 'pending',
      'vehicle_id': vehicleId,
    });
  }
}
