import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user_model.dart';

/// كل التعامل مع تسجيل الدخول والخروج يمر من هنا فقط
/// حتى لو حبينا نغيّر طريقة الدخول مستقبلًا (مثلاً برقم الهاتف) نعدل هنا فقط
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  /// كل موظف/مدير له بريد إلكتروني خاص به يقوم المدير بإنشائه من لوحة التحكم
  Future<AppUserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      await _auth.signOut();
      throw Exception('هذا الحساب غير مسجل في قاعدة بيانات المستخدمين');
    }

    final appUser = AppUserModel.fromMap(uid, userDoc.data()!);

    if (!appUser.isActive) {
      await _auth.signOut();
      throw Exception('هذا الحساب موقوف. برجاء التواصل مع المدير');
    }

    return appUser;
  }

  Future<void> signOut() => _auth.signOut();

  /// جلب بيانات المستخدم الحالي (الدور: مدير أو موظف)
  Future<AppUserModel?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUserModel.fromMap(user.uid, doc.data()!);
  }

  /// إنشاء حساب موظف جديد (يُستخدم من لوحة تحكم المدير فقط)
  ///
  /// ملاحظة فنية مهمة: استخدام createUserWithEmailAndPassword مباشرة كان
  /// سيُسجّل دخول تلقائيًا بحساب الموظف الجديد ويُخرج المدير من جلسته.
  /// لتفادي ذلك، ننشئ تطبيق Firebase ثانوي مؤقت (Secondary App) ننشئ به
  /// الحساب الجديد فقط، ثم نغلقه فورًا، بينما تظل جلسة المدير كما هي.
  Future<String> createEmployeeAccount({
    required String name,
    required String email,
    required String password,
    required bool canSeeWholesalePrice,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email.trim(),
        'role': 'employee',
        'canSeeWholesalePrice': canSeeWholesalePrice,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await secondaryAuth.signOut();
      return uid;
    } finally {
      await secondaryApp?.delete();
    }
  }

  Future<void> deactivateUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': false,
    });
  }

  Future<void> activateUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': true,
    });
  }

  Future<void> updateEmployeePermissions({
    required String uid,
    required bool canSeeWholesalePrice,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'canSeeWholesalePrice': canSeeWholesalePrice,
    });
  }

  Future<void> updateEmployeeName({
    required String uid,
    required String name,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
    });
  }

  Stream<List<AppUserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snap) => snap.docs
        .map((d) => AppUserModel.fromMap(d.id, d.data()))
        .toList());
  }
}
