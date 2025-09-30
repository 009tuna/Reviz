// lib/data/appointments_repo.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Randevu durumları
enum AppointmentStatus { pending, confirmed, completed, cancelled }

/// Tek model
class Appointment {
  final String id;
  final String plate;
  final String vehicleModel;
  final String serviceName;
  final DateTime dateTime;
  final String cityDistrict;
  final double distanceKm;
  final AppointmentStatus status;
  final bool hasTow;
  final String? note;
  final List<String> brandTags;

  const Appointment({
    required this.id,
    required this.plate,
    required this.vehicleModel,
    required this.serviceName,
    required this.dateTime,
    required this.cityDistrict,
    required this.distanceKm,
    required this.status,
    required this.hasTow,
    this.note,
    this.brandTags = const [],
  });

  static Appointment fromRow(Map<String, dynamic> row) {
    final statusStr = (row['status'] ?? 'pending').toString();
    final status = _statusFromDb(statusStr);

    final rawDt = row['date_time'];
    final DateTime dt = rawDt is String
        ? DateTime.parse(rawDt)
        : (rawDt is DateTime ? rawDt : DateTime.now());

    return Appointment(
      id: (row['id'] ?? '').toString(),
      plate: (row['plate'] ?? '').toString(),
      vehicleModel: (row['vehicle_model'] ?? '').toString(),
      serviceName: (row['service_name'] ?? '').toString(),
      dateTime: dt,
      cityDistrict: (row['city_district'] ?? '').toString(),
      distanceKm: (row['distance_km'] is num)
          ? (row['distance_km'] as num).toDouble()
          : 0.0,
      status: status,
      hasTow: (row['has_tow'] ?? false) == true,
      note: row['note']?.toString(),
      brandTags: (row['brand_tags'] is List)
          ? (row['brand_tags'] as List).map((e) => e.toString()).toList()
          : const <String>[],
    );
  }

  static Map<String, dynamic> toRow(Appointment a) {
    return {
      'id': a.id,
      'plate': a.plate,
      'vehicle_model': a.vehicleModel,
      'service_name': a.serviceName,
      'date_time': a.dateTime.toIso8601String(),
      'city_district': a.cityDistrict,
      'distance_km': a.distanceKm,
      'status': _statusToDb(a.status),
      'has_tow': a.hasTow,
      'note': a.note,
      'brand_tags': a.brandTags,
    };
  }

  static AppointmentStatus _statusFromDb(String v) {
    switch (v) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  static String _statusToDb(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.pending:
      default:
        return 'pending';
    }
  }
}

/// Arayüz
abstract class AppointmentRepo {
  Stream<List<Appointment>> streamAppointments(String userId);
  Future<List<Appointment>> fetchAppointments(String userId);
  Future<void> cancelAppointment(String appointmentId);
  Future<void> rescheduleAppointment(String appointmentId, DateTime newTime);
}

/// Supabase implementasyonu
class SupabaseAppointmentRepo implements AppointmentRepo {
  final SupabaseClient supabase;
  SupabaseAppointmentRepo(this.supabase);

  static const _table = 'appointments';

  @override
  Stream<List<Appointment>> streamAppointments(String userId) {
    final stream =
        supabase.from(_table).stream(primaryKey: ['id']).eq('user_id', userId);
    return stream.map((rows) =>
        rows.map<Appointment>((r) => Appointment.fromRow(r)).toList());
  }

  @override
  Future<List<Appointment>> fetchAppointments(String userId) async {
    // BURADA GENERIC YOK: sadece .select()
    final rows = await supabase
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('date_time', ascending: true);

    // rows tip olarak dynamic list olabilir; güvenli cast + map:
    final list = (rows as List)
        .map((e) => Appointment.fromRow(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await supabase
        .from(_table)
        .update({'status': 'cancelled'}).eq('id', appointmentId);
  }

  @override
  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newTime) async {
    await supabase.from(_table).update({
      'date_time': newTime.toIso8601String(),
      'status': 'confirmed',
    }).eq('id', appointmentId);
  }
}

/// Mock (UI geliştirirken)
class MockAppointmentRepo implements AppointmentRepo {
  final _controller = StreamController<List<Appointment>>.broadcast();
  List<Appointment> _data = [
    Appointment(
      id: 'a1',
      plate: '34 BAK 81',
      vehicleModel: 'CBR-650',
      serviceName: 'Duha Motobike',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      cityDistrict: 'Sancaktepe/İstanbul',
      distanceKm: 1.2,
      status: AppointmentStatus.confirmed,
      hasTow: true,
      note: 'Ön fren balatası sesi var.',
      brandTags: const ['KUBA', 'VOLTA', 'ARORA'],
    ),
    Appointment(
      id: 'a2',
      plate: '34 ABC 123',
      vehicleModel: 'PCX 150',
      serviceName: 'City Moto',
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 5)),
      cityDistrict: 'Ümraniye/İstanbul',
      distanceKm: 3.7,
      status: AppointmentStatus.pending,
      hasTow: false,
    ),
  ];

  MockAppointmentRepo() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.add(_data);
    });
  }

  @override
  Stream<List<Appointment>> streamAppointments(String userId) =>
      _controller.stream;

  @override
  Future<List<Appointment>> fetchAppointments(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _data;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    _data = _data
        .map((e) => e.id == appointmentId
            ? Appointment(
                id: e.id,
                plate: e.plate,
                vehicleModel: e.vehicleModel,
                serviceName: e.serviceName,
                dateTime: e.dateTime,
                cityDistrict: e.cityDistrict,
                distanceKm: e.distanceKm,
                status: AppointmentStatus.cancelled,
                hasTow: e.hasTow,
                note: e.note,
                brandTags: e.brandTags,
              )
            : e)
        .toList();
    _controller.add(_data);
  }

  @override
  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newTime) async {
    _data = _data
        .map((e) => e.id == appointmentId
            ? Appointment(
                id: e.id,
                plate: e.plate,
                vehicleModel: e.vehicleModel,
                serviceName: e.serviceName,
                dateTime: newTime,
                cityDistrict: e.cityDistrict,
                distanceKm: e.distanceKm,
                status: AppointmentStatus.confirmed,
                hasTow: e.hasTow,
                note: e.note,
                brandTags: e.brandTags,
              )
            : e)
        .toList();
    _controller.add(_data);
  }
}
