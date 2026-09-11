import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ضع ملف اللوجو الرسمي (PNG بخلفية شفافة) في المسار التالي بالضبط:
/// assets/images/logo.png
///
/// بمجرد وضعه هناك، هذا الويدجت سيعرضه تلقائيًا في كل الشاشات
/// (Splash - تسجيل الدخول - الرئيسية - لوحة تحكم Admin) بدون أي تعديل آخر
/// في اللوجو نفسه (بدون تغيير أبعاده أو ألوانه أو إضافة نص عليه)
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Placeholder مؤقت لحين رفع ملف اللوجو الرسمي في assets/images/logo.png
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          alignment: Alignment.center,
          child: Text(
            'أ.أ',
            style: TextStyle(
              color: AppColors.accentOrange,
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
