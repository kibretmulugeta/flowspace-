import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowspace/app.dart';

void main() {
  testWidgets('FlowSpaceApp smoke test - renders dashboard and navigation', (WidgetTester tester) async {
    // Set a large enough surface size for responsive testing
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: FlowSpaceApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand title is rendered
    expect(find.text('FlowSpace'), findsOneWidget);

    // Verify Primary Navigation tabs are present
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Notes'), findsWidgets);
    expect(find.text('More'), findsWidgets);

    // Verify Quick Actions are present
    expect(find.text('+ Task'), findsOneWidget);
    expect(find.text('+ Event'), findsOneWidget);

    // Switch to Calendar tab
    await tester.tap(find.text('Calendar').first);
    await tester.pumpAndSettle();

    // Switch to Tasks tab
    await tester.tap(find.text('Tasks').first);
    await tester.pumpAndSettle();

    // Switch to Notes tab
    await tester.tap(find.text('Notes').first);
    await tester.pumpAndSettle();

    // Switch to More tab
    await tester.tap(find.text('More').first);
    await tester.pumpAndSettle();
  });
}
