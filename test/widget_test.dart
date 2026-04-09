import 'package:flutter_test/flutter_test.dart';
import 'package:travel_in_a_box/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Login Screen title exists
    expect(find.text('TRAVEL IN A BOX'), findsOneWidget);
    expect(find.text('UNBOX ADVENTURE'), findsOneWidget);
  });
}