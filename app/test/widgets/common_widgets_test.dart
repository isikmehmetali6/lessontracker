import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesson_tracker/widgets/common/common_widgets.dart';

void main() {
  group('Common Widgets Tests', () {
    testWidgets('TagChip renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TagChip(label: 'NEW', color: Colors.green),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('ProgressBar renders with given progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
             body: const ProgressBar(progress: 75.0, showPercentage: true),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
      // Finde internal FractionallySizedBox to check width factor
      final boxes = tester.widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(boxes.first.widthFactor, 0.75);
    });

    testWidgets('CircleIconButton triggers tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
           home: Scaffold(
             body: CircleIconButton(
               icon: Icons.check,
               onTap: () {
                 tapped = true;
               },
             ),
           ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
