import 'package:flutter_test/flutter_test.dart';
import 'package:smart_money/main.dart';

void main() {
  testWidgets('Smart Money app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMoneyApp());
    await tester.pump();
    expect(find.text('Smart Money'), findsWidgets);
  });
}
