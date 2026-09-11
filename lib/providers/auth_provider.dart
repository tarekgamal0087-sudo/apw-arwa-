import 'package:flutter/foundation.dart';
import '../models/app_user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, loggedOut, loggedIn }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.checking;
  AppUserModel? currentUser;
  String? errorMessage;
  bool isLoading = false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        status = AuthStatus.loggedOut;
        currentUser = null;
      } else {
        final appUser = await _authService.getCurrentAppUser();
        if (appUser != null && appUser.isActive) {
          currentUser = appUser;
          status = AuthStatus.loggedIn;
        } else {
          await _authService.signOut();
          status = AuthStatus.loggedOut;
          currentUser = null;
        }
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      currentUser = user;
      status = AuthStatus.loggedIn;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _mapError(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    currentUser = null;
    status = AuthStatus.loggedOut;
    notifyListeners();
  }

  bool get isAdmin => currentUser?.isAdmin ?? false;

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found') || msg.contains('wrong-password') ||
        msg.contains('invalid-credential')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('invalid-email')) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    if (msg.contains('network')) {
      return 'تحقق من الاتصال بالإنترنت وحاول مرة أخرى';
    }
    if (msg.contains('موقوف')) {
      return 'هذا الحساب موقوف. برجاء التواصل مع المدير';
    }
    return 'حدث خطأ، برجاء المحاولة مرة أخرى';
  }
}
