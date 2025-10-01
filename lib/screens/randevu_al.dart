// lib/screens/randevu_al.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:reviz_develop/widgets/icons.dart' as reviz_icons;
import 'package:reviz_develop/widgets/job_date_and_time.dart';
// Eğer Supabase kullanıyorsan (opsiyonel – yoksa yoruma al)
// import 'package:supabase_flutter/supabase_flutter.dart';

enum RandevuAdimi {
  aracVeHizmet,
  konumaUygunServisler,
  onerilenServisler,
  sevkHizmeti
}

class AppointmentRequest {
  String? plate;
  String? vehicleModel;
  String serviceType; // "Onarım" | "Bakım" | "Ekspertiz"
  String? address;
  String? note;
  DateTime? preferredDate; // JobDateAndTime veya seçilen tarih
  String? timeSlot; // "Sabah 9:00-12:00" vb.
  String? serviceId; // seçilen servis
  String? towType; // Sevk seçimi
  double? towPrice;
  List<String> imageUrls;

  AppointmentRequest({
    this.plate,
    this.vehicleModel,
    required this.serviceType,
    this.address,
    this.note,
    this.preferredDate,
    this.timeSlot,
    this.serviceId,
    this.towType,
    this.towPrice,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];
}

// Basit backend stub (Supabase/REST bağlamak için hazır)
class AppointmentRepository {
  // final SupabaseClient supabase = Supabase.instance.client;

  Future<String> uploadFileToStorage(File file) async {
    // TODO: Supabase Storage’a yükleme
    await Future.delayed(const Duration(milliseconds: 300));
    return 'https://example.com/${file.path.split('/').last}';
  }

  Future<void> createAppointment(AppointmentRequest req) async {
    // TODO: Supabase RPC/REST’e gönder
    await Future.delayed(const Duration(milliseconds: 400));
  }
}

class RandevuAlPage extends StatefulWidget {
  const RandevuAlPage({super.key, this.onCreatedNavigateTo = 'appointments'});
  final String onCreatedNavigateTo; // <— varsa route’ta kullanabilirsin
  @override
  State<RandevuAlPage> createState() => _RandevuAlPageState();
}

class _RandevuAlPageState extends State<RandevuAlPage> {
  final _repo = AppointmentRepository();
  final _picker = ImagePicker();

  // State
  RandevuAdimi _step = RandevuAdimi.aracVeHizmet;

  // Araç & Hizmet
  final String? _selectedPlate = '34 BAK 81';
  final String? _selectedVehicleModel = 'CBR-650';
  String _serviceType = 'Onarım'; // default
  // Konum & servis önerileri
  String? _selectedServiceId; // "duha-motobike" gibi.
  // Tarih & saat
  DateTime? _selectedDate;
  String? _selectedTimeSlot; // "Sabah 9:00 - 12:00" vb.
  // Adres & not
  String? _address;
  String? _note;
  // Görseller
  final List<File> _pickedImages = [];
  // Sevk Hizmeti
  String? _towType; // "Kendim Bırak - Teslim Alacağım" vb.
  double? _towPrice;

  bool _submitting = false;

  void _goNext([RandevuAdimi? to]) {
    setState(() {
      if (to != null) {
        _step = to;
        return;
      }
      switch (_step) {
        case RandevuAdimi.aracVeHizmet:
          _step = RandevuAdimi.konumaUygunServisler;
          break;
        case RandevuAdimi.konumaUygunServisler:
          _step = RandevuAdimi.onerilenServisler;
          break;
        case RandevuAdimi.onerilenServisler:
          _step = RandevuAdimi.sevkHizmeti;
          break;
        case RandevuAdimi.sevkHizmeti:
          break;
      }
    });
  }

