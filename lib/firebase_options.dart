// File generated from GoogleService-Info.plist and google-services.json.
// Re-run `flutterfire configure` to regenerate (if the CLI succeeds).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. '
        'Re-run flutterfire configure and select web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBAv7gniaE3QQ22l8-3_W8T8eI2gb9lGQ',
    appId: '1:341474669286:android:8b94eb98d8b5df379c0127',
    messagingSenderId: '341474669286',
    projectId: 'food-delivery-app-9536c',
    storageBucket: 'food-delivery-app-9536c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDt3148w0LW0U52rnf-aL_d6h2nncS_u5U',
    appId: '1:341474669286:ios:ae80725981ea24b59c0127',
    messagingSenderId: '341474669286',
    projectId: 'food-delivery-app-9536c',
    storageBucket: 'food-delivery-app-9536c.firebasestorage.app',
    iosClientId: '341474669286-lmld180kl6un7fvb0f12mo5r440gnhbn.apps.googleusercontent.com',
  );
}
