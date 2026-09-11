import 'package:cloud_firestore/cloud_firestore.dart';

class PriceLogModel {
  final String id;
  final String productId;
  final String productName;
  final double oldSellPrice;
  final double newSellPrice;
  final double oldWholesalePrice;
  final double newWholesalePrice;
  final String editedByUid;
  final String editedByName;
  final DateTime date;

  PriceLogModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.oldSellPrice,
    required this.newSellPrice,
    required this.oldWholesalePrice,
    required this.newWholesalePrice,
    required this.editedByUid,
    required this.editedByName,
    required this.date,
  });

  factory PriceLogModel.fromMap(String id, Map<String, dynamic> map) {
    return PriceLogModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      oldSellPrice: (map['oldSellPrice'] ?? 0).toDouble(),
      newSellPrice: (map['newSellPrice'] ?? 0).toDouble(),
      oldWholesalePrice: (map['oldWholesalePrice'] ?? 0).toDouble(),
      newWholesalePrice: (map['newWholesalePrice'] ?? 0).toDouble(),
      editedByUid: map['editedByUid'] ?? '',
      editedByName: map['editedByName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'oldSellPrice': oldSellPrice,
      'newSellPrice': newSellPrice,
      'oldWholesalePrice': oldWholesalePrice,
      'newWholesalePrice': newWholesalePrice,
      'editedByUid': editedByUid,
      'editedByName': editedByName,
      'date': Timestamp.fromDate(date),
    };
  }
}
