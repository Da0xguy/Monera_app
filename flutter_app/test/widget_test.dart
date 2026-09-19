import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monera/main.dart';

void main() {
  testWidgets('Monera app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MoneraNeobankApp(),
      ),
    );

    expect(find.text('Pay & Scan'), findsAtLeastNWidgets(1));
  });
}
