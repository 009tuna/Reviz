// lib/screens/home1.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:reviz_develop/widgets/icons.dart' as reviz_icons;

// Appointment modeli & repo (biz yazmıştık)
import 'package:reviz_develop/data/appointments_repo.dart';

class Home1 extends StatefulWidget {
  final AppointmentRepo? repo; // Dışarıdan verilebilir (test için)
  final String? userId;

  const Home1({
    super.key,
    this.repo,
    this.userId,
  });

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  late final AppointmentRepo _repo;
  late final String _userId;

  StreamSubscription<List<Appointment>>? _sub;

  bool _loading = true;
  List<Appointment> _appointments = const [];
  Appointment? _nextAppointment;

  @override
  void initState() {
    super.initState();

    // Repo ve userId’yi uygunca hazırla
    _repo = widget.repo ??
        // prod: Supabase client’ı main’de init ettiysen:
        // SupabaseAppointmentRepo(Supabase.instance.client);
        MockAppointmentRepo(); // şimdilik UI görsün diye
    _userId = widget.userId ?? 'demo';

    _listenStream();
    _initialFetch();
  }

  void _listenStream() {
    _sub = _repo.streamAppointments(_userId).listen((rows) {
      final list = List<Appointment>.from(rows); // typed
      _applyAppointments(list);
    });
  }

