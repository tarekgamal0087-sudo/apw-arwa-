import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة قسم جديد'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اسم القسم'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ProductProvider>().addCategory(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الأقسام')),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.accentOrange,
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productProvider.categories.length,
          itemBuilder: (context, index) {
            final cat = productProvider.categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(cat.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.danger),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('حذف القسم'),
                        content: Text(
                            'هل أنت متأكد من حذف قسم "${cat.name}"؟\nملاحظة: المنتجات الموجودة بهذا القسم لن تُحذف لكن لن تظهر ضمن أي قسم.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('إلغاء')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('حذف',
                                  style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await productProvider.deleteCategory(cat.id);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
