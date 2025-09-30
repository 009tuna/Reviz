import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:reviz_develop/widgets/icons.dart' as RevizIcons;

/// Basit model (mock)
class ServiceItem {
  final String id;
  final String name;
  final String cityDistrict; // "Sancaktepe/İstanbul"
  final double distanceKm; // 1.2
  final double rating; // 4.8
  final int ratingCount; // 15
  final List<String> brandTags; // ["KUBA","VOLTA","ARORA"]
  final String? coverAsset; // 'assets/duha_cover.png' (opsiyonel)

  const ServiceItem({
    required this.id,
    required this.name,
    required this.cityDistrict,
    required this.distanceKm,
    required this.rating,
    required this.ratingCount,
    required this.brandTags,
    this.coverAsset,
  });
}

/// Mock veri
const _mockServices = <ServiceItem>[
  ServiceItem(
    id: 's1',
    name: 'Duha Motobike',
    cityDistrict: 'Sancaktepe/İstanbul',
    distanceKm: 1.2,
    rating: 4.8,
    ratingCount: 15,
    brandTags: ['KUBA', 'VOLTA', 'ARORA'],
    coverAsset: null, // istersen bir asset koyarsın
  ),
  ServiceItem(
    id: 's2',
    name: 'City Moto',
    cityDistrict: 'Ümraniye/İstanbul',
    distanceKm: 3.7,
    rating: 4.6,
    ratingCount: 22,
    brandTags: ['HONDA', 'YAMAHA'],
    coverAsset: null,
  ),
];

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

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
          title: const Text('Servisler', style: titleStyle),
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
          child: ListView.separated(
            padding:
                const EdgeInsets.fromLTRB(padding20, padding20, padding20, 120),
            itemCount: _mockServices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ServiceCard(item: _mockServices[i]),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(br15),
        color: white300,
        boxShadow: const [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Kapak (mock)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black12,
              alignment: Alignment.center,
              child: item.coverAsset == null
                  ? const Icon(Icons.image, size: 40, color: Colors.black38)
                  : Image.asset(item.coverAsset!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity),
            ),
          ),
          // Alt bilgi & aksiyonlar
          Container(
            padding: const EdgeInsets.fromLTRB(13, 6, 13, 11),
            color: white300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: fs12,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w600,
                    height: 1.17,
                    color: black500,
                  ),
                ),
                const SizedBox(height: 6),
                // Konum & Mesafe
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: RevizIcons.Icons(name: "MapPinLine"),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.cityDistrict,
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
                    const SizedBox(width: 8),
                    Text(
                      '${item.distanceKm.toStringAsFixed(1)} km',
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
                const SizedBox(height: 6),
                // Marka etiketleri
                if (item.brandTags.isNotEmpty)
                  SizedBox(
                    height: 20,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: item.brandTags.length,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) => _BrandTag(text: item.brandTags[i]),
                    ),
                  ),
                const SizedBox(height: 8),
                // Butonlar
                Row(
                  children: [
                    // Servisi İncele
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenyellow300,
                        foregroundColor: black500,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(br20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          ServiceDetailPage.route,
                          arguments: item,
                        );
                      },
                      child: const Text(
                        'Servisi İncele',
                        style: TextStyle(
                          fontSize: fs10,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w600,
                          height: 1.17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Randevu Al
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenyellow300,
                        foregroundColor: black500,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(br20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Var olan randevu akışına gönder
                        Navigator.pushNamed(context, 'randevu_al',
                            arguments: item.id);
                      },
                      child: const Text(
                        'Randevu Al',
                        style: TextStyle(
                          fontSize: fs10,
                          fontFamily: 'Roboto Flex',
                          fontWeight: FontWeight.w600,
                          height: 1.17,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Rating rozet
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: const BoxDecoration(
                        color: white300,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(br10),
                          bottomLeft: Radius.circular(br10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: fs10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: sandybrown,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${item.ratingCount})',
                            style: const TextStyle(
                              fontSize: fs10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: darkslateblue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _BrandTag extends StatelessWidget {
  final String text;
  const _BrandTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

/// Detay sayfası route ismi
class ServiceDetailPage extends StatelessWidget {
  static const route = '/service_detail';

  const ServiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceItem item =
        ModalRoute.of(context)!.settings.arguments as ServiceItem;

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
          title: Text(item.name, style: titleStyle),
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
          child: ListView(
            padding:
                const EdgeInsets.fromLTRB(padding20, padding20, padding20, 32),
            children: [
              // Kapak
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(br15),
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: item.coverAsset == null
                    ? const Icon(Icons.storefront,
                        size: 48, color: Colors.black38)
                    : Image.asset(item.coverAsset!,
                        fit: BoxFit.cover, width: double.infinity),
              ),
              const SizedBox(height: 12),
              // Konum + Mesafe + Puan
              Row(
                children: [
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: RevizIcons.Icons(name: 'MapPinLine')),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.cityDistrict,
                      style: const TextStyle(
                        fontSize: fs12,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w600,
                        color: black500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: fs12,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w600,
                      color: black300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: sandybrown),
                  const SizedBox(width: 6),
                  Text(
                    '${item.rating.toStringAsFixed(1)}  (${item.ratingCount})',
                    style: const TextStyle(
                      fontSize: fs12,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w600,
                      color: darkslateblue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Desteklenen markalar
              if (item.brandTags.isNotEmpty) ...[
                const Text(
                  'Desteklenen Markalar',
                  style: TextStyle(
                    fontSize: fs14,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w700,
                    color: black500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      item.brandTags.map((e) => _BrandTag(text: e)).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Servis sahibi dolduracağı alanlara yer tutucu
              const Text(
                'Servis Bilgileri',
                style: TextStyle(
                  fontSize: fs14,
                  fontFamily: 'Roboto Flex',
                  fontWeight: FontWeight.w700,
                  color: black500,
                ),
              ),
              const SizedBox(height: 8),
              _InfoTile(
                  label: 'Çalışma Saatleri',
                  value: 'Hafta içi 09:00 - 19:00, Cumartesi 10:00 - 17:00'),
              _InfoTile(
                  label: 'Hizmetler',
                  value: 'Periyodik bakım, Onarım, Ekspertiz'),
              _InfoTile(label: 'Adres', value: item.cityDistrict),
              _InfoTile(label: 'İletişim', value: '+90 5xx xxx xx xx'),

              const SizedBox(height: 20),
              // CTA
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: greenyellow300),
                        foregroundColor: black500,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(br6)),
                      ),
                      child: const Text('Geri'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, 'randevu_al',
                          arguments: item.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gray1200,
                        foregroundColor: white100,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(br6)),
                      ),
                      child: const Text('Randevu Al'),
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

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white300,
        borderRadius: BorderRadius.circular(br10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: black300),
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
                      color: black500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: fs12,
                      fontFamily: 'Roboto Flex',
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
