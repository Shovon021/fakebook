import 'package:flutter_test/flutter_test.dart';
import 'package:fakebook/main.dart';

void main() {
  testWidgets('Fakebook app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FakebookApp());

    // Verify that the app renders
    expect(find.text('fakebook'), findsOneWidget);
  });
}
