import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // Replace these placeholders by running:
  // flutterfire configure

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAnLmvL1pXi5UiuD-ojA_ICxrOCjpkI55I',
    appId: '1:252912880544:web:5b87683ab2191bac18b2c5',
    messagingSenderId: '252912880544',
    projectId: 'parabol-kocluk',
    authDomain: 'parabol-kocluk.firebaseapp.com',
    databaseURL: 'https://parabol-kocluk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'parabol-kocluk.firebasestorage.app',
    measurementId: 'G-RC8PYC03W7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHwpHtcODCPpyyFi-vWDk97y6L5GfnLsA',
    appId: '1:252912880544:android:a152c3ca06ce1d5618b2c5',
    messagingSenderId: '252912880544',
    projectId: 'parabol-kocluk',
    databaseURL: 'https://parabol-kocluk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'parabol-kocluk.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQsxX0jY3hqJmijjbL9rpBpRU5azW1swo',
    appId: '1:252912880544:ios:2ffd084116359d1b18b2c5',
    messagingSenderId: '252912880544',
    projectId: 'parabol-kocluk',
    databaseURL: 'https://parabol-kocluk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'parabol-kocluk.firebasestorage.app',
    iosClientId: '252912880544-tdmmcqp8ebgm9bqp04kdmepjre2uok7r.apps.googleusercontent.com',
    iosBundleId: 'com.parabol.kocluk.webkoclukMobile',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAQsxX0jY3hqJmijjbL9rpBpRU5azW1swo',
    appId: '1:252912880544:ios:2ffd084116359d1b18b2c5',
    messagingSenderId: '252912880544',
    projectId: 'parabol-kocluk',
    databaseURL: 'https://parabol-kocluk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'parabol-kocluk.firebasestorage.app',
    iosClientId: '252912880544-tdmmcqp8ebgm9bqp04kdmepjre2uok7r.apps.googleusercontent.com',
    iosBundleId: 'com.parabol.kocluk.webkoclukMobile',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAnLmvL1pXi5UiuD-ojA_ICxrOCjpkI55I',
    appId: '1:252912880544:web:a9fe20cdc1bcfb6518b2c5',
    messagingSenderId: '252912880544',
    projectId: 'parabol-kocluk',
    authDomain: 'parabol-kocluk.firebaseapp.com',
    databaseURL: 'https://parabol-kocluk-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'parabol-kocluk.firebasestorage.app',
    measurementId: 'G-MH8N7GFXGZ',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );
}
