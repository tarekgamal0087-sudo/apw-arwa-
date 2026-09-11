import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../theme/app_theme.dart';

/// شريط صغير يظهر أعلى الشاشة عند انقطاع الإنترنت
/// البيانات تبقى تظهر من آخر نسخة محفوظة محليًا (Firestore Offline Cache)
/// وعند عودة الإنترنت تتم المزامنة تلقائيًا بدون أي إجراء من المستخدم
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.contains(ConnectivityResult.none) &&
          results.length == 1;
      if (mounted) setState(() => _isOffline = offline);
    });
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    final offline = result.contains(ConnectivityResult.none);
    if (mounted) setState(() => _isOffline = offline);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.danger,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Text(
        'لا يوجد اتصال بالإنترنت - تُعرض آخر بيانات محفوظة',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