  void _goBack() {
    setState(() {
      switch (_step) {
        case RandevuAdimi.aracVeHizmet:
          Navigator.pop(context);
          break;
        case RandevuAdimi.konumaUygunServisler:
          _step = RandevuAdimi.aracVeHizmet;
          break;
        case RandevuAdimi.onerilenServisler:
          _step = RandevuAdimi.konumaUygunServisler;
          break;
        case RandevuAdimi.sevkHizmeti:
          _step = RandevuAdimi.onerilenServisler;
          break;
      }
    });
  }

  Future<void> _pickImages() async {
    final result = await _picker.pickMultiImage(imageQuality: 80);
    // ignore: unnecessary_null_comparison
    if (result != null && result.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(result.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _submit() async {
    // Alan kontrolleri
    if (_selectedPlate == null ||
        _serviceType.isEmpty ||
        _selectedServiceId == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null ||
        _address == null ||
        (_note == null || _note!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen zorunlu alanları doldurun.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // Görselleri yükle
      final urls = <String>[];
      for (final f in _pickedImages) {
        final url = await _repo.uploadFileToStorage(f);
        urls.add(url);
      }

      final req = AppointmentRequest(
        plate: _selectedPlate,
        vehicleModel: _selectedVehicleModel,
        serviceType: _serviceType,
        address: _address,
        note: _note,
        preferredDate: _selectedDate,
        timeSlot: _selectedTimeSlot,
        serviceId: _selectedServiceId,
        towType: _towType,
        towPrice: _towPrice,
        imageUrls: urls,
      );

      await _repo.createAppointment(req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Randevu alındı!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Randevu Al';
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5FD),
        appBar: AppBar(
          title: const Text(
            title,
            style: TextStyle(
              fontSize: fs22,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w700,
              height: 1.23,
              color: gray1200,
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: padding20),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _goBack,
              child: const SizedBox(width: width24, height: height24),
            ),
          ),
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(br30),
              topRight: Radius.circular(br30),
            ),
            color: ghostwhite,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              if (_step == RandevuAdimi.aracVeHizmet)
                _Step0AracVeHizmet(
                  selectedPlate: _selectedPlate,
                  vehicleModel: _selectedVehicleModel,
                  onServiceTypeChanged: (v) => setState(() => _serviceType = v),
                  serviceType: _serviceType,
                  onOpenKonumaUygun: () =>
                      _goNext(RandevuAdimi.konumaUygunServisler),
                  onOpenOnerilen: () => _goNext(RandevuAdimi.onerilenServisler),
                  onOpenSevk: () => _goNext(RandevuAdimi.sevkHizmeti),
                  onPickImages: _pickImages,
                  pickedImages: _pickedImages,
                  onAddressTap: () async {
                    // TODO: Adres seçimi ekranına yönlendirme/Sheet
                    setState(() => _address = 'Sancaktepe/İstanbul');
                  },
                  onNoteTap: () async {
                    final note = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => _NoteSheet(initial: _note),
                    );
                    if (note != null) setState(() => _note = note);
                  },
                  // SAAT alt sheet ile seçiliyor (aynen tuttuğumuz işlev)
                  onTimeTap: () async {
                    final slot =
                        await _pickTimeSlot(context, _selectedTimeSlot);
                    if (slot != null) setState(() => _selectedTimeSlot = slot);
                  },
                  // SAYFA İÇİNDE TARİH SEÇİMİ → JobDateAndTime ile (AŞAĞIDA)
                  selectedDate: _selectedDate,
                  onInlineDateChanged: (d) => setState(() => _selectedDate = d),
                ),
              if (_step == RandevuAdimi.konumaUygunServisler)
                _Step1KonumaUygun(
                  selectedPlate: _selectedPlate,
                  vehicleModel: _selectedVehicleModel,
                  onSelectService: (id) {
                    setState(() => _selectedServiceId = id);
                    _goNext(RandevuAdimi.onerilenServisler);
                  },
                  selectedDate:
                      _selectedDate ?? DateTime.now(), // non-null gönder
                  onDateChanged: (d) =>
                      setState(() => _selectedDate = d), // strip seçimlerini al
                  onDateTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
              if (_step == RandevuAdimi.onerilenServisler)
                _Step2OnerilenServisler(
                  onSelectService: (id) {
                    setState(() => _selectedServiceId = id);
                    _goNext(RandevuAdimi.sevkHizmeti);
                  },
                ),
              if (_step == RandevuAdimi.sevkHizmeti)
                _Step3SevkHizmeti(
                  onSelectTow: (type, price) {
                    setState(() {
                      _towType = type;
                      _towPrice = price;
                    });
                  },
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: gray1200,
                  foregroundColor: white100,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(br6)),
                  ),
                  minimumSize: const Size(335, 52),
                  elevation: 0,
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: white100))
                    : const Text(
                        "Randevu Al",
                        style: TextStyle(
                          fontSize: fs16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 1.19,
                          letterSpacing: -0.18,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _pickTimeSlot(BuildContext context, String? current) async {
    const slots = [
      'Sabah 9:00 - 12:00',
      'Öğlen 13:00 - 16:00',
      'Akşam 16:00 - 19:00',
    ];
    return await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: slots
            .map((s) => ListTile(
                  title: Text(s),
                  trailing: current == s ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, s),
                ))
            .toList(),
      ),
    );
  }
}

// === Adım 0: Araçlarım + Hizmet + Kısa kısayollar ===
class _Step0AracVeHizmet extends StatelessWidget {
  final String? selectedPlate;
  final String? vehicleModel;
  final String serviceType;
  final void Function(String) onServiceTypeChanged;
  final VoidCallback onOpenKonumaUygun;
  final VoidCallback onOpenOnerilen;
  final VoidCallback onOpenSevk;
  final VoidCallback onPickImages;
  final List<File> pickedImages;
  final VoidCallback onAddressTap;
  final VoidCallback onNoteTap;
  final VoidCallback onTimeTap;

