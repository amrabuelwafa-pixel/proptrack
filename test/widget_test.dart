import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proptrack/main.dart';

void main() {
  testWidgets('PropTrackApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PropTrackApp(),
      ),
    );
    expect(find.text('Property Tracker — Sprint 0 ✅'), findsOneWidget);
  });
}
