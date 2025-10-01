import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reviz_develop/theme/tokens.dart';

class IPhone143 extends StatefulWidget {
  const IPhone143({super.key});
  @override
  State<IPhone143> createState() => _IPhone143State();
}

class _IPhone143State extends State<IPhone143> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  bool _agree = false;
  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      setState(() => _error = 'Şartları ve politikayı onaylayın.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final supa = Supabase.instance.client;

      final res = await supa.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        data: {'full_name': _name.text.trim()},
      );

      if (res.user == null) {
        throw const AuthException('Kayıt tamamlanamadı');
      }

      // profiles tablosuna first_login=true upsert (tabloyu önceden oluşturduğunu varsayıyoruz)
      await supa.from('profiles').upsert({
        'id': res.user!.id,
        'full_name': _name.text.trim(),
        'first_login': true,
      });

      if (!mounted) return;
      // AuthGate’in yönlendirmesi için root'a dön
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Bir şeyler ters gitti. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goLogin() => Navigator.pushReplacementNamed(context, 'i_phone_14_2');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: white300,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hesabınızı oluşturun',
                  style: TextStyle(
                      fontSize: 26.7,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w600,
                      color: black500)),
              const SizedBox(height: 16),
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
                const SizedBox(height: 12),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('İsim-Soyisim',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _name,
                      decoration:
                          const InputDecoration(hintText: 'Burak Akpınar'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Zorunlu alan'
                          : null,
                    ),
                    const SizedBox(height: 16),
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
                          return 'Zorunlu alan';
                        }
                        if (!v.contains('@')) return 'Geçerli bir email girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                        if (v == null || v.isEmpty) return 'Zorunlu alan';
                        if (v.length < 6) return 'En az 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Şifreyi Onayla',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _password2,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: '********'),
                      validator: (v) {
                        if (v != _password.text) return 'Şifreler eşleşmiyor';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _agree,
                          onChanged: (v) => setState(() => _agree = v ?? false),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        const Expanded(
                          child: Text.rich(TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Şartları ve politikayı ',
                                  style: TextStyle(color: forestgreen300)),
                              TextSpan(
                                  text: 'anladım.',
                                  style: TextStyle(color: black500)),
                            ],
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signup,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('KAYIT OL'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hesabınız var mı?',
                      style: TextStyle(color: gray500)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _goLogin,
                    child: const Text('Giriş Yap',
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
