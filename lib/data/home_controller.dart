// lib/data/home_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_repository.dart';

/// Provider ile kullanılacak controller
class HomeController extends ChangeNotifier {
  HomeController({HomeRepository? repository})
      : _repo = repository ?? HomeRepository(Supabase.instance.client);

  final HomeRepository _repo;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  List<ServiceItem> _services = const [];
  List<ServiceItem> get services => _services;

  List<AppointmentItem> _appointments = const [];
  List<AppointmentItem> get appointments => _appointments;

  StreamSubscription<List<AppointmentItem>>? _apptSub;

  double? _lat;
  double? _lng;

  /// Ekran ilk açıldığında çağır
  Future<void> init() async {
    _setLoading(true);
    _error = null;

    try {
      // 1) Konum izni ve koordinatlar (opsiyonel)
      await _ensureLocation();

      // 2) Önerilen servisler
      _services = await _repo.fetchRecommendedServices(lat: _lat, lng: _lng);

      // 3) Appointments stream
      final uid = _repo.currentUserId;
      if (uid != null) {
        _apptSub?.cancel();
        _apptSub = _repo.streamAppointments(userId: uid).listen((items) {
          _appointments = items;
          notifyListeners();
        });
      } else {
        // oturum yoksa sadece boş bırak
        _appointments = const [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Manuel yenile
  Future<void> refreshAll() async {
    _setLoading(true);
    _error = null;
    try {
      final uid = _repo.currentUserId;

      // konumu güncellemeden sadece servisleri tekrar çekmek istersen:
      _services = await _repo.fetchRecommendedServices(lat: _lat, lng: _lng);

      if (uid != null) {
        // tek seferlik çek; stream zaten açık ama ilk yükleme için faydalı
        _appointments = await _repo.fetchAppointmentsOnce(userId: uid);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Konuma göre servisi tekrar getir (kullanıcı şehir değişti vb.)
  Future<void> updateLocationAndReload(double lat, double lng) async {
    _lat = lat;
    _lng = lng;
    await refreshAll();
  }

  @override
  void dispose() {
    _apptSub?.cancel();
    super.dispose();
  }

  // --------------------------
  // İç yardımcılar
  // --------------------------
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  Future<void> _ensureLocation() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) return; // servis kapalı → konumsuz devam

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return; // izin yok → konumsuz devam
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lat = pos.latitude;
      _lng = pos.longitude;
    } catch (_) {
      // sessizce konumsuz kal
      _lat = null;
      _lng = null;
    }
  }
}
