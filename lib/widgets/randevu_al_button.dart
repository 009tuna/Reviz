// lib/screens/randevu_al.dart
import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:reviz_develop/widgets/job_date_and_time.dart';

class RandevuAlPage extends StatefulWidget {
  const RandevuAlPage({super.key, this.onCreatedNavigateTo = 'appointments'});

  /// Randevu başarıyla oluşturulunca gidilecek route adı
  final String onCreatedNavigateTo;

  @override
  State<RandevuAlPage> createState() => _RandevuAlPageState();
}

class _RandevuAlPageState extends State<RandevuAlPage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime; // "10:00" gibi
  ServiceOption? _selectedService;
  final _noteCtrl = TextEditingController();

  // Basit saat slotları (günlük)
  final List<String> _timeSlots = const [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
  ];

  // Şimdilik 2 mock servis – daha sonra services app’ten gelecek
  final List<ServiceOption> _services = const [
    ServiceOption(
      id: 'svc_duha',
      name: 'Duha Motobike',
      address: 'Sancaktepe / İstanbul',
      distanceKm: 1.2,
      rating: 4.8,
    ),
    ServiceOption(
      id: 'svc_city',
      name: 'City Moto',
      address: 'Ümraniye / İstanbul',
      distanceKm: 3.7,
      rating: 4.5,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // (Opsiyonel) RandevuAlButton bu sayfaya 'selectedDate' argümanı gönderdiyse yakala
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['selectedDate'] is DateTime) {
      _selectedDate = args['selectedDate'] as DateTime;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
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
          title: const Text('Randevu Al', style: titleStyle),
          backgroundColor: white300,
          toolbarHeight: height70,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(br30)),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: ghostwhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(br30)),
          ),
          child: ListView(
            padding:
                const EdgeInsets.fromLTRB(padding16, padding16, padding16, 120),
            children: [
              _sectionCard(
                child: JobDateAndTime(
                  // >> JobDateAndTime için GEREKEN parametreler <<
                  selectedDate: _selectedDate,
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                  // alt-üst sınırlar
                  minDate: DateTime.now(),
                  maxDate: DateTime.now().add(const Duration(days: 45)),
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                child: _TimeSlots(
                  slots: _timeSlots,
                  selected: _selectedTime,
                  onChanged: (s) => setState(() => _selectedTime = s),
                ),
              ),
              const SizedBox(height: 12),
              _sectionTitle('Servis Seçimi'),
              const SizedBox(height: 8),
              ..._services.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ServiceCard(
                    option: s,
                    selected: _selectedService?.id == s.id,
                    onTap: () => setState(() => _selectedService = s),
                    onView: () {
                      // “Servisi İncele” – şimdilik mock
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${s.name} detayları yakında.')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _sectionCard(
                child: TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Not (opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text(
                  'Randevu Oluştur',
                  style: TextStyle(
                    fontSize: fs16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gray1200,
                  foregroundColor: white100,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(br8),
                  ),
                  elevation: 0,
                ),
                onPressed: _createAppointment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAppointment() async {
    // Basit doğrulamalar
    if (_selectedService == null) {
      _toast('Lütfen bir servis seçin.');
      return;
    }
    if (_selectedTime == null) {
      _toast('Lütfen bir saat seçin.');
      return;
    }

    // Tarih + saat birleştir
    _selectedTime!.split(':');

    try {
      // TODO: Backend’e bağla
      // Örn:
      // await context.read<AppointmentRepo>().createAppointment(
      //   userId: <currentUserId>,
      //   serviceId: _selectedService!.id,
      //   startsAt: startsAt,
      //   note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      // );

      await Future.delayed(const Duration(milliseconds: 400)); // mock

      if (!mounted) return;
      _toast('Randevu oluşturuldu');
      // Appointments ekranına geç
      Navigator.pushReplacementNamed(context, widget.onCreatedNavigateTo);
    } catch (e) {
      _toast('Bir hata oluştu: $e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: fs16,
            fontFamily: 'Roboto Flex',
            fontWeight: FontWeight.w700,
            color: gray1200,
          ),
        ),
      );

  Widget _sectionCard({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: white300,
          borderRadius: BorderRadius.circular(br12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      );
}

/// --- Modeller / küçük bileşenler ---

class ServiceOption {
  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final double rating;
  const ServiceOption({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.rating,
  });
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.onView,
  });

  final ServiceOption option;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(br12),
      child: Container(
        decoration: BoxDecoration(
          color: white300,
          borderRadius: BorderRadius.circular(br12),
          border: Border.all(color: selected ? greenyellow300 : Colors.black12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Görsel placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(br8),
              ),
              child: const Icon(Icons.home_repair_service),
            ),
            const SizedBox(width: 12),
            // Metinler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: black500,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: black300),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          option.address,
                          style: const TextStyle(fontSize: 12, color: black300),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${option.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 12, color: black300),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        option.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, color: black300),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onView,
                        child: const Text('Servisi İncele'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Seçili işareti
            if (selected)
              const Icon(Icons.check_circle, color: greenyellow300)
            else
              const Icon(Icons.circle_outlined, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _TimeSlots extends StatelessWidget {
  const _TimeSlots({
    required this.slots,
    required this.selected,
    required this.onChanged,
  });

  final List<String> slots;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saat Seçiniz',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((s) {
            final isSel = selected == s;
            return ChoiceChip(
              label: Text(s),
              selected: isSel,
              onSelected: (_) => onChanged(s),
              selectedColor: greenyellow300.withOpacity(.25),
            );
          }).toList(),
        ),
      ],
    );
  }
}
