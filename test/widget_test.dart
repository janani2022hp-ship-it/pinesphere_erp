import 'package:flutter_test/flutter_test.dart';
import 'package:pinesphere_erp/main.dart';

void main() {
  testWidgets('login screen shows the expected auth UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PineSphereApp());
    await tester.pump();

    expect(find.text('PineSphere'), findsOneWidget);
    expect(find.text('AI Powered Learning Platform'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
