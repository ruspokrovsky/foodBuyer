import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AccountabilityModel {
  String? docId;
  String rootId;
  String userId;
  num amountIssued;//выданно
  num amountSpent;//освоено
  num refundAmount;//возврат
  num? balanceAmount;//остаток
  int accountabilityStatus;
  int invoiceNum;
  int addedAt;

  AccountabilityModel({
    this.docId,
    required this.rootId,
    required this.userId,
    required this.amountIssued,
    required this.amountSpent,
    required this.refundAmount,
    this.balanceAmount,
    required this.accountabilityStatus,
    required this.invoiceNum,
    required this.addedAt,
  });


  Map<String, dynamic> toJson() => {
        "docId": docId,
        "rootId": rootId,
        "userId": userId,
        "amountIssued": amountIssued,
        "amountSpent": amountSpent,
        "refundAmount": refundAmount,
        "accountabilityStatus": accountabilityStatus,
        "invoiceNum": invoiceNum,
        "addedAt": addedAt,
      };

  Map<String, dynamic> toJsonForDb() => {
    "rootId": rootId,
    "userId": userId,
    "amountIssued": amountIssued,
    "amountSpent": amountSpent,
    "refundAmount": refundAmount,
    "accountabilityStatus": accountabilityStatus,
    "invoiceNum": invoiceNum,
    "addedAt": addedAt,
  };

  static AccountabilityModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;
    return AccountabilityModel(
      docId: docId,
      rootId: snapshot['rootId'] ?? '',
      userId: snapshot['userId'] ?? '',
      amountIssued: snapshot['amountIssued'] ?? 0,
      amountSpent: snapshot['amountSpent'] ?? 0,
      refundAmount: snapshot['refundAmount'] ?? 0,
      accountabilityStatus: snapshot['accountabilityStatus'] ?? 0,
      invoiceNum: snapshot['invoiceNum'] ?? 0,
      addedAt: snapshot['addedAt'] ?? 0,
    );
  }

  static AccountabilityModel empty() {
    return AccountabilityModel(
      rootId: '',
      userId: '',
      amountIssued: 0,
      amountSpent: 0,
      refundAmount: 0,
      accountabilityStatus: 0,
      invoiceNum: 0,
      addedAt: 0,
    );
  }

}