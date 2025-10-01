import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reviz_develop/theme/tokens.dart';

class IPhone142 extends StatefulWidget {
  const IPhone142({super.key});
  @override
  State<IPhone142> createState() => _IPhone142State();
}

class _IPhone142State extends State<IPhone142> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final supa = Supabase.instance.client;
      await supa.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      // AuthGate routing devreye girsin diye root'a dön:
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Bir şeyler ters gitti. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goSignup() => Navigator.pushNamed(context, 'i_phone_14_3');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white300,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              const SizedBox(
                height: 180,
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image(
                          image: AssetImage('assets/reviz-LOGO-11@2x.png')),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'REVIZ',
                      style: TextStyle(
                          fontSize: 35,
                          fontFamily: 'Post No Bills Jaffna ExtraBold',
                          letterSpacing: -6.45,
                          color: gray1200),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hesabınıza giriş yapın',
                style: TextStyle(
                    fontSize: 26.7,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w600,
                    color: black500),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(.2)),
                  ),
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 16),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(hintText: 'ornek@gmail.com'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email zorunlu';
                        }
                        if (!v.contains('@')) return 'Geçerli bir email girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Şifre
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Şifre',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: '********'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifre zorunlu';
                        if (v.length < 6) return 'En az 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Giriş
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('GİRİŞ YAP'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Kayıt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hesabınız yok mu?',
                      style: TextStyle(color: gray500)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _goSignup,
                    child: const Text('KAYIT OL',
                        style: TextStyle(
                            color: forestgreen300,
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
}
