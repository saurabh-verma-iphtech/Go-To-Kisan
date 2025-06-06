// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCc2CuOQ5jjNrdGncis9njv2A1rHk6l96M',
    appId: '1:509822802298:web:9a209fa62487f292e41ec3',
    messagingSenderId: '509822802298',
    projectId: 'signup-login-page-4dc42',
    authDomain: 'signup-login-page-4dc42.firebaseapp.com',
    storageBucket: 'signup-login-page-4dc42.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_ZeqK2TP1AkgrF6Ae_4YEYW1J9FHwgFA',
    appId: '1:509822802298:android:c16a942fa5cba4ade41ec3',
    messagingSenderId: '509822802298',
    projectId: 'signup-login-page-4dc42',
    storageBucket: 'signup-login-page-4dc42.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCeqZVw64WclVWZ_N33YBMR_svGhBMPdZQ',
    appId: '1:509822802298:ios:f14e4f97a922beefe41ec3',
    messagingSenderId: '509822802298',
    projectId: 'signup-login-page-4dc42',
    storageBucket: 'signup-login-page-4dc42.firebasestorage.app',
    iosBundleId: 'com.example.signupLoginPage',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCeqZVw64WclVWZ_N33YBMR_svGhBMPdZQ',
    appId: '1:509822802298:ios:f14e4f97a922beefe41ec3',
    messagingSenderId: '509822802298',
    projectId: 'signup-login-page-4dc42',
    storageBucket: 'signup-login-page-4dc42.firebasestorage.app',
    iosBundleId: 'com.example.signupLoginPage',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCc2CuOQ5jjNrdGncis9njv2A1rHk6l96M',
    appId: '1:509822802298:web:ffd75645be9885bee41ec3',
    messagingSenderId: '509822802298',
    projectId: 'signup-login-page-4dc42',
    authDomain: 'signup-login-page-4dc42.firebaseapp.com',
    storageBucket: 'signup-login-page-4dc42.firebasestorage.app',
  );
}
