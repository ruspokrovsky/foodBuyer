import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class ExpensesModel {
  String? docId;
  String userId;
  String rootId;
  String? expensesName;
  num? expensesPrice;
  String? description;
  UserModel? userModel;
  int addedAt;


  ExpensesModel({
      required this.docId,
      required this.userId,
      required this.rootId,
      this.expensesName,
      this.expensesPrice,
      this.description,
      this.userModel,
      required this.addedAt,
  });

  Map<String, dynamic> toJsonForDb() => {
    'userId': userId,
    'rootId': rootId,
    'expensesName': expensesName,
    'expensesPrice': expensesPrice,
    'description': description,
    'addedAt': addedAt,
  };
  Map<String, dynamic> toJson() => {
    'docId': docId,
    'userId': userId,
    'rootId': rootId,
    'expensesName': expensesName,
    'expensesPrice': expensesPrice,
    'description': description,
    'addedAt': addedAt,
  };

  static ExpensesModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;
    return ExpensesModel(
        docId: docId,
        userId: snapshot['userId'] ?? '',
        rootId: snapshot['rootId'] ?? '',
        expensesName: snapshot['expensesName'] ?? '',
        expensesPrice: snapshot['expensesPrice'] ?? 0,
        description: snapshot['description'] ?? '',
        addedAt: snapshot['addedAt'] ?? 0,
    );
  }

  static empty(){
    return ExpensesModel(docId: '', userId: '', rootId: '', addedAt: 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ExpensesModel &&
              userId == other.userId;

  @override
  int get hashCode =>
      userId.hashCode ^ userId.hashCode;


}
