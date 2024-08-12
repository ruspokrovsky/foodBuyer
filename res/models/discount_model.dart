import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountModel {
  String? docId;
  String positionId;
  String? rootId;
  num quantity;
  num percent;

  DiscountModel({this.docId, required this.positionId, this.rootId, required this.quantity, required this.percent});


  Map<String, dynamic> toJson() => {
        "docId": docId,
        "positionId": positionId,
        "quantity": quantity,
        "percent": percent,
      };

  Map<String, dynamic> toJsonForDb() => {
    "positionId": positionId,
    "quantity": quantity,
    "percent": percent,
  };

  static DiscountModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;


    return DiscountModel(
      docId: docId,
      positionId: snapshot['positionId'] ?? '',
      quantity: snapshot['quantity'] ?? 0,
      percent: snapshot['percent'] ?? 0,
    );
  }

  static DiscountModel empty() {
    return DiscountModel(positionId: '', quantity: 0, percent: 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DiscountModel &&
              positionId == other.positionId &&
              quantity == other.quantity &&
              percent == other.percent;

  @override
  int get hashCode =>
      positionId.hashCode ^ quantity.hashCode ^ percent.hashCode;
}