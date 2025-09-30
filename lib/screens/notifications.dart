import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _notifications = response;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Bildirimler alınırken hata: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5FD),
        appBar: AppBar(
          title: const Text(
            'Bildirimler',
            style: TextStyle(
              fontSize: fs22,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w700,
              height: 1.23,
              color: gray1200,
            ),
            textAlign: TextAlign.center,
          ),
          leading: const SizedBox(),
          backgroundColor: white300,
          centerTitle: true,
          toolbarHeight: height100,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(),
      ),
    );
  }

  /// 📌 Bildirim yoksa eski dosyadaki ikonlarla boş state
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/Bell-illustration@2x.png'),
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 24),
          Text(
            'Henüz Bildirim Yok',
            style: TextStyle(
              fontSize: fs20,
              fontFamily: 'Roboto Flex',
              fontWeight: FontWeight.w600,
              height: 1.52,
              color: darkslategray300,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Şu anda bildiriminiz yok.\nDaha sonra tekrar gelin.',
            style: TextStyle(
              fontSize: fs14,
              fontFamily: 'Roboto Flex',
              height: 1.3,
              color: darkgray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📌 Bildirim listesi Supabase’den geliyor, ikonları eski tasarımdan aldık
  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final item = _notifications[index];

        /// tip → ikon seçimi
        final type = item['type'] ?? 'default';
        String iconPath;
        Color bgColor;

        switch (type) {
          case 'appointment_approved':
            iconPath = 'assets/ClipboardText@2x.png';
            bgColor = orange;
            break;
          case 'process_check':
            iconPath = 'assets/shield-checkmark@2x.png';
            bgColor = mediumslateblue100;
            break;
          case 'process_started':
            iconPath = 'assets/worker@2x.png';
            bgColor = white300;
            break;
          case 'process_done':
            iconPath = 'assets/circle-checkmark@2x.png';
            bgColor = forestgreen400;
            break;
          case 'cancelled':
            iconPath = 'assets/emoji-sad@2x.png';
            bgColor = indianred;
            break;
          case 'announcement':
            iconPath = 'assets/BellRinging@2x.png';
            bgColor = darkslategray200;
            break;
          default:
            iconPath = 'assets/Bell-illustration@2x.png';
            bgColor = gray200;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: white300,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(iconPath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? 'Bildirim',
                      style: const TextStyle(
                        fontSize: fs16,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w500,
                        color: black500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['message'] ?? '',
                      style: const TextStyle(
                        fontSize: fs14,
                        fontFamily: 'Roboto Flex',
                        color: black600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item['created_at'] != null
                    ? DateTime.parse(item['created_at'])
                        .toLocal()
                        .toString()
                        .substring(11, 16) // saat:dakika
                    : '',
                style: const TextStyle(
                  fontSize: fs12,
                  color: black300,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
