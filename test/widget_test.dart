import 'package:flutter_test/flutter_test.dart';

import 'package:otobakim_defteri/main.dart';

void main() {
  testWidgets('Splash ekranından ana sayfaya geçer', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('OtoBakım Defteri'), findsOneWidget);
    expect(
      find.text('Bakım ve masraflarını düzenli takip et.'),
      findsOneWidget,
    );
    expect(find.text('Başla'), findsOneWidget);

    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();

    expect(find.text('Araçlarım'), findsOneWidget);
    expect(find.text('Bakım Kayıtları'), findsOneWidget);
    expect(find.text('Masraf Kayıtları'), findsOneWidget);
  });
}
