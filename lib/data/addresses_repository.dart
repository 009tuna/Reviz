import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address.dart';

class AddressesRepository {
  final SupabaseClient sb;
  AddressesRepository(this.sb);

  Future<List<Address>> fetchMyAddresses() async {
    // TODO: kendi tablo adını yaz: 'addresses' örnektir
    final uid = sb.auth.currentUser!.id;
    final res = await sb.from('addresses').select().eq('user_id', uid);
    return (res as List).map((e) => Address.fromMap(e)).toList();
  }
}
