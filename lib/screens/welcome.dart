import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum bulunamadı.')),
      );
      return;
    }

    final res = await supabase.from('profiles').update({
      'first_login': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);

    // supabase_flutter 2.x’te hata kontrolü böyle yapılır:
    if (res is PostgrestException) {
      throw Exception(res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> onHadiBaslayalim() async {
      try {
        await _completeOnboarding(context);
        if (!context.mounted) return; // async gap sonrası güvenlik
        Navigator.pushNamed(context, 'root1');
      } catch (e) {
        debugPrint('Onboarding güncelleme hatası: $e');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: height812,
            padding: const EdgeInsets.only(
              top: 101,
              left: padding7,
              right: padding6,
              bottom: padding106,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(br30)),
              color: white300,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst blok
                SizedBox(
                  width: width362,
                  height: 521,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      Container(
                        width: 316,
                        height: height64,
                        padding: const EdgeInsets.only(left: padding46),
                        alignment: AlignmentDirectional.topStart,
                        child: const Text(
                          'Size En İyi Yardımcı\nEller',
                          style: TextStyle(
                            fontSize: 30.5,
                            fontFamily: 'Roboto Flex',
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                            color: gray1200,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Alt açıklama
                      Container(
                        width: 308,
                        height: height36,
                        padding: const EdgeInsets.only(left: 54),
                        alignment: AlignmentDirectional.topStart,
                        child: const Text(
                          'Mikro Mobilite alanında\n uzman servislerimiz ile hizmetinizdeyiz!',
                          style: TextStyle(
                            fontSize: 13.7,
                            fontFamily: 'Roboto Flex',
                            fontWeight: FontWeight.w500,
                            height: 1.31,
                            letterSpacing: 0.1,
                            color: gray1200,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Görsel strip
                      const SizedBox(
                        width: width362,
                        height: 373,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 373,
                              child: Image(
                                image: AssetImage('assets/Frame-3284@2x.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 1),
                            SizedBox(
                              width: 120,
                              height: 373,
                              child: Image(
                                image: AssetImage('assets/Frame-3285@2x.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 1),
                            SizedBox(
                              width: 120,
                              height: 373,
                              child: Image(
                                image: AssetImage('assets/Frame-3286@2x.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: gap32),

                // Buton
                Container(
                  width: 331,
                  height: height52,
                  padding: const EdgeInsets.only(left: padding31),
                  alignment: AlignmentDirectional.topStart,
                  child: Container(
                    width: 300,
                    height: height52,
                    padding: const EdgeInsets.only(
                      top: padding16,
                      left: 91,
                      right: 86,
                      bottom: padding17,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(br6)),
                      color: gray1200,
                    ),
                    alignment: AlignmentDirectional.topStart,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onHadiBaslayalim,
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: Text(
                            'Hadi Başlayalım',
                            style: TextStyle(
                              fontSize: fs16,
                              fontFamily: 'Roboto Flex',
                              fontWeight: FontWeight.w600,
                              height: 1.19,
                              color: greenyellow300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
