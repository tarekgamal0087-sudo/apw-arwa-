import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/price_log_model.dart';

/// كل التعامل مع Firestore يمر من هنا فقط (Products, Categories, Price Logs)
/// هذا يسهل تطوير المشروع مستقبلًا لأن الشاشات لا تتعامل مع Firebase مباشرة أبدًا
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection('categories');
  CollectionReference<Map<String, dynamic>> get _priceLogs =>
      _db.collection('priceLogs');

  /// تفعيل التخزين المحلي (Offline Persistence)
  /// يجب استدعاؤها مرة واحدة فقط عند بدء التطبيق قبل أي استخدام آخر لـ Firestore
  static void enableOfflinePersistence() {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // ---------------- الأقسام ----------------

  Stream<List<CategoryModel>> getCategories() {
    return _categories.orderBy('order').snapshots().map((snap) =>
        snap.docs.map((d) => CategoryModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> addCategory(String name, int order) async {
    await _categories.add({'name': name, 'order': order});
  }

  Future<void> updateCategory(String id, String name) async {
    await _categories.doc(id).update({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await _categories.doc(id).delete();
  }

  /// إنشاء الأقسام الافتراضية أول مرة فقط (تُستدعى مرة واحدة عند إعداد المشروع)
  Future<void> seedDefaultCategoriesIfEmpty() async {
    final snap = await _categories.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final defaults = ['رجالي', 'حريمي', 'أطفال', 'مفروشات'];
    for (var i = 0; i < defaults.length; i++) {
      await _categories.add({'name': defaults[i], 'order': i});
    }
  }

  // ---------------- المنتجات ----------------

  /// نستمع لكل المنتجات مرة واحدة عبر Stream (real-time)
  /// وهذا ما يجعل السعر يتحدث فورًا على كل الأجهزة بدون أي إجراء يدوي
  Stream<List<ProductModel>> getAllProducts() {
    return _products
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> addProduct(ProductModel product) async {
    await _products.doc(product.id).set(product.toMap());
  }

  /// تعديل منتج + تسجيل تلقائي في سجل تغييرات الأسعار لو تغيّر السعر
  Future<void> updateProduct({
    required ProductModel oldProduct,
    required ProductModel newProduct,
  }) async {
    await _products.doc(newProduct.id).update(newProduct.toMap());

    final priceChanged = oldProduct.sellPrice != newProduct.sellPrice ||
        oldProduct.wholesalePrice != newProduct.wholesalePrice;

    if (priceChanged) {
      await _priceLogs.add(PriceLogModel(
        id: '',
        productId: newProduct.id,
        productName: newProduct.name,
        oldSellPrice: oldProduct.sellPrice,
        newSellPrice: newProduct.sellPrice,
        oldWholesalePrice: oldProduct.wholesalePrice,
        newWholesalePrice: newProduct.wholesalePrice,
        editedByUid: newProduct.lastEditedByUid,
        editedByName: newProduct.lastEditedByName,
        date: DateTime.now(),
      ).toMap());
    }
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  /// يزيد عدد مرات فتح المنتج بمقدار 1 في كل مرة يدخل فيها موظف على تفاصيله
  /// هذا هو الأساس اللي هنعتمد عليه في حساب "المنتجات الأكثر استخدامًا"
  Future<void> incrementViewCount(String productId) async {
    await _products.doc(productId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Stream<List<PriceLogModel>> getPriceLogs() {
    return _priceLogs
        .orderBy('date', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PriceLogModel.fromMap(d.id, d.data())).toList());
  }
}
