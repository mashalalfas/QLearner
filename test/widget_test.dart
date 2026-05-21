import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlearner/src/presentation/app.dart';

void main() {
  testWidgets('QLearner app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: QLearnerApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}