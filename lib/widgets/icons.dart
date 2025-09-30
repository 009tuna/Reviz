// lib/widgets/icons.dart
import 'package:flutter/material.dart' as m;

/// Reviz'in basit ikon adaptörü.
/// Kullanım:
///   import 'package:reviz_develop/widgets/icons.dart' as RevizIcons;
///   SizedBox(width: 14, height: 14, child: RevizIcons.Icons(name: 'MapPinLine'));
class Icons extends m.StatelessWidget {
  const Icons({
    super.key,
    required this.name,
    this.size = 16,
    this.color,
  });

  /// Tasarımda geçen ad
  final String name;

  /// Boyut (px)
  final double size;

  /// Renk (opsiyonel)
  final m.Color? color;

  @override
  m.Widget build(m.BuildContext context) {
    final iconData = _materialIconFor(name);
    if (iconData != null) {
      return m.Icon(iconData, size: size, color: color);
    }

    // Asset ikon gerekiyorsa burada eşleştir.
    final asset = _assetFor(name);
    if (asset != null) {
      return m.Image.asset(asset, width: size, height: size);
    }

    // Fallback
    return m.SizedBox(width: size, height: size);
  }

  /// Sık kullanılan birkaç isim → Material Icons eşlemesi
  m.IconData? _materialIconFor(String n) {
    switch (n) {
      case 'MapPinLine':
      case 'map-pin':
        return m.Icons.place_outlined;
      case 'ClipboardText':
      case 'clipboard':
        return m.Icons.notes_outlined;
      case 'calendar':
      case 'Calendar':
        return m.Icons.calendar_today;
      case 'phone':
        return m.Icons.phone_outlined;
      case 'chat':
        return m.Icons.chat_bubble_outline;
      case 'warning':
        return m.Icons.warning_amber_outlined;
      case 'check':
        return m.Icons.check_circle_outline;
      case 'time':
        return m.Icons.access_time;
      // Araç çekici için material alternatifi:
      case 'game-icons-tow-truck':
      case 'tow-truck':
        return m.Icons.local_shipping_outlined;
      default:
        return null;
    }
  }

  /// Eğer özel bir SVG/PNG ikon kullanacaksan burada ad → asset yolu eşleştir.
  String? _assetFor(String n) {
    switch (n) {
      // Örn:
      // case 'game-icons-tow-truck':
      //   return 'assets/icons/tow_truck.png';
      default:
        return null;
    }
  }
}
