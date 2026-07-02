import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ujobs_app/core/widgets/ujob_button.dart';

Widget _wrap(Widget widget) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(home: Scaffold(body: Center(child: widget))),
    );

void main() {
  group('UJobButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobButton(label: 'Submit'),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        UJobButton(label: 'Go', onTap: () => tapped = true),
      ));
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when onTap is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobButton(label: 'Disabled'),
      ));
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pump();
      // No error thrown — button is inert
    });

    testWidgets('shows CircularProgressIndicator when isLoading', (tester) async {
      await tester.pumpWidget(_wrap(
        UJobButton(label: 'Save', isLoading: true, onTap: () {}),
      ));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides label text when isLoading', (tester) async {
      await tester.pumpWidget(_wrap(
        UJobButton(label: 'Save', isLoading: true, onTap: () {}),
      ));
      await tester.pump();
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('does not fire onTap while loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        UJobButton(
          label: 'Save',
          isLoading: true,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(UJobButton), warnIfMissed: false);
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('outlined variant renders', (tester) async {
      await tester.pumpWidget(_wrap(
        UJobButton(label: 'Cancel', outlined: true, onTap: () {}),
      ));
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