  // inline tarih seçimi için
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onInlineDateChanged;

  const _Step0AracVeHizmet({
    required this.selectedPlate,
    required this.vehicleModel,
    required this.serviceType,
    required this.onServiceTypeChanged,
    required this.onOpenKonumaUygun,
    required this.onOpenOnerilen,
    required this.onOpenSevk,
    required this.onPickImages,
    required this.pickedImages,
    required this.onAddressTap,
    required this.onNoteTap,
    required this.onTimeTap,
    required this.selectedDate,
    required this.onInlineDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Başlık ve araç kartları
        const Row(
          children: [
            SizedBox(
              width: width26,
              height: height18,
              child: Image(image: AssetImage('assets/Vector3@2x.png')),
            ),
            SizedBox(width: 8),
            Text(
              'Araçlarım',
              style: TextStyle(
                fontSize: fs22,
                fontFamily: 'Roboto Flex',
                fontWeight: FontWeight.w600,
                height: 1.23,
                color: black500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _VehicleCard(
                topIcon: const AssetImage('assets/image-31@2x.png'),
                plate: selectedPlate ?? '',
                model: vehicleModel ?? '',
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: _VehicleCard(
                // sağdaki boş placeholder kart (eskinin ikinci kartı)
                topIcon: null,
                plate: '',
                model: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Hizmet Türü Seçiniz',
            style: TextStyle(
              fontSize: fs22,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w600,
              height: 1.23,
              letterSpacing: -0.05,
              color: black500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ServicePill(
              label: 'Onarım',
              selected: serviceType == 'Onarım',
              asset: 'assets/Group-4273218681@2x.png',
              onTap: () => onServiceTypeChanged('Onarım'),
            ),
            _ServicePill(
              label: 'Bakım',
              selected: serviceType == 'Bakım',
              onTap: () => onServiceTypeChanged('Bakım'),
            ),
            _ServicePill(
              label: 'Ekspertiz',
              selected: serviceType == 'Ekspertiz',
              onTap: () => onServiceTypeChanged('Ekspertiz'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Kısayollar (Konumuna uygun servisler / Önerilen / Sevk / Adresim / Not / Görsel Ekle)
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "MapPinLine"),
          label: 'Konumuna Uygun Servisler',
          onTap: onOpenKonumaUygun,
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const SizedBox(
              width: width25, height: height23), // boş ikonlu görünüm
          label: 'Önerilen Servisler',
          onTap: onOpenOnerilen,
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const SizedBox(width: width25, height: height25),
          label: 'Araç Sevk Hizmeti Seçiniz',
          onTap: onOpenSevk,
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "MapPinLine"),
          label: 'Adresim',
          onTap: onAddressTap,
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "ClipboardText"),
          label: 'Talep - Açıklama Ekle (Zorunlu)',
          onTap: onNoteTap,
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "Image"),
          label: 'Görsel Ekle (İsteğe Bağlı)',
          onTap: onPickImages,
        ),
        if (pickedImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pickedImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(br8),
                child: Image.file(pickedImages[i],
                    width: 80, height: 80, fit: BoxFit.cover),
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // === SAYFA İÇİ TARİH SEÇİMİ ===
        JobDateAndTime(
          selectedDate: selectedDate,
          onDateChanged: onInlineDateChanged,
        ),
        const SizedBox(height: 10),

        // Saat seçim butonu (aynen koruduk)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: gainsboro, width: 0.9),
                  backgroundColor: white300,
                  minimumSize: const Size(0, 48),
                ),
                onPressed: onTimeTap,
                child: const Text(
                  'Saat Aralığı',
                  style: TextStyle(
                    fontSize: fs13,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: ls041,
                    color: gray100,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final AssetImage? topIcon;
  final String plate;
  final String model;
  const _VehicleCard({this.topIcon, required this.plate, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: const BoxDecoration(
        color: white300,
        borderRadius: BorderRadius.all(Radius.circular(br8)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (topIcon != null)
            Align(
              alignment: Alignment.topRight,
              child: Image(
                  image: topIcon!, width: 42, height: 34, fit: BoxFit.contain),
            ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              plate,
              style: const TextStyle(
                fontSize: fs109,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 1.19,
                letterSpacing: -0.44,
                color: black500,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              model,
              style: const TextStyle(
                fontSize: fs109,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 1.19,
                color: black600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? asset;
  const _ServicePill(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.asset});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(97),
      onTap: onTap,
      child: Container(
        width: 102,
        height: 102,
        decoration: BoxDecoration(
          color: selected ? dimgray100 : white300,
          borderRadius: const BorderRadius.all(Radius.circular(br97)),
        ),
        padding: const EdgeInsets.fromLTRB(26, 16, 26, 17),
        child: Column(
          children: [
            if (asset != null)
              Image(
                  image: AssetImage(asset!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: fs117,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: black500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LavenderButton extends StatelessWidget {
  final Widget leading;
  final String label;
  final VoidCallback onTap;
  const _LavenderButton({
    required this.leading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: lavender,
      borderRadius: BorderRadius.circular(br5),
      child: InkWell(
        borderRadius: BorderRadius.circular(br5),
        onTap: onTap,
        child: Container(
          height: 53,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: fs14,
                    fontFamily: 'Roboto Flex',
                    height: 1.14,
                    color: black500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === Adım 1: Konumuna Uygun Servisler ===
class _Step1KonumaUygun extends StatelessWidget {
  final String? selectedPlate;
  final String? vehicleModel;
  final void Function(String serviceId) onSelectService;
  final DateTime selectedDate; // non-null
  final ValueChanged<DateTime> onDateChanged; // yeni param
  final VoidCallback onDateTap;

  const _Step1KonumaUygun({
    required this.selectedPlate,
    required this.vehicleModel,
    required this.onSelectService,
    required this.selectedDate, // eklendi
    required this.onDateChanged, // eklendi
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const SizedBox(
          width: width335,
          height: 250,
          child: Image(
            image: AssetImage('assets/image-29@2x.png'),
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            SizedBox(
              width: width26,
              height: height18,
              child: Image(image: AssetImage('assets/Vector3@2x.png')),
            ),
            SizedBox(width: 8),
            Text(
              'Araçlarım',
              style: TextStyle(
                fontSize: fs22,
                fontFamily: 'Roboto Flex',
                fontWeight: FontWeight.w600,
                height: 1.23,
                color: black500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _VehicleCard(
                topIcon: const AssetImage('assets/image-31@2x.png'),
                plate: selectedPlate ?? '',
                model: vehicleModel ?? '',
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
                child: _VehicleCard(plate: '', model: '', topIcon: null)),
          ],
        ),
        const SizedBox(height: 12),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Hizmet Türü Seçiniz',
            style: TextStyle(
              fontSize: fs22,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w600,
              height: 1.23,
              letterSpacing: -0.05,
              color: black500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ServicePill(
              label: 'Onarım',
              selected: true,
              onTap: () {},
              asset: 'assets/Group-4273218681@2x.png',
            ),
            _ServicePill(
              label: 'Bakım',
              selected: false,
              onTap: () {},
            ),
            _ServicePill(
              label: 'Ekspertiz',
              selected: false,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),

        _LavenderButton(
          leading: const reviz_icons.Icons(name: "MapPinLine"),
          label: 'Konumuna Uygun Servisler',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const SizedBox(width: width25, height: height23),
          label: 'Önerilen Servisler',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 25,
          decoration: const BoxDecoration(
            color: greenyellow200,
            borderRadius: BorderRadius.all(Radius.circular(br5)),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: const Text(
            'Sancaktepe-İstanbul',
            style: TextStyle(
              fontSize: fs10,
              fontFamily: 'Roboto Flex',
              height: 0.8,
              color: black500,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Servis kartı
        _ServiceCardBig(
          imageAsset: 'assets/mage1@2x.png',
          name: 'Duha Motobike',
          location: 'Sancaktepe/İstanbul',
          distance: '1.2 km',
          rating: 4.8,
          ratingCount: 15,
          brandBadges: const ['KUBA', 'VOLTA', 'ARORA'],
          onInspect: () {},
          onPick: () => onSelectService('duha-motobike'),
        ),

        const SizedBox(height: 12),

        // === SAYFA İÇİ TARİH SEÇİMİ (Step1 içinde de) ===
        JobDateAndTime(
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: gainsboro, width: 0.9),
            backgroundColor: white300,
            minimumSize: const Size(0, 48),
          ),
          onPressed: () {},
          child: Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(
              fontSize: fs13,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: ls041,
              color: gray100,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceCardBig extends StatelessWidget {
  final String imageAsset;
  final String name;
  final String location;
  final String distance;
  final double rating;
  final int ratingCount;
  final List<String> brandBadges;
  final VoidCallback onInspect;
  final VoidCallback onPick;

  const _ServiceCardBig({
    required this.imageAsset,
    required this.name,
    required this.location,
    required this.distance,
    required this.rating,
    required this.ratingCount,
    required this.brandBadges,
    required this.onInspect,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(br15),
          child: Column(
            children: [
              Image.asset(imageAsset,
                  width: double.infinity, height: 120, fit: BoxFit.cover),
              Container(
                color: white300,
                padding: const EdgeInsets.fromLTRB(13, 4, 13, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                          fontSize: fs12,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w600,
                          height: 1.17,
                          color: black500,
                        )),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(location,
                            style: const TextStyle(
                              fontSize: fs8,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.13,
                              color: black200,
                            )),
                        const Spacer(),
                        Text(distance,
                            style: const TextStyle(
                              fontSize: fs8,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.13,
                              color: black200,
                            )),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        _Badge('KUBA', background: red, borderColor: crimson),
                        SizedBox(width: 6),
                        _Badge('VOLTA',
                            background: forestgreen100,
                            borderColor: forestgreen200),
                        SizedBox(width: 6),
                        _Badge('ARORA',
                            background: black100,
                            borderColor: black500,
                            wide: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenyellow300,
                            foregroundColor: black500,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(br20)),
                            ),
                            minimumSize: const Size(60, 21),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          onPressed: onInspect,
                          child: const Text(
                            'Servisi İncele',
                            style: TextStyle(
                              fontSize: fs6,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenyellow300,
                            foregroundColor: black500,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(br20)),
                            ),
                            minimumSize: const Size(60, 21),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          onPressed: onPick,
                          child: const Text(
                            'Randevu Al',
                            style: TextStyle(
                              fontSize: fs6,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 86,
          right: 0,
          child: Container(
            height: 20,
            padding: const EdgeInsets.fromLTRB(9, 5, 5, 4),
            decoration: const BoxDecoration(
              color: white300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(br10),
                bottomLeft: Radius.circular(br10),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10, height: 10),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: fs7,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.57,
                    color: sandybrown,
                  ),
                ),
                Text(
                  '($ratingCount)',
                  style: const TextStyle(
                    fontSize: fs7,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.57,
                    color: darkslateblue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color background;
  final Color borderColor;
  final bool wide;
  const _Badge(this.text,
      {required this.background, required this.borderColor, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 19 : 16,
      height: 12,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(br5),
        border: Border.all(color: borderColor, width: 0.2),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: fs5,
            fontFamily: 'Roboto Flex',
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: black500,
          ),
        ),
      ),
    );
  }
}

class _NoteSheet extends StatefulWidget {
  final String? initial;
  const _NoteSheet({this.initial});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Talep - Açıklama',
              style: TextStyle(
                fontSize: fs16,
                fontFamily: 'Roboto Flex',
                fontWeight: FontWeight.w600,
                color: black500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _c,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Arıza/İstek detayını yazın...',
              filled: true,
              fillColor: white300,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(br8))),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _c.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: gray1200,
                foregroundColor: white100,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(br6)),
                ),
              ),
              child: const Text('Kaydet'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// === Adım 2: Önerilen Servisler (eski RandevuAl2) ===
class _Step2OnerilenServisler extends StatelessWidget {
  final void Function(String id) onSelectService;
  const _Step2OnerilenServisler({required this.onSelectService});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SmallServiceCard(
                onPick: () => onSelectService('duha-1'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SmallServiceCard(
                onPick: () => onSelectService('duha-2'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LavenderButton(
          leading: const SizedBox(width: width25, height: height25),
          label: 'Araç Sevk Hizmeti Seçiniz',
          onTap: () => onSelectService('duha-1'),
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "MapPinLine"),
          label: 'Adresim',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "ClipboardText"),
          label: 'Talep - Açıklama Ekle (Zorunlu)',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "Image"),
          label: 'Görsel Ekle (İsteğe Bağlı)',
          onTap: () {},
        ),
      ],
    );
  }
}

class _SmallServiceCard extends StatelessWidget {
  final VoidCallback onPick;
  const _SmallServiceCard({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(br15),
          child: Column(
            children: [
              const SizedBox(width: 200, height: 110),
              Container(
                color: white300,
                padding: const EdgeInsets.fromLTRB(13, 4, 13, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Duha Motobike',
                        style: TextStyle(
                          fontSize: fs12,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w600,
                          height: 1.17,
                          color: black500,
                        )),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Text('Sancaktepe/İstanbul',
                            style: TextStyle(
                              fontSize: fs8,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.13,
                              color: black200,
                            )),
                        Spacer(),
                        Text('1.2 km',
                            style: TextStyle(
                              fontSize: fs8,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.13,
                              color: black200,
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        _Badge('KUBA', background: red, borderColor: crimson),
                        SizedBox(width: 6),
                        _Badge('VOLTA',
                            background: forestgreen100,
                            borderColor: forestgreen200),
                        SizedBox(width: 6),
                        _Badge('ARORA',
                            background: black100,
                            borderColor: black500,
                            wide: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenyellow300,
                            foregroundColor: black500,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(br20)),
                            ),
                            minimumSize: const Size(60, 21),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Servisi İncele',
                            style: TextStyle(
                              fontSize: fs6,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenyellow300,
                            foregroundColor: black500,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(br20)),
                            ),
                            minimumSize: const Size(60, 21),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          onPressed: onPick,
                          child: const Text(
                            'Randevu Al',
                            style: TextStyle(
                              fontSize: fs6,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 86,
          right: 0,
          child: Container(
            height: 20,
            padding: const EdgeInsets.fromLTRB(9, 5, 5, 4),
            decoration: const BoxDecoration(
              color: white300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(br10),
                bottomLeft: Radius.circular(br10),
              ),
            ),
            child: const Text(
              '4.8(15)',
              style: TextStyle(
                fontSize: fs7,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 1.57,
                color: sandybrown,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// === Adım 3: Araç Sevk Hizmeti Seçimi ===
class _Step3SevkHizmeti extends StatelessWidget {
  final void Function(String type, double price) onSelectTow;
  const _Step3SevkHizmeti({required this.onSelectTow});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TowOptionCard(
          title: 'Kendim Bırak-Teslim Alacağım',
          desc:
              'Araç randevu adresine kullanıcı tarafından getirilir, işlemler bittiğinde kullanıcı teslim alır.',
          badgeText: 'Ücretsiz',
          badgeColor: darkorange,
          priceText: '0.00 TL',
          onTap: () => onSelectTow('Kendim Bırak-Teslim Alacağım', 0),
        ),
        const SizedBox(height: 8),
        _TowOptionCard(
          title: 'Aracım Sadece Teslim Alınsın',
          desc:
              'Araç randevu adresine servis tarafından getirilir, işlemler bittiğinde kullanıcı aracını servisten teslim alır.',
          badgeText: 'Ücretli',
          badgeColor: darkolivegreen,
          priceText: '150.00 TL',
          onTap: () => onSelectTow('Sadece Teslim Alınsın', 150),
        ),
        const SizedBox(height: 8),
        _TowOptionCard(
          title: 'Aracım Teslim Alınsın-Edilsin',
          desc:
              'Araç randevu adresine servis tarafından getirilir, işlemler bittiğinde araç seçilen adrese servis tarafından teslim edilir',
          badgeText: 'Ücretli',
          badgeColor: darkolivegreen,
          priceText: '300.00 TL',
          onTap: () => onSelectTow('Teslim Alınsın-Edilsin', 300),
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "MapPinLine"),
          label: 'Adresim',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "ClipboardText"),
          label: 'Talep - Açıklama Ekle (Zorunlu)',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _LavenderButton(
          leading: const reviz_icons.Icons(name: "Image"),
          label: 'Görsel Ekle (İsteğe Bağlı)',
          onTap: () {},
        ),
      ],
    );
  }
}

class _TowOptionCard extends StatelessWidget {
  final String title;
  final String desc;
  final String badgeText;
  final Color badgeColor;
  final String priceText;
  final VoidCallback onTap;

  const _TowOptionCard({
    required this.title,
    required this.desc,
    required this.badgeText,
    required this.badgeColor,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white300,
      borderRadius: BorderRadius.circular(br8),
      child: InkWell(
        borderRadius: BorderRadius.circular(br8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: fs12,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: black500,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: fs10,
                        fontFamily: 'Roboto Flex',
                        height: 1.2,
                        color: black600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(17, 6, 17, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(br30),
                      border: Border.all(color: badgeColor, width: 1),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: fs12,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w500,
                        height: 1.17,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceText,
                    style: const TextStyle(
                      fontSize: fs12,
                      fontFamily: 'Roboto Flex',
                      height: 1.23,
                      letterSpacing: -0.11,
                      color: black300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
