import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'admin/add_edit_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductModel get product => widget.product;

  @override
  void initState() {
    super.initState();
    // نسجّل مشاهدة واحدة لهذا المنتج عند فتح الشاشة (لحساب "الأكثر استخدامًا")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().registerProductView(product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final category = productProvider.categoryById(product.categoryId);
    final canSeeWholesale =
        auth.isAdmin || (auth.currentUser?.canSeeWholesalePrice ?? false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          actions: [
            if (auth.isAdmin)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddEditProductScreen(product: product),
                  ));
                },
              ),
          ],
        ),
        body: ListView(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.border,
                      child: const Icon(Icons.checkroom,
                          size: 80, color: AppColors.textGray),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('كود المنتج: ${product.code}',
                      style: const TextStyle(color: AppColors.textGray)),
                  if (category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Chip(
                        label: Text(category.name),
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  const SizedBox(height: 20),
                  _PriceBox(
                    label: 'سعر البيع',
                    value: Formatters.currency(product.sellPrice),
                    highlighted: true,
                  ),
                  if (canSeeWholesale) ...[
                    const SizedBox(height: 10),
                    _PriceBox(
                      label: 'سعر الجملة',
                      value: Formatters.currency(product.wholesalePrice),
                      highlighted: false,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (product.sizes.isNotEmpty) ...[
                    const Text('المقاسات المتاحة',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: product.sizes
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (product.colors.isNotEmpty) ...[
                    const Text('الألوان المتاحة',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: product.colors
                          .map((c) => Chip(label: Text(c)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 18, color: AppColors.textGray),
                      const SizedBox(width: 6),
                      Text('الكمية المتاحة: ${product.quantity}'),
                    ],
                  ),
                  if (auth.isAdmin) ...[
                    const Divider(height: 32),
                    Text('آخر تعديل: ${Formatters.date(product.updatedAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGray)),
                    if (product.lastEditedByName.isNotEmpty)
                      Text('بواسطة: ${product.lastEditedByName}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGray)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _PriceBox(
      {required this.label, required this.value, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primaryNavy
            : AppColors.primaryNavy.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlighted ? Colors.white70 : AppColors.textGray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: highlighted ? Colors.white : AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
