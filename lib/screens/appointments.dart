// lib/screens/appointments.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:reviz_develop/widgets/icons.dart' as reviz_icons;

// Güncel model ve repo burada:
// Appointment, AppointmentStatus, AppointmentRepo vb.
import 'package:reviz_develop/data/appointments_repo.dart';

class AppointmentsPage extends StatefulWidget {
  final AppointmentRepo repo;
  final String userId;

  const AppointmentsPage({
    super.key,
    required this.repo,
    required this.userId,
  });

  /// Hızlı deneme için mock
  factory AppointmentsPage.mock({String userId = 'demo'}) {
    return AppointmentsPage(repo: MockAppointmentRepo(), userId: userId);
  }

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  StreamSubscription<List<Appointment>>? _sub;

  List<Appointment> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _listen();
    _initialFetch();
  }

  void _listen() {
    _sub = widget.repo.streamAppointments(widget.userId).listen((data) {
      if (!mounted) return;
      setState(() => _items = data);
    });
  }

  Future<void> _initialFetch() async {
    final data = await widget.repo.fetchAppointments(widget.userId);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _onRefresh() => _initialFetch();

  @override
  void dispose() {
    _sub?.cancel();
    _tab.dispose();
    super.dispose();
  }

  List<Appointment> _filtered(int tabIndex) {
    final now = DateTime.now();
    switch (tabIndex) {
      case 0: // Yaklaşan
        return _items
            .where((e) =>
                e.dateTime.isAfter(now) &&
                (e.status == AppointmentStatus.pending ||
                    e.status == AppointmentStatus.confirmed))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      case 1: // Geçmiş
        return _items
            .where((e) =>
                e.dateTime.isBefore(now) &&
                (e.status == AppointmentStatus.completed ||
                    e.status == AppointmentStatus.cancelled))
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      default: // Tümü
        return List.of(_items)
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
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
          title: const Text('Randevularım', style: titleStyle),
          backgroundColor: white300,
          toolbarHeight: height100,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(br30),
              topRight: Radius.circular(br30),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: white300,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: padding20),
              child: TabBar(
                controller: _tab,
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorColor: gray1200,
                labelColor: gray1200,
                unselectedLabelColor: black300,
                tabs: const [
                  Tab(text: 'Yaklaşan'),
                  Tab(text: 'Geçmiş'),
                  Tab(text: 'Tümü'),
                ],
                onTap: (_) => setState(() {}),
              ),
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
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: TabBarView(
                    controller: _tab,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildList(_filtered(0)),
                      _buildList(_filtered(1)),
                      _buildList(_filtered(2)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildList(List<Appointment> list) {
    if (list.isEmpty) {
      return _EmptyState(onCreate: () {
        if (!mounted) return;
        Navigator.pushNamed(context, 'randevu_al');
      });
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(padding20, padding20, padding20, 120),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = list[i];
        return _AppointmentCard(
          item: item,
          onCancel: (item.status == AppointmentStatus.pending ||
                  item.status == AppointmentStatus.confirmed)
              ? () async {
                  await widget.repo.cancelAppointment(item.id);

                  // await sonrası State.context kullan => mounted ile koru
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Randevu iptal edildi')),
                  );
                }
              : null,
          onReschedule: (item.status == AppointmentStatus.pending ||
                  item.status == AppointmentStatus.confirmed)
              ? () async {
                  // State.context'i kullanıyoruz
                  final picked = await showDatePicker(
                    context: this.context,
                    initialDate: item.dateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  // await sonrası tekrar kontrol et
                  if (!mounted) return;

                  if (picked != null) {
                    await widget.repo.rescheduleAppointment(item.id, picked);

                    // tekrar await => tekrar kontrol
                    if (!mounted) return;

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Randevu güncellendi')),
                    );
                  }
                }
              : null,
          onViewService: () {
            // Servis detay sayfası eklenince route’a git
            // Navigator.pushNamed(context, 'service_detail', arguments: item.serviceId);
          },
        );
      },
    );
  }
}

/// =======================
/// WIDGETS
/// =======================
class _AppointmentCard extends StatefulWidget {
  final Appointment item;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onViewService;

  const _AppointmentCard({
    required this.item,
    this.onCancel,
    this.onReschedule,
    this.onViewService,
  });

  @override
  State<_AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> {
  bool _expanded = false;

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

  String _fmtDateTime(DateTime dt) {
    final d =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d • $t';
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.item;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(br15),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Üst satır
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // plaka kutusu
                  Container(
                    width: 92,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: white300,
                      borderRadius: BorderRadius.circular(br8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          it.plate,
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
                          it.vehicleModel,
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
                          it.serviceName,
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
                                it.cityDistrict,
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
                              '${it.distanceKm.toStringAsFixed(1)} km',
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
                              _fmtDateTime(it.dateTime),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(it.status).withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statusColor(it.status)),
                    ),
                    child: Text(
                      _statusText(it.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(it.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Marka etiketleri
              if (it.brandTags.isNotEmpty)
                SizedBox(
                  height: 24,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: it.brandTags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) => _BrandTag(it.brandTags[i]),
                  ),
                ),

              // Genişleyen detay
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      if (it.hasTow)
                        const _InfoRow(
                          icon: reviz_icons.Icons(name: 'game-icons-tow-truck'),
                          label: 'Araç Sevk Hizmeti',
                          value: 'Aktif',
                        ),
                      if ((it.note ?? '').isNotEmpty)
                        _InfoRow(
                          icon: const reviz_icons.Icons(name: 'ClipboardText'),
                          label: 'Açıklama',
                          value: it.note!,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onViewService,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: greenyellow300),
                                foregroundColor: black500,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(br6),
                                ),
                              ),
                              child: const Text('Servisi İncele'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.onReschedule != null)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onReschedule,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: greenyellow300,
                                  foregroundColor: black500,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(br6),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('Saat/Tarih Değiştir'),
                              ),
                            ),
                          if (widget.onCancel != null) const SizedBox(width: 8),
                          if (widget.onCancel != null)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onCancel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFEBEE),
                                  foregroundColor: const Color(0xFFD32F2F),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(br6),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('İptal Et'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),

              // Expand ikon
              Align(
                alignment: Alignment.center,
                child: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: black300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandTag extends StatelessWidget {
  final String text;
  const _BrandTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26, width: 0.8),
        borderRadius: BorderRadius.circular(br5),
        color: white300,
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontFamily: 'Roboto Flex',
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: black500,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 18, height: 18, child: icon),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontSize: fs12,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: black500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: fs12,
                      fontFamily: 'Roboto Flex',
                      height: 1.2,
                      color: black600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Center(
          child: Column(
            children: [
              SizedBox(height: 12),
              Text(
                'Henüz randevun yok',
                style: TextStyle(
                  fontSize: fs16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  height: 1.19,
                  color: black500,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Hızlıca bir randevu oluştur ve servislerden destek al.',
                style: TextStyle(
                  fontSize: fs12,
                  fontFamily: 'Roboto Flex',
                  height: 1.2,
                  color: black300,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: padding20),
          child: ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: gray1200,
              foregroundColor: white100,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(br6),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Randevu Al',
              style: TextStyle(
                fontSize: fs16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 1.19,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
