import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import 'add_edit_product_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_users_screen.dart';
import 'price_log_screen.dart';
import 'admin_products_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة تحكم المدير')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إجمالي عدد المنتجات',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(
                    '${productProvider.totalProductsCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _DashboardTile(
              icon: Icons.add_box_outlined,
              title: 'إضافة منتج جديد',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AddEditProductScreen()),
              ),
            ),
            _DashboardTile(
              icon: Icons.inventory_2_outlined,
              title: 'إدارة المنتجات (تعديل / حذف)',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminProductsListScreen()),
              ),
            ),
            _DashboardTile(
              icon: Icons.category_outlined,
              title: 'إدارة الأقسام',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ManageCategoriesScreen()),
              ),
            ),
            _DashboardTile(
              icon: Icons.people_outline,
              title: 'إدارة المستخدمين',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
              ),
            ),
            _DashboardTile(
              icon: Icons.history,
              title: 'سجل تغييرات الأسعار',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PriceLogScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryNavy.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primaryNavy),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_back_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
