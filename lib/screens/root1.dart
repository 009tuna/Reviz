import 'package:flutter/material.dart';

/// Onboarding akışı: Welcome(1) → Root(2) → RootContainer(3) → WebsiteLayout(4) → Root1(5)
/// Bu sayfanın route adı: 'root1'
/// "İlerle" tıklandığında sonraki aşama: 'security_verification'
class Root1Page extends StatelessWidget {
  static const String routeName = 'root1';

  const Root1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final texts = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final horizontalPadding = isWide ? 32.0 : 20.0;
            const maxContentWidth = 640.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      horizontalPadding, 24, horizontalPadding, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Son Bir Adım',
                        style: texts.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Temel kurulum tamamlandı. Devam ettiğinde güvenlik doğrulamasına geçeceğiz.',
                        style: texts.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _SoftCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.verified_user_rounded,
                                  size: 28, color: colors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Güvenlik için e-posta/telefon doğrulaması önerilir.',
                                  style: texts.bodyMedium?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // İlerleme: 5/5
                      Semantics(
                        label: 'Onboarding ilerleme durumu',
                        value: 'Adım 5 / 5',
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: 5 / 5,
                                  backgroundColor:
                                      colors.surfaceContainerHighest,
                                  color: colors.primary,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '5/5',
                              style: texts.labelLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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
                          Navigator.of(context)
                              .pushNamed('security_verification');
                        },
                        child: const Text('İlerle'),
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton(
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
                          Navigator.of(context).maybePop();
                        },
                        child: const Text('Geri'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sonraki aşama: Security Verification',
                        style: texts.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
