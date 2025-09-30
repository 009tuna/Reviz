import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle.dart';

class VehiclesRepository {
  final SupabaseClient _sb;
  VehiclesRepository(this._sb);

  static const _table = 'vehicles';

  Future<List<Vehicle>> fetchMyVehicles() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await _sb
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (res as List)
        .map((e) => Vehicle.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Sadece plaka listesi (Home özetinde kullanmak için)
  Future<List<String>> fetchMyPlates() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await _sb
        .from(_table)
        .select('plate')
        .eq('user_id', uid)
        .order('created_at');
    return (res as List).map((e) => (e as Map)['plate'] as String).toList();
  }

  Future<Vehicle> addVehicle({
    required String plate,
    required String brand,
    required String model,
    required int year,
    DateTime? purchaseDate,
    int? km,
  }) async {
    final uid = _sb.auth.currentUser!.id;
    final insert = {
      'user_id': uid,
      'plate': plate.trim(),
      'brand': brand.trim(),
      'model': model.trim(),
      'year': year,
      'purchase_date': purchaseDate?.toIso8601String(),
      'km': km,
    };
    final res = await _sb.from(_table).insert(insert).select().single();
    return Vehicle.fromMap(res);
  }

  Future<void> deleteVehicle(String id) async {
    final uid = _sb.auth.currentUser!.id;
    await _sb.from(_table).delete().eq('id', id).eq('user_id', uid);
  }
}
