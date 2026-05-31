import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/core/widgets/app_button.dart';

/// Widget tests for the shared [AppButton] — the single primary button used
/// across the app. Wrapped in [ScreenUtilInit] because the widget relies on
/// flutter_screenutil sizing extensions (`.h/.w/.sp/.r`).
void main() {
  Widget harness(Widget child) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('renders label and fires onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      harness(AppButton(label: 'Tap', onPressed: () => tapped = true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tap'), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shows a spinner and is disabled while loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      harness(
        AppButton(label: 'Tap', isLoading: true, onPressed: () => tapped = true),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Tap'), findsNothing);

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(tapped, isFalse);
  });
}
