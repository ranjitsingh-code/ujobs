// TODO: Run `flutterfire configure` to replace this stub with real config.
//
// Steps:
//   1. Install CLI:  dart pub global activate flutterfire_cli
//   2. Create Firebase project at https://console.firebase.google.com
//   3. Run: flutterfire configure --project=YOUR_PROJECT_ID
//   4. This file + google-services.json (Android) + GoogleService-Info.plist (iOS)
//      will be generated/updated automatically.
//   5. In main.dart, uncomment the Firebase.initializeApp() and NotificationService.init() calls.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Run `flutterfire configure` to generate firebase_options.dart.\n'
      'See: https://firebase.flutter.dev/docs/overview#initialization',
    );
  }
}
