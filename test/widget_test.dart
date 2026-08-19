import 'package:eagle_smart_business/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the Eagle workspace sign-in entry point', (tester) async {
    await tester.pumpWidget(const EagleSmartBusinessApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue to workspace'), findsOneWidget);
    expect(find.text('Eagle'), findsOneWidget);
  });
}
