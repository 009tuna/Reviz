import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_repository.dart';

class HomeController extends ChangeNotifier {
  HomeController(this.repo);
  final HomeRepository repo;

  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> appointments = [];

  bool loading = true;
  Object? error;
  RealtimeChannel? _apptsCh;

  Future<void> init() async {
    try {
      loading = true;
      error = null;
      notifyListeners();
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        loading = false;
        error = 'auth yok';
        notifyListeners();
        return;
      }

      profile = await repo.getProfile(user.id);
      vehicles = await repo.getVehicles(user.id);
      appointments = await repo.getAppointments(user.id);

      // Servis önerisi: GPS → yoksa city/district
      services = await _loadServicesByLocation(profile);

      // Realtime: randevular
      _apptsCh?.unsubscribe();
      _apptsCh = repo.listenAppointments(() async {
        final u = Supabase.instance.client.auth.currentUser;
        if (u == null) return;
        appointments = await repo.getAppointments(u.id);
        notifyListeners();
      });

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      error = e;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _loadServicesByLocation(
      Map<String, dynamic>? p) async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        return await repo.getNearbyServices(
            lat: pos.latitude, lng: pos.longitude, limit: 6);
      }

      if ((p?['city'] ?? '').toString().isNotEmpty &&
          (p?['district'] ?? '').toString().isNotEmpty) {
        return await repo.getServicesByCityDistrict(
            city: p!['city'], district: p['district'], limit: 6);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> createQuickAppointment() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await repo.createAppointment(
      userId: user.id,
      title: 'Genel Kontrol',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      vehicleId: vehicles.isNotEmpty ? vehicles.first['id'] as String : null,
    );
  }

  @override
  void dispose() {
    _apptsCh?.unsubscribe();
    super.dispose();
  }
}
