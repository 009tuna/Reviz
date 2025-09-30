import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services_repository.dart';
import '../models/service.dart';

class RecommendedServicesPage extends StatefulWidget {
  final String userId;
  final String vehicleId;
  final String serviceType; // 'onarim' | 'bakim' | 'ekspertiz'
  const RecommendedServicesPage({
    super.key,
    required this.userId,
    required this.vehicleId,
    required this.serviceType,
  });

  @override
  State<RecommendedServicesPage> createState() =>
      _RecommendedServicesPageState();
}

class _RecommendedServicesPageState extends State<RecommendedServicesPage> {
  late final ServicesRepository repo;
  List<Service> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    repo = ServicesRepository(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      items = await repo.fetchRecommended(
        userId: widget.userId,
        vehicleId: widget.vehicleId,
        serviceType: widget.serviceType,
      );
    } catch (_) {
      items = [];
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5FD),
        appBar: AppBar(
          title: const Text(
            'Önerilen Servisler',
            style: TextStyle(
              fontSize: fs22,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w700,
              height: 1.23,
              color: gray1200,
            ),
          ),
          centerTitle: true,
          backgroundColor: white300,
          toolbarHeight: height100,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(br30),
              topRight: Radius.circular(br30),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: padding20),
            decoration: const BoxDecoration(
              color: ghostwhite,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(br30),
                bottomRight: Radius.circular(br30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: padding16),
                // Başlık şeridi (senin UI’ya uygun)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: padding20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Araçlarım'),
                      const SizedBox(height: gap8),
                      Row(
                        children: [
                          _plateCard(
                              plate: '34 BAK 81',
                              subtitle: 'CBR-650',
                              logoAsset: 'assets/image-31@2x.png'),
                          const SizedBox(width: gap8),
                          _addVehicleCard(), // boş kart
                        ],
                      ),
                      const SizedBox(height: gap16),
                      const Text(
                        'Hizmet Türü Seçiniz',
                        style: TextStyle(
                          fontSize: fs22,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w600,
                          height: 1.23,
                          color: black500,
                        ),
                      ),
                      const SizedBox(height: gap8),
                      Row(
                        children: [
                          _serviceTypePill(
                              label: 'Onarım',
                              selected: widget.serviceType == 'onarim',
                              iconAsset: 'assets/Group-4273218681@2x.png'),
                          const SizedBox(width: 14.5),
                          _serviceTypePill(
                              label: 'Bakım',
                              selected: widget.serviceType == 'bakim'),
                          const SizedBox(width: 14.5),
                          _serviceTypePill(
                              label: 'Ekspertiz',
                              selected: widget.serviceType == 'ekspertiz'),
                        ],
                      ),
                      const SizedBox(height: gap12),
                      // “Önerilen Servisler” şeridi
                      _infoStrip(icon: null, text: 'Önerilen Servisler'),
                      const SizedBox(height: gap6),
                      _infoStrip(
                          icon: 'assets/Vector-211@2x.png',
                          text: 'Sancaktepe-İstanbul',
                          bg: greenyellow200),
                    ],
                  ),
                ),
                const SizedBox(height: gap12),

                // Liste
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  const _EmptyRecommended()
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: padding20),
                    itemBuilder: (_, i) => _RecommendedCard(
                      service: items[i],
                      onInspect: () =>
                          Navigator.pop(context, items[i]), // Servisi seç
                      onBook: () => Navigator.pop(
                          context, items[i]), // veya direkt randevuya dön
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: gap12),
                    itemCount: items.length,
                  ),

                const SizedBox(height: gap16),
                // Alt aksiyonlar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: padding20),
                  child: Column(
                    children: [
                      _actionTile(
                          iconAsset: 'assets/game-icons-tow-truck@2x.png',
                          text: 'Araç Sevk Hizmeti Seçiniz',
                          onTap: () {
                            Navigator.pushNamed(context, 'randevu_al_3');
                          }),
                      const SizedBox(height: gap7),
                      _actionTile(
                          iconAsset: 'assets/MapPinLine-1@2x.png',
                          text: 'Adresim',
                          onTap: () {}),
                      const SizedBox(height: gap7),
                      _actionTile(
                          iconAsset: 'assets/ClipboardText1@2x.png',
                          text: 'Talep - Açıklama Ekle (Zorunlu)',
                          onTap: () {}),
                      const SizedBox(height: gap7),
                      _actionTile(
                          iconAsset: 'assets/Image@2x.png',
                          text: 'Görsel Ekle (İsteğe Bağlı)',
                          onTap: () {}),
                      const SizedBox(height: gap16),
                      SizedBox(
                        width: width335,
                        height: height52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gray1200,
                            foregroundColor: white100,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(br6)),
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text('Randevu Al',
                              style: TextStyle(
                                  fontSize: fs16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- küçük UI yardımcıları ---

  Widget _sectionLabel(String t) => Row(
        children: [
          const SizedBox(width: width26, height: height18),
          Text(t,
              style: const TextStyle(
                  fontSize: fs22,
                  fontFamily: 'Roboto Flex',
                  fontWeight: FontWeight.w600,
                  color: black500)),
        ],
      );

  Widget _plateCard(
      {required String plate, required String subtitle, String? logoAsset}) {
    return Container(
      width: 160,
      height: 86,
      decoration: BoxDecoration(
          color: white300, borderRadius: BorderRadius.circular(br8)),
      padding: const EdgeInsets.fromLTRB(padding16, 12, 16, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
                width: 42.4,
                height: 34,
                child: (logoAsset == null)
                    ? const SizedBox()
                    : Image.asset(logoAsset, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 6),
          Text(plate,
              style: const TextStyle(
                  fontSize: fs109,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: black500)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: fs109,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: black600)),
        ],
      ),
    );
  }

  Widget _addVehicleCard() {
    return Container(
      width: 160,
      height: 86,
      decoration: BoxDecoration(
          color: white300, borderRadius: BorderRadius.circular(br8)),
      child: const Center(
          child: Image(image: AssetImage('assets/Group-20334@2x.png'))),
    );
  }

  Widget _serviceTypePill(
      {required String label, required bool selected, String? iconAsset}) {
    final bg = selected ? dimgray100 : white300;
    return Container(
      width: width102,
      height: height102,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(br97)),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAsset != null) Image.asset(iconAsset, width: 50, height: 50),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: fs117,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: black500)),
        ],
      ),
    );
  }

  Widget _infoStrip({String? icon, required String text, Color bg = lavender}) {
    return Container(
      width: width335,
      height: 25,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(br5)),
      padding: const EdgeInsets.symmetric(horizontal: padding13, vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Image.asset(icon, width: 10, height: 10),
            const SizedBox(width: gap8),
          ],
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: fs10,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w600,
                      color: black500))),
        ],
      ),
    );
  }

  Widget _actionTile(
      {required String iconAsset, required String text, VoidCallback? onTap}) {
    return SizedBox(
      width: width335,
      height: height53,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Image.asset(iconAsset, width: 24, height: 24),
        label: Text(text,
            style: const TextStyle(fontSize: fs14, fontFamily: 'Roboto Flex')),
        style: ElevatedButton.styleFrom(
          backgroundColor: lavender,
          foregroundColor: black500,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(br5)),
          padding: const EdgeInsets.symmetric(
              horizontal: padding12, vertical: padding14),
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final Service service;
  final VoidCallback onInspect;
  final VoidCallback onBook;
  const _RecommendedCard(
      {required this.service, required this.onInspect, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white300,
      borderRadius: BorderRadius.circular(br12),
      child: Padding(
        padding: const EdgeInsets.all(padding12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(br10),
                child: Image.asset(service.heroAsset,
                    height: 110, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: gap8),
            Row(children: [
              Expanded(
                  child: Text(service.name,
                      style: const TextStyle(
                          fontSize: fs12,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w600,
                          color: black500))),
              const SizedBox(width: gap8),
              Text('${service.distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                      fontSize: fs8,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w600,
                      color: black200)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const SizedBox(
                  width: 12,
                  height: 12,
                  child: Image(image: AssetImage('assets/Vector-211@2x.png'))),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(service.district,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: fs8,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w600,
                          color: black200))),
            ]),
            const SizedBox(height: gap6),
            Wrap(
                spacing: 6,
                runSpacing: 6,
                children: service.brands.map((b) => _chip(b)).toList()),
            const SizedBox(height: gap6),
            Row(children: [
              TextButton(
                onPressed: onInspect,
                style: TextButton.styleFrom(
                  backgroundColor: greenyellow300,
                  foregroundColor: black500,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 21),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(br20)),
                ),
                child: const Text('Servisi İncele',
                    style: TextStyle(
                        fontSize: fs6,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: gap10),
              TextButton(
                onPressed: onBook,
                style: TextButton.styleFrom(
                  backgroundColor: greenyellow300,
                  foregroundColor: black500,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 21),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(br20)),
                ),
                child: const Text('Randevu Al',
                    style: TextStyle(
                        fontSize: fs6,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: white300, borderRadius: BorderRadius.circular(br10)),
                child: const Row(children: [
                  Image(
                      image: AssetImage('assets/Star-Icon@2x.png'),
                      width: 12,
                      height: 12),
                  SizedBox(width: 4),
                ]),
              ),
              const SizedBox(width: 4),
              Text(
                  '${service.rating.toStringAsFixed(1)} (${service.ratingCount})',
                  style: const TextStyle(
                      fontSize: fs7,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: sandybrown)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _chip(String brand) {
    Color bg, border;
    switch (brand.toUpperCase()) {
      case 'KUBA':
        bg = red;
        border = crimson;
        break;
      case 'VOLTA':
        bg = forestgreen100;
        border = forestgreen200;
        break;
      case 'ARORA':
        bg = black100;
        border = black500;
        break;
      default:
        bg = lavender;
        border = gainsboro;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(br5),
          border: Border.all(color: border, width: 0.2)),
      child: Text(brand.toUpperCase(),
          style: const TextStyle(
              fontSize: fs5,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w500,
              color: black500)),
    );
  }
}

class _EmptyRecommended extends StatelessWidget {
  const _EmptyRecommended();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(padding20),
      child: Column(
        children: [
          SizedBox(height: 8),
          Text('Öneri bulunamadı',
              style: TextStyle(
                  fontSize: fs16,
                  fontFamily: 'Roboto Flex',
                  fontWeight: FontWeight.w600,
                  color: darkslategray300)),
          SizedBox(height: 6),
          Text('Farklı bir hizmet türü veya araç seçmeyi deneyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fs14, color: darkgray, fontFamily: 'Roboto Flex')),
        ],
      ),
    );
  }
}
