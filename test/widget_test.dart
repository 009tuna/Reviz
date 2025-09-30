import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Uygulamanın giriş widget'ını içeri aktar
import 'package:reviz_develop/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // main()'i çağırmıyoruz; sadece widget'ı pump ediyoruz
    await tester.pumpWidget(const MainApp());

    // MaterialApp var mı?
    expect(find.byType(MaterialApp), findsOneWidget);

    // Başlangıç route'u yüklenebilmiş mi? (AppBar veya herhangi bir widget’ı kontrol edebilirsin)
    // Örn: initialRoute '/' sayfasında IPhone141 varsa onu arayabilirsin.
    // expect(find.text('...'), findsOneWidget);
  });
}
