// ============================================================
//  IMPORTANT: This file is a PLACEHOLDER.
//  You must replace it by running:
//
//    flutterfire configure
//
//  in your project directory after setting up Firebase.
//  See README.md for full setup instructions.
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run flutterfire configure to generate real options.',
        );
    }
  }

  // ── Replace ALL values below with your actual Firebase project values ──

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDt_B7LhfAFHHfI5OxozTMGrdsrVYEzpk4',
    appId: '1:596213234164:web:41cd13382c5535687ce1a1',
    messagingSenderId: '596213234164',
    projectId: 'smart-trash23',
    authDomain: 'smart-trash23.firebaseapp.com',
    databaseURL: 'https://smart-trash23-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smart-trash23.firebasestorage.app',
    measurementId: 'G-SCYSPRHQ08',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsfVg0pBqtzZ6euSg4NCUVP1wRyxivbwE',
    appId: '1:596213234164:android:a08c30cd80319a137ce1a1',
    messagingSenderId: '596213234164',
    projectId: 'smart-trash23',
    databaseURL: 'https://smart-trash23-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smart-trash23.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    databaseURL: 'YOUR_RTDB_URL',
    iosBundleId: 'com.tripleb.smartTrash',
  );
}