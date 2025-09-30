enum SevkType { selfDropPickup, pickupOnly, dropOnly, pickupAndDrop }

class SevkOption {
  final SevkType type;
  final String title;
  final String description;
  final double price; // 0 => ücretsiz
  const SevkOption({
    required this.type,
    required this.title,
    required this.description,
    required this.price,
  });

  bool get isFree => price == 0;
  String get priceText => isFree ? '0.00 TL' : '${price.toStringAsFixed(2)} TL';
}
