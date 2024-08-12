import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class OrderModel {
  String? customerId;
  String projectRootId;
  String? orderId;
  String? docId;
  String? objectId;
  String? objectName;
  String productId;
  String productName;
  String productMeasure;
  String category;
  num productPrice;
  num productQuantity;
  num amountSum;
  int acceptedDate;
  num returnQty;
  String requestNote;
  int successStatus;
  int? index;
  num? united;

  bool? isSelected;
  String? productImage;

  num? discountPercent;
  num lastDiscountPercent;
  String rejectionReason;

  List<DiscountModel>? discountList;

  num? discountPrice;

  UserModel? userModel;

  num? discountSum;
  num? firstPrice;


  OrderModel({
    this.orderId,
    this.docId,
    this.objectId,
    this.objectName,
    this.customerId,
    required this.projectRootId,

    required this.productId,
    required this.productName,
    required this.productMeasure,
    required this.category,
    required this.productPrice,
    required this.productQuantity,
    required this.amountSum,
    required this.acceptedDate,
    required this.returnQty,
    required this.requestNote,
    required this.successStatus,
    this.index,
    this.united,
    this.isSelected = false,
    this.productImage,
    this.discountPercent,
    required this.lastDiscountPercent,
    required this.rejectionReason,
    this.discountList,
    this.discountPrice,

    this.userModel,
    this.discountSum,
    this.firstPrice,
  });




  Map<String, dynamic> toJsonForDb() => {
    'projectRootId': projectRootId,
    'productId': productId,
    'productName': productName,
    'productMeasure': productMeasure,
    'category': category,
    'productPrice': productPrice,
    'productQuantity': productQuantity,
    'amountSum': amountSum,
    'acceptedDate': acceptedDate,
    'returnQty': returnQty,
    'requestNote': requestNote,
    'successStatus': successStatus,
    'isSelected': isSelected,
    'discountPercent': discountPercent,
    'lastDiscountPercent': lastDiscountPercent,
    'rejectionReason': rejectionReason,
    'firstPrice': firstPrice,

  };

  Map<String, dynamic> toPurchasingJsonFromOrder() => {
    'projectRootId': projectRootId,
    'buyerId': '',
    'buyerName': '',
    'selectedTime': 0,
    'firsPrice': 0,
    'actualPrice': 0,
    'actualQty': 0,
    'productName': productName,
    'productId': productId,
    'productMeasure': productMeasure,
    'orderQty': productQuantity,
    'purchasingStatus': 0,
    'receivedQuantity': 0,
    'receivedDate': 0,
    'positionImgUrl': '',
  };

  Map<String, dynamic> toJson() => {
    'projectRootId': projectRootId,
    'docId': docId,
    'productId': productId,
    'objectId': objectId,
    'productName': productName,
    'productMeasure': productMeasure,
    'category': category,
    'productPrice': productPrice,
    'productQuantity': productQuantity,
    'amountSum': amountSum,
    'acceptedDate': acceptedDate,
    'returnQty': returnQty,
    'requestNote': requestNote,
    'successStatus': successStatus,
    'isSelected': isSelected,
    'discountPercent': discountPercent,
    'lastDiscountPercent': lastDiscountPercent,
    'rejectionReason': rejectionReason,
    'firstPrice': firstPrice,

      };

  static OrderModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;


    return OrderModel(
      projectRootId: snapshot['projectRootId'] ?? '',
      docId: docId,
      productId: snapshot['productId'] ?? '',
      productName: snapshot['productName'] ?? '',
      productMeasure: snapshot['productMeasure'] ?? '',
      category: snapshot['category'] ?? '',
      productPrice: snapshot['productPrice'] ?? 0,
      productQuantity: snapshot['productQuantity'] ?? 0,
      amountSum: snapshot['amountSum'] ?? 0,
      acceptedDate: snapshot['acceptedDate'] ?? 0,
      returnQty: snapshot['returnQty'] ?? 0,
      requestNote: snapshot['requestNote'] ?? '',
      successStatus: snapshot['successStatus'] ?? 0,
      discountPercent: snapshot['discountPercent'] ?? 0,
      lastDiscountPercent: snapshot['lastDiscountPercent'] ?? 0,
      rejectionReason: snapshot['rejectionReason'] ?? '',
      firstPrice: snapshot['firstPrice'] ?? 0,
    );
  }

}
