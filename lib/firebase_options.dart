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
    apiKey: 'AIzaSyDiMvJ_eYpTugWXKlRl0b85do1S7N0ZxLI',
    appId: '1:816185508876:web:361a54d9e907ed452b1a29',
    messagingSenderId: '816185508876',
    projectId: 'living-guide-253bf',
    authDomain: 'living-guide-253bf.firebaseapp.com',
    storageBucket: 'living-guide-253bf.firebasestorage.app',
    measurementId: 'G-14MMP62ZT5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCB7iTEWfAiudgRTUPXEelPrehLbIe4t2k',
    appId: '1:816185508876:android:cf9c9e7b9eb377e62b1a29',
    messagingSenderId: '816185508876',
    projectId: 'living-guide-253bf',
    storageBucket: 'living-guide-253bf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5YwRp9z7cKQkzs-w-G-NanKGXZ6zmwXg',
    appId: '1:816185508876:ios:4663ec5df4414d592b1a29',
    messagingSenderId: '816185508876',
    projectId: 'living-guide-253bf',
    storageBucket: 'living-guide-253bf.firebasestorage.app',
    iosBundleId: 'com.example.livingGuide',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5YwRp9z7cKQkzs-w-G-NanKGXZ6zmwXg',
    appId: '1:816185508876:ios:4663ec5df4414d592b1a29',
    messagingSenderId: '816185508876',
    projectId: 'living-guide-253bf',
    storageBucket: 'living-guide-253bf.firebasestorage.app',
    iosBundleId: 'com.example.livingGuide',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDiMvJ_eYpTugWXKlRl0b85do1S7N0ZxLI',
    appId: '1:816185508876:web:323592d03b5249622b1a29',
    messagingSenderId: '816185508876',
    projectId: 'living-guide-253bf',
    authDomain: 'living-guide-253bf.firebaseapp.com',
    storageBucket: 'living-guide-253bf.firebasestorage.app',
    measurementId: 'G-E9CF5REZJQ',
  );
}
