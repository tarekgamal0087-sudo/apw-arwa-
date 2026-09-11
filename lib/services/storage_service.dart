import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// كل التعامل مع رفع صور المنتجات يمر من هنا فقط
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(String productId, File imageFile) async {
    final ref = _storage.ref().child('product_images/$productId.jpg');
    final task = await ref.putFile(imageFile);
    return await task.ref.getDownloadURL();
  }

  Future<void> deleteProductImage(String productId) async {
    try {
      final ref = _storage.ref().child('product_images/$productId.jpg');
      await ref.delete();
    } catch (_) {
      // الصورة غير موجودة أصلًا، نتجاهل الخطأ
    }
  }
}
