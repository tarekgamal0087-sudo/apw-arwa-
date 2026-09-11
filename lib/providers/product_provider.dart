import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

/// هذا الـ Provider هو "مصدر الحقيقة الوحيد" لكل بيانات المنتجات داخل التطبيق
/// أي شاشة تحتاج منتجات تقرأ منه فقط، ولا تتواصل مع Firestore مباشرة
///
/// لماذا Provider تحديدًا كإدارة حالة (State Management)؟
/// - المشروع متوسط الحجم وليس ضخمًا، فـ Provider يعطي بساطة ووضوح بدون تعقيد
///   زيادة عن الحاجة (مقارنة بـ Bloc مثلًا).
/// - يتكامل بسهولة شديدة مع StreamBuilder / Firestore Streams (تحديث لحظي).
/// - سهل الشرح والصيانة لمطور مبتدئ أو فريق صغير مستقبلًا.
/// - مدعوم رسميًا وموصى به من فريق Flutter نفسه لمعظم التطبيقات.
class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _allProducts = [];
  List<CategoryModel> categories = [];
  bool isLoading = true;

  String searchQuery = '';
  String? selectedCategoryId;

  ProductProvider() {
    _listen();
  }

  void _listen() {
    _firestoreService.getAllProducts().listen((products) {
      _allProducts = products;
      isLoading = false;
      notifyListeners();
    });

    _firestoreService.getCategories().listen((cats) {
      categories = cats;
      notifyListeners();
    });
  }

  List<ProductModel> get recentProducts => _allProducts.take(10).toList();

  /// أكثر المنتجات فتحًا (مرتبة تنازليًا حسب عدد مرات الفتح)
  /// المنتجات اللي عدد فتحها صفر (لسه محدش فتحها) بتتجاهل من القائمة دي
  List<ProductModel> get mostUsedProducts {
    final withViews = _allProducts.where((p) => p.viewCount > 0).toList();
    withViews.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return withViews.take(10).toList();
  }

  Future<void> registerProductView(String productId) =>
      _firestoreService.incrementViewCount(productId);

  List<ProductModel> get filteredProducts {
    Iterable<ProductModel> result = _allProducts;

    if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
      result = result.where((p) => p.categoryId == selectedCategoryId);
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((p) =>
          p.searchKeywords.contains(q) ||
          p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q));
    }

    return result.toList();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  void clearFilters() {
    searchQuery = '';
    selectedCategoryId = null;
    notifyListeners();
  }

  CategoryModel? categoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int get totalProductsCount => _allProducts.length;

  Future<void> addProduct(ProductModel product) =>
      _firestoreService.addProduct(product);

  Future<void> updateProduct(ProductModel oldP, ProductModel newP) =>
      _firestoreService.updateProduct(oldProduct: oldP, newProduct: newP);

  Future<void> deleteProduct(String id) =>
      _firestoreService.deleteProduct(id);

  Future<void> addCategory(String name) =>
      _firestoreService.addCategory(name, categories.length);

  Future<void> deleteCategory(String id) =>
      _firestoreService.deleteCategory(id);
}
