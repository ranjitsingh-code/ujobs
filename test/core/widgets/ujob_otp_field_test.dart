import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ujobs_app/core/widgets/ujob_otp_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('accepts a complete pasted OTP and invokes callbacks', (
    tester,
  ) async {
    String changedValue = '';
    String completedValue = '';

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: UJobOtpField(
              autofocus: false,
              onChanged: (value) => changedValue = value,
              onCompleted: (value) => completedValue = value,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pump();

    expect(changedValue, '123456');
    expect(completedValue, '123456');
    for (final digit in '123456'.characters) {
      expect(find.text(digit), findsOneWidget);
    }
  });

  testWidgets('rejects non-digit input', (tester) async {
    String value = '';

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: UJobOtpField(
              autofocus: false,
              onChanged: (newValue) => value = newValue,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '12ab34');
    await tester.pump();

    expect(value, '1234');
  });
}
