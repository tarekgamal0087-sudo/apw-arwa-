import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String code;
  final String categoryId;
  final double sellPrice;
  final double wholesalePrice;
  final List<String> sizes;
  final List<String> colors;
  final int quantity;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastEditedByUid;
  final String lastEditedByName;

  // حقل مساعد للبحث الجزئي والسريع (اسم بدون تشكيل ومسافات زائدة، بأحرف صغيرة)
  final String searchKeywords;
  final int viewCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.code,
    required this.categoryId,
    required this.sellPrice,
    required this.wholesalePrice,
    required this.sizes,
    required this.colors,
    required this.quantity,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.lastEditedByUid,
    required this.lastEditedByName,
    required this.searchKeywords,
    this.viewCount = 0,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      categoryId: map['categoryId'] ?? '',
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      wholesalePrice: (map['wholesalePrice'] ?? 0).toDouble(),
      sizes: List<String>.from(map['sizes'] ?? []),
      colors: List<String>.from(map['colors'] ?? []),
      quantity: (map['quantity'] ?? 0) is int
          ? map['quantity']
          : (map['quantity'] as num).toInt(),
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastEditedByUid: map['lastEditedByUid'] ?? '',
      lastEditedByName: map['lastEditedByName'] ?? '',
      searchKeywords: map['searchKeywords'] ?? '',
      viewCount: (map['viewCount'] ?? 0) is int
          ? map['viewCount']
          : (map['viewCount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'categoryId': categoryId,
      'sellPrice': sellPrice,
      'wholesalePrice': wholesalePrice,
      'sizes': sizes,
      'colors': colors,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastEditedByUid': lastEditedByUid,
      'lastEditedByName': lastEditedByName,
      'searchKeywords': searchKeywords,
      'viewCount': viewCount,
    };
  }

  /// يبني كلمات البحث الجزئي: يقسم اسم المنتج والكود إلى مقاطع فرعية
  /// حتى يعمل البحث بجزء من الاسم (مثال: "بولو" داخل "تيشيرت بولو أطفال")
  static String buildSearchKeywords(String name, String code) {
    final normalized = '$name $code'.trim().toLowerCase();
    return normalized;
  }
}
