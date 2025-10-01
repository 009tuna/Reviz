// lib/screens/website_layout.dart
import 'package:flutter/material.dart';

/// Onboarding akışı: Welcome(1) → Root(2) → RootContainer(3) → WebsiteLayout(4) → Root1(5)
/// Bu sayfanın route adı: 'website_layout'
class WebsiteLayoutPage extends StatelessWidget {
  static const String routeName = 'website_layout';

  const WebsiteLayoutPage({super.key});

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
            final isWide = constraints.maxWidth >= 800;
            final horizontalPadding = isWide ? 40.0 : 20.0;
            const maxContentWidth = 880.0;

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
                        'Website Düzeni',
                        style: texts.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Basit bir grid ve responsive mantıkla, içerikleri net bölümlere ayır.',
                        style: texts.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Basit responsive bölümler
                      _SoftCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.web_rounded,
                                      size: 28, color: colors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Header / Navigation alanı: sade ve tutarlı',
                                      style: texts.bodyMedium?.copyWith(
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, inner) {
                                  final twoCol = inner.maxWidth >= 560;
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: _SectionPlaceholder(
                                              title: 'Sol Bölüm',
                                              icon: Icons.view_sidebar_rounded,
                                            ),
                                          ),
                                          if (twoCol) const SizedBox(width: 12),
                                          if (twoCol)
                                            const Expanded(
                                              child: _SectionPlaceholder(
                                                title: 'Sağ Bölüm',
                                                icon: Icons.view_week_rounded,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (!twoCol) const SizedBox(height: 12),
                                      if (!twoCol)
                                        const _SectionPlaceholder(
                                          title: 'Alt Bölüm',
                                          icon: Icons.view_day_rounded,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // İlerleme: 4/5
                      Semantics(
                        label: 'Onboarding ilerleme durumu',
                        value: 'Adım 4 / 5',
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: 4 / 5,
                                  backgroundColor:
                                      colors.surfaceContainerHighest,
                                  color: colors.primary,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '4/5',
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
                          Navigator.of(context).pushNamed('root1');
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
                        'Bir sonraki adım: Root1',
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

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: texts.bodyMedium?.copyWith(color: colors.onSurface),
            ),
          ),
        ],
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
