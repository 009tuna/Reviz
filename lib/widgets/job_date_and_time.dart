import 'package:flutter/material.dart';
import 'package:reviz_develop/theme/tokens.dart';

/// Hafif tarih seçici:
/// - Oklarla birer gün ileri/geri
/// - Aşağıda 9 günlük strip (merkezde mevcut gün)
/// - İsteğe bağlı [minDate]/[maxDate] ile aralık kısıtlama
/// - [selectedDate] ve [onDateChanged] opsiyonel (geri uyumlu)
class JobDateAndTime extends StatefulWidget {
  const JobDateAndTime({
    super.key,
    this.selectedDate,
    this.onDateChanged,
    this.minDate,
    this.maxDate,
  });

  /// Başlangıç tarihi (verilmezse bugün).
  final DateTime? selectedDate;

  /// Tarih değişince tetiklenecek callback (opsiyonel).
  final ValueChanged<DateTime>? onDateChanged;

  /// İzin verilen en erken tarih (opsiyonel).
  final DateTime? minDate;

  /// İzin verilen en geç tarih (opsiyonel).
  final DateTime? maxDate;

  @override
  State<JobDateAndTime> createState() => _JobDateAndTimeState();
}

class _JobDateAndTimeState extends State<JobDateAndTime> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate =
        _normalize(_applyBounds(widget.selectedDate ?? DateTime.now()));
  }

  @override
  void didUpdateWidget(covariant JobDateAndTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent'tan gelen selectedDate değişirse senkronize et
    final incoming = widget.selectedDate;
    if (incoming != null) {
      final normalized = _normalize(_applyBounds(incoming));
      if (normalized != _currentDate) {
        setState(() => _currentDate = normalized);
      }
    }
  }

  // Yalnızca yıl/ay/gün
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // min/max sınırlarını uygula (varsa)
  DateTime _applyBounds(DateTime d) {
    final minD = widget.minDate != null ? _normalize(widget.minDate!) : null;
    final maxD = widget.maxDate != null ? _normalize(widget.maxDate!) : null;
    var nd = _normalize(d);
    if (minD != null && nd.isBefore(minD)) nd = minD;
    if (maxD != null && nd.isAfter(maxD)) nd = maxD;
    return nd;
  }

  void _bump(int days) {
    var next = _currentDate.add(Duration(days: days));
    next = _applyBounds(next);
    if (next != _currentDate) {
      setState(() => _currentDate = next);
      widget.onDateChanged?.call(next);
    }
  }

  void _set(DateTime d) {
    final nd = _applyBounds(d);
    if (nd != _currentDate) {
      setState(() => _currentDate = nd);
      widget.onDateChanged?.call(nd);
    }
  }

  String _monthTr(int m) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  /// Şeritte 9 gün: merkez _currentDate, ±4 gün;
  /// min/max varsa aralık dışına taşmayacak şekilde kırpılır.
  List<DateTime> get _stripDays {
    final center = _currentDate;
    var start = center.subtract(const Duration(days: 4));
    var end = center.add(const Duration(days: 4));

    final minD = widget.minDate != null ? _normalize(widget.minDate!) : null;
    final maxD = widget.maxDate != null ? _normalize(widget.maxDate!) : null;

    if (minD != null && start.isBefore(minD)) {
      start = minD;
      end = start.add(const Duration(days: 8));
    }
    if (maxD != null && end.isAfter(maxD)) {
      end = maxD;
      start = end.subtract(const Duration(days: 8));
    }

    // Start/end arası 9 günden kısaysa doldur
    final days = <DateTime>[];
    var cur = start;
    while (!cur.isAfter(end) && days.length < 9) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
    }
    // Yine de 9 dan az kaldıysa (çok dar aralık), sağa doğru tamamla
    while (days.length < 9) {
      final last = days.isNotEmpty ? days.last : start;
      final candidate = last.add(const Duration(days: 1));
      if (maxD != null && candidate.isAfter(maxD)) break;
      days.add(candidate);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final title =
        '${_currentDate.day.toString().padLeft(2, '0')} ${_monthTr(_currentDate.month)} ${_currentDate.year}';

    return Container(
      color: white300,
      width: width335,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Randevu Tarihi Seçiniz',
              style: TextStyle(
                fontSize: fs15,
                fontFamily: 'Roboto Flex',
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: ls041,
                color: darkslategray100,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Başlık + oklar
          Row(
            children: [
              InkWell(
                onTap: () => _bump(-1),
                child: const SizedBox(
                  width: width19,
                  height: height19,
                  child: Image(
                    image: AssetImage('assets/CaretLeft@2x.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: fs15,
                      fontFamily: 'Roboto Flex',
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: ls041,
                      color: darkslategray100,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _bump(1),
                child: const SizedBox(
                  width: width19,
                  height: height19,
                  child: Image(
                    image: AssetImage('assets/CaretRight@2x.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Küçük gün şeridi
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _stripDays.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final d = _stripDays[i];
                final isSelected = _normalize(d) == _currentDate;
                const dows = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                final dow = dows[d.weekday - 1];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _set(d),
                  child: SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dow,
                          style: TextStyle(
                            fontSize: fs13,
                            fontFamily: 'Basis Grotesque Pro',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: ls041,
                            color: isSelected ? darkorchid : darkslategray100,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? darkorchid : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              fontSize: fs13,
                              fontFamily: 'Basis Grotesque Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              letterSpacing: ls041,
                              color: isSelected ? white300 : gray200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
