import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  // Menü item builder
  Widget _buildMenuItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(iconPath, width: 24, height: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: fs15,
          fontFamily: 'Roboto Flex',
          color: black500,
        ),
      ),
      trailing: Image.asset(
        "assets/arrow-next-small@2x.png",
        width: 20,
        height: 20,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    const userName = "Burak Akpınar"; // TODO: Supabase’den çekilecek

    return SafeArea(
      child: Scaffold(
        backgroundColor: ghostwhite,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Bar
            Container(
              color: white300,
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    userName,
                    style: TextStyle(
                      fontSize: fs22,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.bold,
                      color: gray1200,
                    ),
                  ),
                  IconButton(
                    icon: Image.asset(
                      "assets/cross1@2x.png",
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),

            // Menü Elemanları
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    title: "Profilim",
                    iconPath: "assets/user@2x.png",
                    onTap: () {
                      Navigator.pushNamed(context, "profile");
                    },
                  ),
                  _buildMenuItem(
                    title: "İletişim",
                    iconPath: "assets/contacts@2x.png",
                    onTap: () {
                      Navigator.pushNamed(context, "contact");
                    },
                  ),
                  _buildMenuItem(
                    title: "Araçlarım",
                    iconPath: "assets/Group-427321991@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Randevu Al",
                    iconPath: "assets/solar-calendar-bold1@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Servisler",
                    iconPath: "assets/Vector4@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Randevu Geçmişi",
                    iconPath: "assets/Group@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Adreslerim",
                    iconPath: "assets/Vector-110@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Ödeme İşlemleri",
                    iconPath: "assets/fluent-payment-20-filled@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Servislik Başvurusu",
                    iconPath: "assets/construction-worker@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Kurumsal Müşteri Ol",
                    iconPath: "assets/bricks@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Paylaş",
                    iconPath: "assets/share@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Puan",
                    iconPath: "assets/star@2x.png",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: "Çıkış Yap",
                    iconPath: "assets/log-out@2x.png",
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      try {
                        await Supabase.instance.client.auth.signOut();
                      } catch (_) {
                        // isteğe bağlı: hatayı loglayabilirsin
                      }
                      navigator.pushNamedAndRemoveUntil('/', (route) => false);
                    },
                  ),
                ],
              ),
            ),

            // Alt Kısım
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset("assets/Group-1@2x.png", width: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Reviz Technologies",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: gray1100,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Version 1.0",
                    style: TextStyle(fontSize: 12, color: black600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
