import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:upgrader/upgrader.dart';
// import 'package:firebase_core/firebase_core.dart'; // TODO: uncomment after flutterfire configure
import 'core/providers/locale_provider.dart';
import 'core/providers/role_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
// import 'core/firebase_options.dart';               // TODO: uncomment after flutterfire configure
// import 'core/services/notification_service.dart';  // TODO: uncomment after flutterfire configure
import 'package:flutter_quill/flutter_quill.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase setup (uncomment after running `flutterfire configure`) ──────
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await NotificationService.init();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: UJobApp()));
}

class UJobApp extends ConsumerWidget {
  const UJobApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role      = ref.watch(activeRoleProvider);
    final router    = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(localeProvider);

    final isEmployer = role == 'employer';

    // Design base: 390×844 (iPhone 14). ScreenUtil scales all .sp/.w/.h values
    // proportionally on every device. splitScreenMode handles tablets/foldables.
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the device is a tablet/iPad (width > 600), set designSize to the actual
        // screen dimensions. This forces a 1.0x scaling factor so that elements
        // don't blow up and become comically huge.
        final isTablet = constraints.maxWidth > 600;
        final designSize = isTablet
            ? Size(constraints.maxWidth, constraints.maxHeight)
            : const Size(390, 844);

        return ScreenUtilInit(
          designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => UpgradeAlert(
        upgrader: Upgrader(
          debugLogging: false,
          durationUntilAlertAgain: const Duration(days: 3),
        ),
        child: MaterialApp.router(
          title: 'UJob',
          debugShowCheckedModeBanner: false,

          // ── Themes (light + dark per role) ──────────────────────────────────
          theme:     isEmployer ? AppTheme.employerTheme()     : AppTheme.seekerTheme(),
          darkTheme: isEmployer ? AppTheme.employerDarkTheme() : AppTheme.seekerDarkTheme(),
          themeMode: themeMode,

          // ── i18n ────────────────────────────────────────────────────────────
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          routerConfig: router,
        ),
      ),
    );
    },
    );
  }
}
