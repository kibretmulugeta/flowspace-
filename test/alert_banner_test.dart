import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowspace/app.dart';
import 'package:flowspace/core/services/notification_service.dart';

void main() {
  testWidgets('Alert banner is placed on screen (dy >= 0) and stays permanently until removed', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: FlowSpaceApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(FlowSpaceApp)));
    
    // Clear any initial boot alerts for a clean test
    container.read(notificationServiceProvider.notifier).dismissAll();
    await tester.pump();

    // 1. Trigger test reminder notification
    container.read(notificationServiceProvider.notifier).triggerTestNotification(type: 'reminder');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify it is visible
    final titleFinder = find.textContaining('Reminder:');
    expect(titleFinder, findsOneWidget);

    // Verify position is ON SCREEN (dy >= 0)
    final pos = tester.getTopLeft(titleFinder);
    expect(pos.dy, greaterThanOrEqualTo(0.0));

    // 2. Wait 15 seconds (simulate elapsed time)
    await tester.pump(const Duration(seconds: 15));

    // Must STILL be on screen because auto-dismiss is removed!
    expect(titleFinder, findsOneWidget);

    // 3. Test explicit dismissal via Close button (✕)
    final closeFinder = find.byIcon(Icons.close);
    expect(closeFinder, findsWidgets);
    await tester.tap(closeFinder.first);
    await tester.pump();
    await tester.pumpAndSettle();

    // Now the specific test reminder should be dismissed
    expect(find.textContaining('Hydration break'), findsNothing);
  });

  testWidgets('Snoozing takes noticeable time (10m default) and provides feedback', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: FlowSpaceApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(FlowSpaceApp)));
    container.read(notificationServiceProvider.notifier).dismissAll();
    await tester.pump();

    container.read(notificationServiceProvider.notifier).triggerTestNotification(type: 'reminder');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.textContaining('Reminder:'), findsOneWidget);
    expect(find.textContaining('Snooze 10m'), findsOneWidget);

    // Tap Snooze button to open duration options
    await tester.tap(find.textContaining('Snooze 10m'));
    await tester.pumpAndSettle();

    // Verify options are visible
    expect(find.text('15 min'), findsOneWidget);

    // Tap 15 min snooze chip
    await tester.tap(find.text('15 min'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Banner is removed
    expect(find.textContaining('Reminder:'), findsNothing);

    // Feedback toast is shown with noticeable time
    expect(find.textContaining('Snoozed for 15 min'), findsOneWidget);
  });

  testWidgets('Multiple alerts queue and rotate', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: FlowSpaceApp(),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(FlowSpaceApp)));
    container.read(notificationServiceProvider.notifier).dismissAll();
    await tester.pump();

    container.read(notificationServiceProvider.notifier).triggerTestNotification(type: 'reminder');
    container.read(notificationServiceProvider.notifier).triggerTestNotification(type: 'task');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Multi-alert indicator
    expect(find.text('1 of 2'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Rotate to next alert
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('1 of 2'), findsOneWidget);

    // Clear all
    await tester.tap(find.text('Clear All'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('1 of 2'), findsNothing);
  });
}
