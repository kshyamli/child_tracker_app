import 'package:flutter_test/flutter_test.dart';
import 'package:child_tracker_app/main.dart';
import 'package:child_tracker_app/login_screen.dart'; // Ensure this exists

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChildTrackerApp());
    expect(find.byType(LoginPage), findsOneWidget);
  });
}