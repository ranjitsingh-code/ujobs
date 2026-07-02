import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ujobs_app/core/widgets/ujob_text_field.dart';

Widget _wrap(Widget widget) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) =>
          MaterialApp(home: Scaffold(body: SingleChildScrollView(child: widget))),
    );

void main() {
  group('UJobTextField', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobTextField(label: 'Email'),
      ));
      expect(find.text('Email', findRichText: true), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(_wrap(
        UJobTextField(label: 'Username', controller: ctrl),
      ));
      await tester.enterText(find.byType(EditableText), 'azad');
      expect(ctrl.text, 'azad');
    });

    testWidgets('password field obscures text by default', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobTextField(label: 'Password', isPassword: true),
      ));
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.obscureText, isTrue);
    });

    testWidgets('password toggle reveals text', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobTextField(label: 'Password', isPassword: true),
      ));

      // Initially obscured
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isTrue,
      );

      // Tap the visibility toggle icon
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pump();

      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
    });

    testWidgets('onChanged fires on input', (tester) async {
      String changed = '';
      await tester.pumpWidget(_wrap(
        UJobTextField(label: 'Name', onChanged: (v) => changed = v),
      ));
      await tester.enterText(find.byType(EditableText), 'Hello');
      expect(changed, 'Hello');
    });

    testWidgets('readOnly field ignores input', (tester) async {
      final ctrl = TextEditingController(text: 'read only');
      await tester.pumpWidget(_wrap(
        UJobTextField(label: 'Fixed', controller: ctrl, readOnly: true),
      ));
      await tester.enterText(find.byType(EditableText), 'changed');
      expect(ctrl.text, 'read only');
    });

    testWidgets('shows errorText when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobTextField(label: 'Email', errorText: 'Invalid email'),
      ));
      expect(find.text('Invalid email'), findsOneWidget);
    });
  });
}
