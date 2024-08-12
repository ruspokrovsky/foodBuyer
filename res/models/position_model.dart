import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class PositionModel {
  String projectRootId;
  String? docId;
  String productName;
  String productMeasure;
  num productFirsPrice;
  num productPrice;
  num productQuantity;
  num marginality;
  int deliverSelectedTime;
  bool available;
  String subCategoryName;
  String subCategoryId;
  String deliverId;
  String deliverName;
  num? cartQty;
  num amount;
  bool? isSelected;
  num united;
  String productImage;

  UserModel? userModel;
  List<DiscountModel>? discountList;
  List<dynamic>? unitedList;
  int addedAt;
  bool? ndsStatus;

  PositionModel({
    this.docId,
    required this.projectRootId,
    required this.productName,
    required this.productMeasure,
    required this.productFirsPrice,
    required this.productPrice,
    required this.productQuantity,
    required this.marginality,
    required this.deliverSelectedTime,

    required this.available,
    required this.subCategoryName,
    required this.subCategoryId,
    required this.deliverId,
    required this.deliverName,


    this.cartQty,
    required this.amount,
    this.isSelected = false,
    required this.united,
    required this.productImage,
    this.userModel,
    this.discountList,
    this.unitedList,
    this.ndsStatus,
    required this.addedAt,
  });

  Map<String, dynamic> toJsonForDb() => {
    "projectRootId": projectRootId,
    "productName": productName,
    "productMeasure": productMeasure,
    "productFirsPrice": productFirsPrice,
    "productPrice": productPrice,
    "productQuantity": productQuantity,
    "marginality": marginality,
    "deliverSelectedTime": deliverSelectedTime,
    "available": available,
    "subCategoryName": subCategoryName,
    "subCategoryId": subCategoryId,
    "deliverId": deliverId,
    "deliverName": deliverName,
    "united": united,
    "productImage": productImage,
    "unitedList": unitedList,
    "addedAt": addedAt,
    "ndsStatus": ndsStatus,

  };

  Map<String, dynamic> toJson() => {
        "projectRootId": projectRootId,
        "docId": docId,
        "productName": productName,
        "productMeasure": productMeasure,
        "productFirsPrice": productFirsPrice,
        "productPrice": productPrice,
        "productQuantity": productQuantity,
        "marginality": marginality,
        "deliverSelectedTime": deliverSelectedTime,
        "available": available,
        "subCategoryName": subCategoryName,
        "subCategoryId": subCategoryId,
        "deliverId": deliverId,
        "deliverName": deliverName,
        "united": united,
        "productImage": productImage,
        "unitedList": unitedList,
        "ndsStatus": ndsStatus,
        "addedAt": addedAt,

      };

  static PositionModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;


    return PositionModel(
      projectRootId: snapshot['projectRootId'] ?? 'projectRootId',
      docId: docId,
      productName: snapshot['productName'] ?? 'positionName',
      productMeasure: snapshot['productMeasure'] ?? 'positionMeasure',
      productFirsPrice: snapshot['productFirsPrice'] ?? 0,
      productPrice: snapshot['productPrice'] ?? 0,
      productQuantity: snapshot['productQuantity'] ?? 0,
      marginality: snapshot['marginality'] ?? 0,
      deliverSelectedTime: snapshot['deliverSelectedTime'] ?? 0,

      available: snapshot['available'] ?? false,
      subCategoryId: snapshot['subCategoryId'] ?? '',
      subCategoryName: snapshot['subCategoryName'] ?? '',
      deliverId: snapshot['deliverId'] ?? '',
      deliverName: snapshot['deliverName'] ?? '',
      cartQty: 0.0,
      amount: 0.0,
      united: snapshot['united'] ?? 0,
      productImage: snapshot['productImage'] ?? '',
      unitedList: snapshot['unitedList'] ?? [],
      ndsStatus: snapshot['ndsStatus'] ?? false,
      addedAt: snapshot['addedAt'] ?? 0,


    );
  }



  static snapFromDoc(DocumentSnapshot data) {

    Map<String, dynamic>  snap = data.data() as Map<String, dynamic>;


    String docid = data.id;

    return PositionModel(
      projectRootId: snap['projectRootId'],
      docId: docid,
      productName: snap['productName'],
      productMeasure: snap['productMeasure'],
      productFirsPrice: snap['productFirsPrice'],
      productPrice: snap['productPrice'],
      productQuantity: snap['productQuantity'],
      marginality: snap['marginality'],
      deliverSelectedTime: snap['deliverSelectedTime'],
      available: snap['available'],
      subCategoryName: snap['subCategoryName'],
      subCategoryId: snap['subCategoryId'],
      deliverId: snap['deliverId'],
      deliverName: snap['deliverName'],
      cartQty: 0,
      amount: 0,
      productImage: snap['productImage'],
      united: snap['united'],
      unitedList: snap['unitedList'],
      addedAt: snap['addedAt']??0,
    );
  }



  static PositionModel empty() {
    return PositionModel(
        projectRootId: '',
        docId: '',
        productName: '',
        productMeasure: '',
        productFirsPrice: 0,
        productPrice: 0,
        productQuantity: 0,
        marginality: 0,
        deliverSelectedTime: 0,
        available: false,
        subCategoryName: '',
        deliverId: '',
        deliverName: '',
        cartQty: 0,
        amount: 0,
        productImage: '',
        subCategoryId: '',
        united: 0,
        unitedList: [],
        addedAt: 0,
    );
  }

}
