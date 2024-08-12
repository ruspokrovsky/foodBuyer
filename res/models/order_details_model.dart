import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class OrderDetailsModel {

  String projectRootId;

  String? docId;
  String userId;
  String objectId;
  String objectName;
  num objectDiscount;
  int requestDate;
  int deliverSelectedTime;
  String deliverId;
  String deliverName;
  num totalSum;
  int positionListLength;
  int orderStatus;
  int invoice;
  int addedAt;
  num cashback;

  num debtRepayment;

  List<OrderModel>? orderPositionsList;
  UserModel? userModel;


  OrderDetailsModel({
  required this.projectRootId,
  this.docId,
  required this.userId,
  required this.objectId,
  required this.objectName,
  required this.requestDate,
  required this.objectDiscount,
  required this.invoice,
  required this.orderStatus,
  required this.deliverSelectedTime,
  required this.deliverId,
  required this.deliverName,
  required this.totalSum,
  required this.positionListLength,
  required this.addedAt,
  this.orderPositionsList,
  required this.cashback,
  required this.debtRepayment,
  this.userModel,
  });


  Map<String, dynamic> toJsonForDb() => {
    'projectRootId':projectRootId,
    'userId':userId,
    'objectId':objectId,
    'objectName':objectName,
    'requestDate':requestDate,
    'objectDiscount':objectDiscount,
    'invoice':invoice,
    'orderStatus':orderStatus,
    'deliverSelectedTime':deliverSelectedTime,
    'deliverId':deliverId,
    'deliverName':deliverName,
    'totalSum':totalSum,
    'addedAt':addedAt,
    'positionListLength':positionListLength,
    'cashback': cashback ,
    'debtRepayment': debtRepayment ,
  };

  Map<String, dynamic> toJson() => {
    'projectRootId':projectRootId,
    'docId':docId,
    'userId':userId,
    'objectId':objectId,
    'objectName':objectName,
    'requestDate':requestDate,
    'objectDiscount':objectDiscount,
    'invoice':invoice,
    'orderStatus':orderStatus,
    'deliverSelectedTime':deliverSelectedTime,
    'deliverId':deliverId,
    'deliverName':deliverName,
    'totalSum':totalSum,
    'addedAt':addedAt,
    'positionListLength':positionListLength,
    'cashback': cashback,
    'debtRepayment': debtRepayment,
  };

  static OrderDetailsModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;

    return OrderDetailsModel(
      projectRootId: snapshot['projectRootId'] ?? 'projectRootId',
      docId: docId,
      userId:snapshot['userId'] ?? 'userId',
      objectId:snapshot['objectId'] ?? 'objectId',
      objectName:snapshot['objectName'] ?? 'objectName',
      requestDate:snapshot['requestDate'] ?? 0,
      objectDiscount:snapshot['objectDiscount'] ?? 0,
      invoice:snapshot['invoice'] ?? 0,
      orderStatus:snapshot['orderStatus'] ?? 0,
      deliverSelectedTime:snapshot['deliverSelectedTime'] ?? 0,
      deliverId:snapshot['deliverId'] ?? 'deliverId',
      deliverName:snapshot['deliverName'] ?? 'deliverName',
      totalSum:snapshot['totalSum'] ?? 0,
      addedAt:snapshot['addedAt'] ?? 0,
      positionListLength:snapshot['positionListLength'] ?? 0,
      orderPositionsList:snapshot['orderPositionsList'] ?? [],
      cashback: snapshot['cashback'] ?? 0,
      debtRepayment: snapshot['debtRepayment'] ?? 0,
    );
  }

  static OrderDetailsModel snapFromDoc(DocumentSnapshot snap) {

    String docid = snap.id;

    return OrderDetailsModel(
        projectRootId: snap['projectRootId'],
        docId: docid,
        userId: snap['userId'],
        objectId: snap['objectId'],
        objectName: snap['objectName'],
        requestDate: snap['requestDate'],
        objectDiscount: snap['objectDiscount'],
        invoice: snap['invoice'],
        orderStatus: snap['orderStatus'],
        deliverSelectedTime: snap['deliverSelectedTime'],
        deliverId: snap['deliverId'],
        deliverName: snap['deliverName'],
        totalSum: snap['totalSum'],
        positionListLength: snap['positionListLength'],
        addedAt: snap['addedAt'],
        cashback: snap['cashback'],
        debtRepayment: snap['debtRepayment']??0);
  }

  static empty(){
    return OrderDetailsModel(
        projectRootId: '',
        userId: '',
        objectId: '',
        objectName: '',
        requestDate: 0,
        objectDiscount: 0,
        invoice: 0,
        orderStatus: 0,
        deliverSelectedTime: 0,
        deliverId: '',
        deliverName: '',
        totalSum: 0,
        positionListLength: 0,
        addedAt: 0,
        cashback: 0,
        debtRepayment: 0);
  }

}
