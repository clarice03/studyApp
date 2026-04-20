
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
    apiKey: 'AIzaSyBW4fiDTKnkugf51D8Gtx-NrjNPxYhYz6g',
    appId: '1:729622765690:web:0a2e031db9c02022df9bc3',
    messagingSenderId: '729622765690',
    projectId: 'studyapp-26768',
    authDomain: 'studyapp-26768.firebaseapp.com',
    storageBucket: 'studyapp-26768.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBa5P3G6z4yBKVoFYuCmv_jKCIJ-PE6_p0',
    appId: '1:729622765690:android:2143dcdea56105dfdf9bc3',
    messagingSenderId: '729622765690',
    projectId: 'studyapp-26768',
    storageBucket: 'studyapp-26768.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJMrLOMjTHlNntjjS_ZvEAfVPhRE__X90',
    appId: '1:729622765690:ios:4784057f60635720df9bc3',
    messagingSenderId: '729622765690',
    projectId: 'studyapp-26768',
    storageBucket: 'studyapp-26768.firebasestorage.app',
    iosBundleId: 'com.example.studyApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDJMrLOMjTHlNntjjS_ZvEAfVPhRE__X90',
    appId: '1:729622765690:ios:4784057f60635720df9bc3',
    messagingSenderId: '729622765690',
    projectId: 'studyapp-26768',
    storageBucket: 'studyapp-26768.firebasestorage.app',
    iosBundleId: 'com.example.studyApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBW4fiDTKnkugf51D8Gtx-NrjNPxYhYz6g',
    appId: '1:729622765690:web:b65ab393b8037d6adf9bc3',
    messagingSenderId: '729622765690',
    projectId: 'studyapp-26768',
    authDomain: 'studyapp-26768.firebaseapp.com',
    storageBucket: 'studyapp-26768.firebasestorage.app',
  );
}
