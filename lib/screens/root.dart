// lib/screens/root.dart
import 'package:flutter/material.dart';

/// Onboarding akışındaki ikinci adım (Welcome → Root).
/// Route adı: 'root'
class RootPage extends StatelessWidget {
  static const String routeName = 'root';

  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final texts = theme.textTheme;

    // Basit responsive: geniş ekranda içerik genişliğini sınırla
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
                constraints: BoxConstraints(
                  maxWidth: isWide ? maxContentWidth : double.infinity,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Başlık
                      Text(
                        'Reviz’e Devam Edelim',
                        style: texts.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 8),

                      // Açıklama
                      Text(
                        'Temel ayarları yapalım ve bir sonraki adıma geçelim. '
                        'Bu akış kısa ve nettir — istediğin zaman geri dönebilirsin.',
                        style: texts.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // (Opsiyonel) görsel alanı — mevcut asset’leri bozmamak için boş placeholder.
                      // Varlıklar projede aynı adlarla duruyorsa buraya Image.asset(...) ekleyebilirsin.
                      _SoftCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings_suggest_rounded,
                                size: 28,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hızlı başlangıç için önerilen ayarlar hazır.',
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

                      // İlerleme göstergesi (minör erişilebilirlik ipucu)
                      Semantics(
                        label: 'Onboarding ilerleme durumu',
                        value: 'Adım 2 / 5',
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: 2 / 5, // Welcome(1) → Root(2) → ...
                                  backgroundColor:
                                      colors.surfaceContainerHighest,
                                  color: colors.primary,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '2/5',
                              style: texts.labelLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Birincil çağrı (İlerle)
                      FilledButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all<Size>(
                            const Size.fromHeight(48), // dokunma alanı
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () {
                          // Bir sonraki adım: 'root_container'
                          Navigator.of(context).pushNamed('root_container');
                        },
                        child: const Text('İlerle'),
                      ),
                      const SizedBox(height: 12),

                      // İkincil: Geri (Welcome’a dönmek isteyene)
                      OutlinedButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all<Size>(
                            const Size.fromHeight(48),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
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
                      // Küçük erişilebilirlik metni
                      Text(
                        'İlerlemek için “İlerle” butonuna dokun.',
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
