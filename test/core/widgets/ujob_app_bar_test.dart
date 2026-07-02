import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ujobs_app/core/widgets/ujob_app_bar.dart';
import 'package:ujobs_app/core/widgets/ujob_button.dart';

Widget _wrap(Widget appBar) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(appBar: appBar as PreferredSizeWidget),
      ),
    );

void main() {
  group('UJobAppBar', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(const UJobAppBar(title: 'My Screen')));
      expect(find.text('My Screen'), findsOneWidget);
    });

    testWidgets('shows back button by default', (tester) async {
      await tester.pumpWidget(_wrap(const UJobAppBar(title: 'Test')));
      expect(find.byType(UJobBackButton), findsOneWidget);
    });

    testWidgets('hides back button when showBack=false', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobAppBar(title: 'No Back', showBack: false),
      ));
      expect(find.byType(UJobBackButton), findsNothing);
    });

    testWidgets('calls onBack when back button tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(
        UJobAppBar(title: 'Back Test', onBack: () => pressed = true),
      ));
      await tester.tap(find.byType(UJobBackButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('renders rightWidget when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        UJobAppBar(
          title: 'With Action',
          rightWidget: const Icon(Icons.settings, key: Key('right')),
        ),
      ));
      expect(find.byKey(const Key('right')), findsOneWidget);
    });

    testWidgets('title truncates with ellipsis on overflow', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobAppBar(title: 'A Very Long Title That Should Be Truncated With Ellipsis'),
      ));
      final textWidget = tester.widget<Text>(find.byType(Text).first);
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 1);
    });

    testWidgets('renders customTitle instead of title string', (tester) async {
      await tester.pumpWidget(_wrap(
        const UJobAppBar(
          title: '',
          customTitle: Text('Custom Widget Title', key: Key('custom')),
        ),
      ));
      expect(find.byKey(const Key('custom')), findsOneWidget);
    });
  });
}