  Future<void> _initialFetch() async {
    try {
      final list = await _repo.fetchAppointments(_userId);
      _applyAppointments(list);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyAppointments(List<Appointment> list) {
    // yaklaşan en yakın randevuyu bul
    final now = DateTime.now();
    final upcoming = list
        .where((a) =>
            a.dateTime.isAfter(now) &&
            (a.status == AppointmentStatus.pending ||
                a.status == AppointmentStatus.confirmed))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final next = upcoming.isNotEmpty ? upcoming.first : null;

    if (!mounted) return;
    setState(() {
      _appointments = list;
      _nextAppointment = next;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: fs22,
      fontFamily: 'Roboto Flex',
      fontWeight: FontWeight.w700,
      height: 1.23,
      color: gray1200,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5FD),
        appBar: AppBar(
          title: Text('Ana Sayfa', style: titleStyle),
          backgroundColor: white300,
          toolbarHeight: height100,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(br30),
              topRight: Radius.circular(br30),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: ghostwhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(br30)),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(padding20, padding20, padding20, 120),
      children: [
        _Header(userId: _userId),
        const SizedBox(height: 16),
        const _SectionTitle(text: 'Yaklaşan Randevu'),
        const SizedBox(height: 8),
        _nextAppointment == null
            ? const _EmptySmall(
                message: 'Yaklaşan randevun yok',
                ctaText: 'Randevu Al',
                routeName: 'randevu_al',
              )
            : _NextAppointmentCard(appt: _nextAppointment!),
        const SizedBox(height: 20),
        const _SectionTitle(text: 'Hızlı İşlemler'),
        const SizedBox(height: 8),
        _QuickActions(
          onTapMakeAppointment: () {
            Navigator.pushNamed(context, 'randevu_al');
          },
          onTapMyAppointments: () {
            // BottomBar içindeki Appointments tabına gitmek istiyorsan:
            Navigator.pushNamed(context, '/tabs', arguments: 2);
          },
          onTapServices: () {
            Navigator.pushNamed(context, '/tabs', arguments: 1);
          },
        ),
        const SizedBox(height: 20),
        const _SectionTitle(text: 'Son Randevular'),
        const SizedBox(height: 8),
        ..._appointments.take(3).map((a) => _SmallAppointmentTile(appt: a)),
        if (_appointments.isEmpty)
          const _EmptySmall(
            message: 'Kayıtlı randevun yok',
            ctaText: 'Randevu Al',
            routeName: 'randevu_al',
          ),
      ],
    );
  }
}

/// ===================
/// parça: başlık/karşılama
/// ===================
class _Header extends StatelessWidget {
  final String userId;
  const _Header({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 24, backgroundColor: greenyellow300),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Merhaba, $userId',
            style: const TextStyle(
              fontSize: fs16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              height: 1.19,
              color: black500,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/tabs', arguments: 3),
          icon: const Icon(Icons.notifications_none, color: black300),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: fs14,
        fontFamily: 'Roboto Flex',
        fontWeight: FontWeight.w700,
        height: 1.14,
        color: black500,
      ),
    );
  }
}

/// ===================
/// parça: yaklaşan randevu kartı
/// ===================
class _NextAppointmentCard extends StatelessWidget {
  final Appointment appt;
  const _NextAppointmentCard({required this.appt});

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return Colors.amber.shade600;
      case AppointmentStatus.confirmed:
        return Colors.green.shade600;
      case AppointmentStatus.completed:
        return Colors.blueGrey.shade600;
      case AppointmentStatus.cancelled:
        return Colors.red.shade600;
    }
  }

  String _fmtDateTime(DateTime dt) {
    final d =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d • $t';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white300,
        borderRadius: BorderRadius.circular(br15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // üst satır
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // plaka kartı
              Container(
                width: 92,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: white300,
                  borderRadius: BorderRadius.circular(br8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    Text(
                      appt.plate,
                      style: const TextStyle(
                        fontSize: fs16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 1.19,
                        letterSpacing: -0.2,
                        color: black500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appt.vehicleModel,
                      style: const TextStyle(
                        fontSize: fs10,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: black600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // servis + konum + tarih
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.serviceName,
                      style: const TextStyle(
                        fontSize: fs14,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w600,
                        height: 1.14,
                        color: black500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: reviz_icons.Icons(name: 'MapPinLine'),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            appt.cityDistrict,
                            style: const TextStyle(
                              fontSize: fs10,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: black200,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${appt.distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: fs10,
                            fontFamily: 'Roboto Flex',
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: black200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: black300),
                        const SizedBox(width: 6),
                        Text(
                          _fmtDateTime(appt.dateTime),
                          style: const TextStyle(
                            fontSize: fs12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 1.17,
                            color: black500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // durum badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(appt.status).withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor(appt.status)),
                ),
                child: Text(
                  _statusText(appt.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(appt.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/tabs', arguments: 2);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: greenyellow300),
                    foregroundColor: black500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(br6),
                    ),
                  ),
                  child: const Text('Tüm Randevular'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'randevu_al');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gray1200,
                    foregroundColor: white100,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(br6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Yeni Randevu'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusText(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return 'Onay Bekliyor';
      case AppointmentStatus.confirmed:
        return 'Onaylandı';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal Edildi';
    }
  }
}

/// ===================
/// parça: hızlı işlemler
/// ===================
class _QuickActions extends StatelessWidget {
  final VoidCallback onTapMakeAppointment;
  final VoidCallback onTapMyAppointments;
  final VoidCallback onTapServices;

  const _QuickActions({
    required this.onTapMakeAppointment,
    required this.onTapMyAppointments,
    required this.onTapServices,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: const reviz_icons.Icons(name: 'Calendar'),
          label: 'Randevu Al',
          onTap: onTapMakeAppointment,
        ),
        const SizedBox(width: 10),
        _QuickAction(
          icon: const reviz_icons.Icons(name: 'solar-calendar-bold-3'),
          label: 'Randevularım',
          onTap: onTapMyAppointments,
        ),
        const SizedBox(width: 10),
        _QuickAction(
          icon: const reviz_icons.Icons(
              name: 'healthicons-factory-worker-outline'),
          label: 'Servisler',
          onTap: onTapServices,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(br10),
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: white300,
            borderRadius: BorderRadius.circular(br10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SizedBox(width: 24, height: 24, child: icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: fs12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    height: 1.17,
                    color: black500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: black300),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================
/// parça: küçük randevu satırı
/// ===================
class _SmallAppointmentTile extends StatelessWidget {
  final Appointment appt;
  const _SmallAppointmentTile({required this.appt});

  String _fmtDateTime(DateTime dt) {
    final d =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d • $t';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: white300,
        borderRadius: BorderRadius.circular(br10),
        border: Border.all(color: const Color(0x14000000)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: reviz_icons.Icons(name: 'Calendar'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              appt.serviceName,
              style: const TextStyle(
                fontSize: fs12,
                fontFamily: 'Roboto Flex',
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: black500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _fmtDateTime(appt.dateTime),
            style: const TextStyle(
              fontSize: fs10,
              fontFamily: 'Roboto Flex',
              height: 1.2,
              color: black300,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================
/// parça: boş küçük durum
/// ===================
class _EmptySmall extends StatelessWidget {
  final String message;
  final String ctaText;
  final String routeName;

  const _EmptySmall({
    required this.message,
    required this.ctaText,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white300,
        borderRadius: BorderRadius.circular(br10),
        border: Border.all(color: const Color(0x14000000)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: black300),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: fs12,
                fontFamily: 'Roboto Flex',
                height: 1.2,
                color: black500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, routeName),
            child: Text(
              ctaText,
              style: const TextStyle(
                fontSize: fs12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                height: 1.17,
                color: gray1200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
