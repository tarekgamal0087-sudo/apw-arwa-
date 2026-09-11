import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import 'add_edit_product_screen.dart';

class AdminProductsListScreen extends StatefulWidget {
  const AdminProductsListScreen({super.key});

  @override
  State<AdminProductsListScreen> createState() =>
      _AdminProductsListScreenState();
}

class _AdminProductsListScreenState extends State<AdminProductsListScreen> {
  final _searchController = TextEditingController();
  String _localQuery = '';

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final products = productProvider.filteredProducts.where((p) {
      if (_localQuery.isEmpty) return true;
      return p.searchKeywords.contains(_localQuery.toLowerCase());
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة المنتجات')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _localQuery = v),
                decoration: const InputDecoration(
                  hintText: 'بحث سريع...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.border,
                        backgroundImage: product.imageUrl.isNotEmpty
                            ? NetworkImage(product.imageUrl)
                            : null,
                        child: product.imageUrl.isEmpty
                            ? const Icon(Icons.checkroom,
                                color: AppColors.textGray)
                            : null,
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                          'كود: ${product.code} - ${Formatters.currency(product.sellPrice)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primaryNavy),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    AddEditProductScreen(product: product),
                              ));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.danger),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('حذف المنتج'),
                                  content: Text(
                                      'هل أنت متأكد من حذف "${product.name}"؟'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('إلغاء')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('حذف',
                                            style: TextStyle(
                                                color: AppColors.danger))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await productProvider
                                    .deleteProduct(product.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
