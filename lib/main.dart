// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Reel (senin mevcut) sayfalar:
import 'package:reviz_develop/screens/iphone141.dart'; // landing / onboarding ilk ekranın
import 'package:reviz_develop/screens/randevu_al.dart'; // randevu akışı

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env yükle
  await dotenv.load(fileName: '.env');

  // Supabase init
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  assert(
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
    'SUPABASE_URL / SUPABASE_ANON_KEY .env içinde bulunamadı.',
  );

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        fontFamily: 'Roboto Flex',
        scaffoldBackgroundColor: const Color(0xFFF3F5FD),
      ),
      // Tüm routing kontrolünü AuthGate içinde yapıyoruz
      home: const AuthGate(),
      routes: {
        // Auth flow
        'login': (_) => const LoginPage(),
        'register': (_) => const RegisterPage(),
        'security_verification': (_) => const SecurityVerificationPage(),
        'phone_verification_success': (_) =>
            const PhoneVerificationSuccessPage(),

        // Ana ekran
        'home': (_) => const HomePage(),

        // Randevu akışı (GERÇEK SAYFA)
        'randevu_al': (_) => const RandevuAlPage(
              onCreatedNavigateTo: 'appointments',
            ),
        'appointments': (_) => const AppointmentsPage(), // basit liste

        // Menü/Bildirim/İletişim vs.
        'menu': (_) => const MenuPage(),
        'notifications': (_) => const NotificationsPage(),
        'notification_empty': (_) => const NotificationsEmptyPage(),
        'contact_us': (_) => const ContactUsPage(),
        'contact_us_1': (_) => const ContactUsStep1Page(),
        'contact_us_2': (_) => const ContactUsStep2Page(),

        // Onboarding zinciri (landing’den sonra devam ekranları)
        'welcome': (_) => const WelcomePage(),
        'root': (_) => const RootPage(),
        'root_container': (_) => const RootContainerPage(),
        'website_layout': (_) => const WebsiteLayoutPage(),
        'root1': (_) => const Root1Page(),

        // Eski randevu varyantları (placeholder)
        'randevu_al_1': (_) => const RoutePlaceholder(title: 'randevu_al_1'),
        'randevu_al_2': (_) => const RoutePlaceholder(title: 'randevu_al_2'),
        'randevu_al_3': (_) => const RoutePlaceholder(title: 'randevu_al_3'),
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }
}

/// Basit auth router:
/// - Session varsa => Home
/// - Yoksa => Landing (IPhone141) + Login/Register’a geçiş
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _sub;
  bool _ready = false;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _signedIn = client.auth.currentSession != null;
    _ready = true;

    _sub = client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      setState(() => _signedIn = session != null);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_signedIn) {
      return const HomePage();
    }
    // Oturum yoksa: Landing (senin ekranın) → oradan Login/Register'a geç
    return IPhone141(
      // IPhone141 içinde “Giriş Yap” butonunda: Navigator.pushNamed(context, 'login');
      // “Kayıt Ol” butonunda: Navigator.pushNamed(context, 'register');
      key: const ValueKey('landing'),
    );
  }
}

/// ====== GERİ KALAN EKRANLAR: hafif stub/örnek ======
/// Bunlar compile eder ve akışı bağlar.
/// Hazır gerçek sayfaların varsa import edip bu stub’ların yerine geçirebilirsin.

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'home');
    } catch (e) {
      _toast('Giriş başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-posta')),
            const SizedBox(height: 8),
            TextField(
                controller: _pass,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _signIn,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Giriş'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, 'register'),
              child: const Text('Hesabın yok mu? Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _email.text.trim(),
        password: _pass.text.trim(),
        emailRedirectTo:
            'io.supabase.flutter://login-callback/', // deep-link örneği
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'security_verification');
    } catch (e) {
      _toast('Kayıt başarısız: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-posta')),
            const SizedBox(height: 8),
            TextField(
                controller: _pass,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class SecurityVerificationPage extends StatelessWidget {
  const SecurityVerificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Güvenlik Doğrulama')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(
              context, 'phone_verification_success'),
          child: const Text('SMS Doğrulamasını Geç (Demo)'),
        ),
      ),
    );
  }
}

class PhoneVerificationSuccessPage extends StatelessWidget {
  const PhoneVerificationSuccessPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Başarılı')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, 'home'),
          child: const Text('Ana Ekrana Geç'),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Ekran'),
        actions: [
          IconButton(
            onPressed: () => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, 'randevu_al'),
            child: const Text('Randevu Al'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, 'appointments'),
            child: const Text('Randevularım'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, 'menu'),
            child: const Text('Menü'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, 'notifications'),
            child: const Text('Bildirimler'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, 'contact_us'),
            child: const Text('İletişim'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ana'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Randevu'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menü'),
        ],
        onTap: (i) {
          switch (i) {
            case 0:
              // zaten buradayız
              break;
            case 1:
              Navigator.pushNamed(context, 'randevu_al');
              break;
            case 2:
              Navigator.pushNamed(context, 'menu');
              break;
          }
        },
      ),
    );
  }
}

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Randevularım')),
      body: const Center(
        child: Text(
          'Randevular burada listelenecek.\n(Şimdilik placeholder)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'menu (stub)');
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'notifications (stub)');
}

class NotificationsEmptyPage extends StatelessWidget {
  const NotificationsEmptyPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'notification_empty (stub)');
}

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'contact_us (stub)');
}

class ContactUsStep1Page extends StatelessWidget {
  const ContactUsStep1Page({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'contact_us_1 (stub)');
}

class ContactUsStep2Page extends StatelessWidget {
  const ContactUsStep2Page({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'contact_us_2 (stub)');
}

// Onboarding zinciri (stub)
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'welcome (stub)');
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'root (stub)');
}

class RootContainerPage extends StatelessWidget {
  const RootContainerPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'root_container (stub)');
}

class WebsiteLayoutPage extends StatelessWidget {
  const WebsiteLayoutPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'website_layout (stub)');
}

class Root1Page extends StatelessWidget {
  const Root1Page({super.key});
  @override
  Widget build(BuildContext context) =>
      const RoutePlaceholder(title: 'root1 (stub)');
}

/// Ortak placeholder
class RoutePlaceholder extends StatelessWidget {
  const RoutePlaceholder({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Bu ekran için henüz gerçek widget bağlanmadı.\n\n'
            'Route adı: $title\n\n'
            'Hazır olduğunda main.dart içinde bu route’un değerini gerçek sayfayla değiştir.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
