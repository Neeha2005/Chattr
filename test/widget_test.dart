import 'package:flutter_test/flutter_test.dart';
import 'package:chattr/main.dart';

void main() {
  testWidgets('Chattr smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const AIChatApp(showOnboarding: false),
    );
  });
}