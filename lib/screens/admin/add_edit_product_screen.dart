import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // null = إضافة منتج جديد
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _sellPriceController;
  late TextEditingController _wholesalePriceController;
  late TextEditingController _quantityController;
  late TextEditingController _sizesController;
  late TextEditingController _colorsController;

  String? _selectedCategoryId;
  File? _pickedImage;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _codeController = TextEditingController(text: p?.code ?? '');
    _sellPriceController =
        TextEditingController(text: p != null ? p.sellPrice.toString() : '');
    _wholesalePriceController = TextEditingController(
        text: p != null ? p.wholesalePrice.toString() : '');
    _quantityController =
        TextEditingController(text: p != null ? p.quantity.toString() : '0');
    _sizesController = TextEditingController(text: p?.sizes.join('، ') ?? '');
    _colorsController =
        TextEditingController(text: p?.colors.join('، ') ?? '');
    _selectedCategoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _sellPriceController.dispose();
    _wholesalePriceController.dispose();
    _quantityController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  List<String> _splitCommaList(String text) {
    return text
        .split(RegExp(r'[،,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      Fluttertoast.showToast(msg: 'برجاء اختيار القسم');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthProvider>();
      final productProvider = context.read<ProductProvider>();

      final id = widget.product?.id ?? const Uuid().v4();

      String imageUrl = widget.product?.imageUrl ?? '';
      if (_pickedImage != null) {
        imageUrl = await _storageService.uploadProductImage(id, _pickedImage!);
      }

      final name = _nameController.text.trim();
      final code = _codeController.text.trim();

      final newProduct = ProductModel(
        id: id,
        name: name,
        code: code,
        categoryId: _selectedCategoryId!,
        sellPrice: double.parse(_sellPriceController.text),
        wholesalePrice: double.tryParse(_wholesalePriceController.text) ?? 0,
        sizes: _splitCommaList(_sizesController.text),
        colors: _splitCommaList(_colorsController.text),
        quantity: int.tryParse(_quantityController.text) ?? 0,
        imageUrl: imageUrl,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        lastEditedByUid: auth.currentUser?.uid ?? '',
        lastEditedByName: auth.currentUser?.name ?? '',
        searchKeywords: ProductModel.buildSearchKeywords(name, code),
      );

      if (isEditing) {
        await productProvider.updateProduct(widget.product!, newProduct);
      } else {
        await productProvider.addProduct(newProduct);
      }

      if (mounted) {
        Fluttertoast.showToast(
            msg: isEditing ? 'تم تعديل المنتج بنجاح' : 'تم إضافة المنتج بنجاح');
        Navigator.of(context).pop();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_pickedImage!, fit: BoxFit.cover),
                        )
                      : (widget.product?.imageUrl.isNotEmpty ?? false)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(widget.product!.imageUrl,
                                  fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    size: 36, color: AppColors.textGray),
                                SizedBox(height: 8),
                                Text('إضافة صورة المنتج',
                                    style:
                                        TextStyle(color: AppColors.textGray)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل اسم المنتج' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'كود المنتج'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل كود المنتج' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'القسم'),
                items: productProvider.categories
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellPriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'سعر البيع (ج.م)'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'مطلوب';
                        if (double.tryParse(v) == null) return 'رقم غير صحيح';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _wholesalePriceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'سعر الجملة (ج.م)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الكمية المتاحة'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sizesController,
                decoration: const InputDecoration(
                  labelText: 'المقاسات (افصل بينها بفاصلة)',
                  hintText: 'مثال: S، M، L، XL',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorsController,
                decoration: const InputDecoration(
                  labelText: 'الألوان (افصل بينها بفاصلة)',
                  hintText: 'مثال: أسود، أبيض، كحلي',
                ),
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المنتج'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
