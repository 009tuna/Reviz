import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Route: 'security_verification'
/// Akış: Intro → Telefon Gir → Kod Gir → (Başarı Modal)
class SecurityVerificationPage extends StatefulWidget {
  static const String routeName = 'security_verification';
  const SecurityVerificationPage({super.key});

  @override
  State<SecurityVerificationPage> createState() =>
      _SecurityVerificationPageState();
}

class _SecurityVerificationPageState extends State<SecurityVerificationPage> {
  final _pageController = PageController();
  int _step = 0;

  // Telefon
  final _phoneCtrl = TextEditingController();
  final _phoneFocus = FocusNode();

  // Kod
  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();

  // Resend sayaç
  Timer? _resendTimer;
  int _secondsLeft = 0;

  bool _isSendingCode = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pageController.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _goToStep(int step) async {
    setState(() => _step = step);
    await _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // Simüle: SMS gönder
  Future<void> _sendCode() async {
    setState(() => _isSendingCode = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Doğrulama kodu gönderildi.')),
    );

    // 60 sn sayaç
    _startResendCountdown(60);

    setState(() => _isSendingCode = false);
    _goToStep(2);
  }

  void _startResendCountdown(int seconds) {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  // Simüle: Kod doğrula
  Future<void> _verifyCode() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() => _isVerifying = false);
    _showSuccessSheet();
  }

  Future<void> _showSuccessSheet() async {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 56, color: colors.primary),
              const SizedBox(height: 12),
              Text(
                'Doğrulama Başarılı',
                style: texts.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hesabın güvenli bir şekilde doğrulandı.',
                style: texts.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all<Size>(
                    const Size.fromHeight(48),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // sheet
                  // Akış bitti: ana sayfa/uygun sayfaya yönlendir
                  Navigator.of(this.context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text('Ana Sayfaya Git'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface, // (background → surface)
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _TopBar(
                  showBack: _step > 0,
                  onBack: () {
                    if (_step > 0) {
                      _goToStep(_step - 1);
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Step 0: Intro
                      _IntroStep(
                        onStart: () => _goToStep(1),
                      ),

                      // Step 1: Enter phone
                      _PhoneStep(
                        phoneCtrl: _phoneCtrl,
                        phoneFocus: _phoneFocus,
                        isSending: _isSendingCode,
                        onSubmit: () async {
                          final phone = _phoneCtrl.text.trim();
                          if (phone.isEmpty || phone.length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Lütfen geçerli bir telefon girin.'),
                              ),
                            );
                            return;
                          }
                          await _sendCode();
                        },
                      ),

                      // Step 2: Enter code
                      _CodeStep(
                        codeCtrl: _codeCtrl,
                        codeFocus: _codeFocus,
                        secondsLeft: _secondsLeft,
                        isVerifying: _isVerifying,
                        onResend: _secondsLeft == 0 ? () => _sendCode() : null,
                        onVerify: () async {
                          final code = _codeCtrl.text.trim();
                          if (code.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen kodu girin.'),
                              ),
                            );
                            return;
                          }
                          await _verifyCode();
                        },
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
}

/// -------------------- UI Parçaları --------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showBack, required this.onBack});
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              tooltip: 'Geri',
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(const Size(48, 48)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Üstteki ikon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_rounded,
                size: 36, color: colors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Güvenlik Doğrulaması',
            style: texts.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface, // (onBackground → onSurface)
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bu cihazdan ilk girişiniz. Hesabınızın güvenliğini sağlamak için kimliğinizi doğrulayın.',
            style: texts.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: ButtonStyle(
              minimumSize:
                  WidgetStateProperty.all<Size>(const Size.fromHeight(48)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            onPressed: onStart,
            child: const Text('Doğrulamaya Başla'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.phoneCtrl,
    required this.phoneFocus,
    required this.isSending,
    required this.onSubmit,
  });

  final TextEditingController phoneCtrl;
  final FocusNode phoneFocus;
  final bool isSending;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone_iphone_rounded,
                  size: 36, color: colors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Doğrulama için Telefon Numaranızı Girin',
            style: texts.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface, // (onBackground → onSurface)
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Telefon alanı (basit maskesiz)
          Text('Telefon Numarası',
              style: texts.labelLarge?.copyWith(color: colors.onSurface)),
          const SizedBox(height: 8),
          TextField(
            controller: phoneCtrl,
            focusNode: phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
            ],
            decoration: InputDecoration(
              hintText: '+90 5xx xxx xx xx',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 16),

          FilledButton(
            style: ButtonStyle(
              minimumSize:
                  WidgetStateProperty.all<Size>(const Size.fromHeight(48)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            onPressed: isSending ? null : onSubmit,
            child: isSending
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator())
                : const Text('Doğrulama'),
          ),
        ],
      ),
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.codeCtrl,
    required this.codeFocus,
    required this.secondsLeft,
    required this.isVerifying,
    required this.onResend,
    required this.onVerify,
  });

  final TextEditingController codeCtrl;
  final FocusNode codeFocus;
  final int secondsLeft;
  final bool isVerifying;
  final VoidCallback? onResend;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sms_rounded, size: 36, color: colors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Devam etmek için Kodu Girin',
            style: texts.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface, // (onBackground → onSurface)
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'SMS yoluyla size bir doğrulama kodu gönderildi.',
            style: texts.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: codeCtrl,
            focusNode: codeFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: InputDecoration(
              hintText: 'Kodu buraya girin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => onVerify(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: ButtonStyle(
              minimumSize:
                  WidgetStateProperty.all<Size>(const Size.fromHeight(48)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            onPressed: isVerifying ? null : onVerify,
            child: isVerifying
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator())
                : const Text('Doğrulama'),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onResend,
              child: Text(
                secondsLeft == 0
                    ? 'Kodu Yeniden Gönder'
                    : 'Kodu $secondsLeft saniye içinde tekrar gönder',
                style: texts.bodyMedium?.copyWith(
                  color: onResend != null
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
