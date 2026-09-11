# أبو أروى — APK Ready

تم تجهيز المشروع كـFlutter Android project، بما في ذلك مجلد `android/` وملفات Gradle وManifest وMainActivity.

## قبل أول Build

1. ثبّت Flutter وAndroid Studio على Windows.
2. افتح Terminal داخل مجلد المشروع.
3. شغّل:

```bash
flutter doctor
flutter pub get
```

4. **اربط Firebase الحقيقي** قبل الاستخدام المشترك بين الأجهزة:

```bash
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login
flutterfire configure
```

اختر مشروع Firebase الخاص بـ"أبو أروى" والمنصة Android. هذا سيستبدل `lib/firebase_options.dart` ويضيف إعداد Android الصحيح.

5. ضع اللوجو الحقيقي في:

`assets/images/logo.png`

إذا كان الكود يستخدم `logo.png`، تأكد أن الملف موجود بهذا الاسم.

## إخراج APK

```bash
flutter build apk --release
```

الملف:

`build/app/outputs/flutter-apk/app-release.apk`

أو على Windows شغّل:

`scripts/prepare_and_build.bat`

## مهم

النسخة الحالية مهيأة للبناء، لكن **بيانات Firebase داخل المشروع Placeholder** وليست بيانات مشروع حقيقي. لا يمكنني اختراع بيانات Firebase الخاصة بك. بعد تنفيذ `flutterfire configure` يصبح الربط حقيقيًا.

الـRelease الحالي يستخدم توقيع debug للتوزيع الداخلي فقط. قبل النشر على Google Play أو اعتماد تحديثات مستقبلية، أنشئ Release/Upload Keystore خاصًا بك.
