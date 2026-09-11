// ملف مؤقت (Placeholder) فقط.
//
// هذا الملف يتم توليده تلقائيًا وبشكل صحيح 100% عن طريق أمر واحد
// اسمه: flutterfire configure
//
// لا تكتب فيه أي بيانات يدويًا. اتبع خطوات "ربط Firebase" في الرسالة
// المرفقة، وبعد تنفيذ الأمر سيتم استبدال هذا الملف بالكامل تلقائيًا
// بالقيم الحقيقية الخاصة بمشروعك على Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'هذا المشروع مُعد لتطبيق Android فقط حاليًا.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'هذا المشروع مُعد لتطبيق Android فقط حاليًا.',
        );
    }
  }

  // ⚠️ هذه قيم وهمية مؤقتة سيتم استبدالها تلقائيًا بعد تنفيذ:
  // flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_AFTER_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_AFTER_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_AFTER_FLUTTERFIRE_CONFIGURE',
    projectId: 'REPLACE_AFTER_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REPLACE_AFTER_FLUTTERFIRE_CONFIGURE',
  );
}
