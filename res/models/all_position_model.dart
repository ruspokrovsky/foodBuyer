import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllPositionModel {
  String? docId;
  String productName;
  String productMeasure;
  String productFirsPrice;
  String productPrice;
  String productQuantity;
  num marginality;
  int deliverSelectedTime;


  bool available;
  String categoryProduct;
  String? subCategoryId;
  String deliverId;
  String deliverName;

  double cartQty;
  double amount;
  bool? isSelected;

  num? united;

  String productImage;

  AllPositionModel({
    this.docId,
    required this.productName,
    required this.productMeasure,
    required this.productFirsPrice,
    required this.productPrice,
    required this.productQuantity,
    required this.marginality,
    required this.deliverSelectedTime,

    required this.available,
    required this.categoryProduct,
    this.subCategoryId,
    required this.deliverId,
    required this.deliverName,


    required this.cartQty,
    required this.amount,
    this.isSelected = false,
    this.united,
    required this.productImage,
  });

  Map<String, dynamic> toJsonForDb() => {
    "productName": productName,
    "productMeasure": productMeasure,
    "productFirsPrice": productFirsPrice,
    "productPrice": productPrice,
    "productQuantity": productQuantity,
    "marginality": marginality,
    "deliverSelectedTime": deliverSelectedTime,
    "available": available,
    "categoryProduct": categoryProduct,
    "deliverId": deliverId,
    "deliverName": deliverName,
    "productImage": productImage,

  };

  Map<String, dynamic> toJson() => {
        "docId": docId,
        "productName": productName,
        "productMeasure": productMeasure,
        "productFirsPrice": productFirsPrice,
        "productPrice": productPrice,
        "productQuantity": productQuantity,
        "marginality": marginality,
        "deliverSelectedTime": deliverSelectedTime,
        "available": available,
        "categoryProduct": categoryProduct,
        "deliverId": deliverId,
        "deliverName": deliverName,
        "united": united,
        "productImage": productImage,

      };

  static AllPositionModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;

    return AllPositionModel(
      docId: docId,
      productName: snapshot['productName'] ?? 'positionName',
      productMeasure: snapshot['productMeasure'] ?? 'positionMeasure',
      productFirsPrice: snapshot['productFirsPrice'] ?? 'positionFirsPrice',
      productPrice: snapshot['productPrice'] ?? 'positionPrice',
      productQuantity: snapshot['productQuantity'] ?? 'productQuantity',
      marginality: snapshot['marginality'] ?? 0,
      deliverSelectedTime: snapshot['deliverSelectedTime'] ?? 0,

      available: snapshot['available'] ?? false,
      categoryProduct: snapshot['categoryProduct'] ?? 'categoryProduct',
      deliverId: snapshot['deliverId'] ?? 'deliverSelectedTime',
      deliverName: snapshot['deliverName'] ?? 'deliverName',
      cartQty: 0.0,
      amount: 0.0,
      united: snapshot['united'] ?? 0.0,
      productImage: snapshot['productImage'] ?? '',

    );
  }



  static AllPositionModel snapFromDoc(DocumentSnapshot snap) {

    String docid = snap.id;

    return AllPositionModel(
        docId: docid,
        productName: snap['productName'],
        productMeasure: snap['productMeasure'],
        productFirsPrice: snap['productFirsPrice'],
        productPrice: snap['productPrice'],
        productQuantity: snap['productQuantity'],
        marginality: snap['marginality'],
        deliverSelectedTime: snap['deliverSelectedTime'],
        available: snap['available'],
        categoryProduct: snap['categoryProduct'],
        deliverId: snap['deliverId'],
        deliverName: snap['deliverName'],
        cartQty: 0,
        amount: 0,
        productImage: snap['productImage'],
        united: snap['united'],
    );
  }

  static AllPositionModel empty() {
    return AllPositionModel(
        docId: '',
        productName: '',
        productMeasure: '',
        productFirsPrice: '',
        productPrice: '',
        productQuantity: '',
        marginality: 0,
        deliverSelectedTime: 0,
        available: false,
        categoryProduct: '',
        deliverId: '',
        deliverName: '',
        cartQty: 0,
        amount: 0,
        productImage: '');
  }

}
