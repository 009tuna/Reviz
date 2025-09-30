// lib/widgets/app_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';

import 'package:reviz_develop/screens/home1.dart';
import 'package:reviz_develop/screens/services.dart';
import 'package:reviz_develop/screens/appointments.dart';
import 'package:reviz_develop/screens/notifications.dart';

// Supabase reposu için
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reviz_develop/data/appointments_repo.dart';

class AppBottomBar extends StatefulWidget {
  final int pageIndex;
  const AppBottomBar({super.key, this.pageIndex = 0});

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  late int _pageIndex;

  // Backend
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseAppointmentRepo? _appointmentsRepo;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.pageIndex;

    // Auth + repo
    _userId = _client.auth.currentUser?.id;
    _appointmentsRepo = SupabaseAppointmentRepo(_client);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      setState(() => _pageIndex = args);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kullanıcı yoksa basit bir “giriş gerekli” placeholder’ı verelim.
    final appointmentsPage = (_userId != null && _appointmentsRepo != null)
        ? AppointmentsPage(
            repo: _appointmentsRepo!,
            userId: _userId!,
          )
        : const _SignInRequired();

    // Bottom bar sayfaları
    final pages = <Widget>[
      const Home1(),
      const ServicesPage(), // mock 2 servis gösteriyor
      appointmentsPage, // backend bağlı randevular
      const Notifications(), // senin mevcut sayfan
    ];

    return Scaffold(
      body: pages[_pageIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        height: 73,
        padding: EdgeInsets.zero,
        child: Container(
          width: width375,
          height: 73,
          padding: const EdgeInsets.only(right: padding1),
          alignment: AlignmentDirectional.topEnd,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Item(
                label: 'AnaSayfa',
                asset: 'assets/home@2x.png',
                selected: _pageIndex == 0,
                onTap: () => setState(() => _pageIndex = 0),
              ),
              _Item(
                label: 'Servisler',
                asset: 'assets/healthicons-factory-worker-outline@2x.png',
                selected: _pageIndex == 1,
                onTap: () => setState(() => _pageIndex = 1),
              ),
              _Item(
                label: 'Randevularım',
                asset: 'assets/solar-calendar-bold-3@2x.png',
                selected: _pageIndex == 2,
                onTap: () => setState(() => _pageIndex = 2),
              ),
              _Item(
                label: 'Bildirimler',
                asset: 'assets/Group-427321969@2x.png',
                selected: _pageIndex == 3,
                onTap: () => setState(() => _pageIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;
  const _Item({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? black500 : black300;
    final weight = selected ? FontWeight.w600 : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 74,
        height: 43,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Image(image: AssetImage(asset), fit: BoxFit.cover),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fs12,
                  fontFamily: 'Roboto',
                  fontWeight: weight,
                  height: 1.17,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInRequired extends StatelessWidget {
  const _SignInRequired();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(padding20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Randevuları görmek için giriş yapmalısın.',
              style: TextStyle(
                fontSize: fs16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                height: 1.19,
                color: black500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // kendi giriş ekranına yönlendir
                Navigator.pushNamed(context, 'login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gray1200,
                foregroundColor: white100,
                minimumSize: const Size(200, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(br6),
                ),
                elevation: 0,
              ),
              child: const Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
