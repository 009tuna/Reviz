import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services_repository.dart';
import '../models/service.dart';

class NearbyServicesPage extends StatefulWidget {
  final double userLat;
  final double userLng;
  const NearbyServicesPage(
      {super.key, required this.userLat, required this.userLng});

  @override
  State<NearbyServicesPage> createState() => _NearbyServicesPageState();
}

class _NearbyServicesPageState extends State<NearbyServicesPage> {
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
      items = await repo.fetchNearby(lat: widget.userLat, lng: widget.userLng);
    } catch (_) {
      items = []; // Hata durumunu sessiz geç, UI zaten “boş” gösteriyor
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
            'Konumuna Uygun Servisler',
            style: TextStyle(
              fontSize: fs22,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w700,
              height: 1.23,
              color: gray1200,
            ),
          ),
          backgroundColor: white300,
          centerTitle: true,
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
              children: [
                const SizedBox(height: padding16),
                // Harita görseli (senin asset)
                Container(
                  width: width335,
                  height: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: white300,
                    borderRadius: BorderRadius.all(Radius.circular(br12)),
                  ),
                  child:
                      Image.asset('assets/image-29@2x.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: gap12),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )
                else if (items.isEmpty)
                  const _EmptyNearby()
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: padding20),
                    itemBuilder: (_, i) => _ServiceCard(
                      service: items[i],
                      onTap: () => Navigator.pop(context, items[i]),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: gap12),
                    itemCount: items.length,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;
  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white300,
      borderRadius: BorderRadius.circular(br12),
      child: InkWell(
        borderRadius: BorderRadius.circular(br12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(padding12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kapak
              ClipRRect(
                borderRadius: BorderRadius.circular(br10),
                child: Image.asset(service.heroAsset,
                    height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: gap8),
              // Başlık + mesafe
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: fs14,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w600,
                        color: black500,
                      ),
                    ),
                  ),
                  const SizedBox(width: gap8),
                  const Image(
                      image: AssetImage('assets/Vector-211@2x.png'),
                      width: 11,
                      height: 11),
                  const SizedBox(width: 4),
                  Text(
                    '${service.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: fs10,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w600,
                      color: black200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: gap4),
              // İlçe
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: black200),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service.district,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: fs10,
                          fontWeight: FontWeight.w600,
                          color: black200,
                          fontFamily: 'Roboto Flex'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: gap8),
              // Marka rozetleri
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: service.brands.map((b) => _brandChip(b)).toList(),
              ),
              const SizedBox(height: gap8),
              // Alt şerit: puan + incele
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: white300,
                      borderRadius: BorderRadius.circular(br10),
                    ),
                    child: Row(
                      children: [
                        const Image(
                            image: AssetImage('assets/Star-Icon@2x.png'),
                            width: 12,
                            height: 12),
                        const SizedBox(width: 4),
                        Text(
                          service.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: fs7,
                              color: sandybrown,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${service.ratingCount})',
                          style: const TextStyle(
                              fontSize: fs7,
                              color: darkslateblue,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: greenyellow300,
                      foregroundColor: black500,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(br20)),
                    ),
                    onPressed: onTap,
                    icon: const Image(
                        image: AssetImage('assets/Vector-46@2x.png'),
                        width: 14,
                        height: 14),
                    label: const Text('Servisi İncele',
                        style: TextStyle(
                            fontSize: fs6,
                            fontFamily: 'Roboto Flex',
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandChip(String brand) {
    // Renkleri markaya göre basit eşleme (UI’daki örneğe yakın)
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
        border: Border.all(color: border, width: 0.2),
      ),
      child: Text(
        brand.toUpperCase(),
        style: const TextStyle(
            fontSize: fs5,
            fontFamily: 'Roboto Flex',
            fontWeight: FontWeight.w500,
            color: black500),
      ),
    );
  }
}

class _EmptyNearby extends StatelessWidget {
  const _EmptyNearby();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(padding20),
      child: Column(
        children: [
          SizedBox(height: 8),
          Text('Yakınında servis bulunamadı',
              style: TextStyle(
                  fontSize: fs16,
                  fontFamily: 'Roboto Flex',
                  fontWeight: FontWeight.w600,
                  color: darkslategray300)),
          SizedBox(height: 6),
          Text(
              'Konum izinlerini açmayı veya arama alanını genişletmeyi deneyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fs14, color: darkgray, fontFamily: 'Roboto Flex')),
        ],
      ),
    );
  }
}
