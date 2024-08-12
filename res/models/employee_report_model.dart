import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/expenses_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class EmployeeReportModel {
  String? docId;
  String userId;
  String rootId;
  num purchasingTotal;
  num expensesTotal;
  String description;
  List<dynamic> purchasingIdList;
  UserModel? userModel;
  List<ExpensesModel>? expensesList;
  int? employeeReportStatus;
  int addedAt;


  EmployeeReportModel({
      this.docId,
      required this.userId,
      required this.rootId,
      required this.purchasingTotal,
      required this.expensesTotal,
      required this.description,
      required this.purchasingIdList,
      this.userModel,
      this.expensesList,
      this.employeeReportStatus,
      required this.addedAt,
  });

  Map<String, dynamic> toJsonForDb() => {
    'userId': userId,
    'rootId': rootId,
    'purchasingTotal': purchasingTotal,
    'expensesTotal': expensesTotal,
    'purchasingIdList': purchasingIdList,
    'description': description,
    'employeeReportStatus': employeeReportStatus,
    'addedAt': addedAt,
  };
  Map<String, dynamic> toJson() => {
    'docId': docId,
    'userId': userId,
    'rootId': rootId,
    'purchasingTotal': purchasingTotal,
    'expensesTotal': expensesTotal,
    'purchasingIdList': purchasingIdList,
    'description': description,
    'employeeReportStatus': employeeReportStatus,
    'addedAt': addedAt,
  };

  static EmployeeReportModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;
    return EmployeeReportModel(
        docId: docId,
        userId: snapshot['userId'] ?? '',
        rootId: snapshot['rootId'] ?? '',
        purchasingTotal: snapshot['purchasingTotal'] ?? 0,
        expensesTotal: snapshot['expensesTotal'] ?? 0,
        purchasingIdList: snapshot['purchasingIdList'] ?? [],
        description: snapshot['description'] ?? '',
        employeeReportStatus: snapshot['employeeReportStatus'] ?? 0,
        addedAt: snapshot['addedAt'] ?? 0,
    );
  }

  static empty(){
    return EmployeeReportModel(
        docId: '',
        userId: '',
        rootId: '',
        addedAt: 0,
        purchasingTotal: 0,
        expensesTotal: 0,
        description: '',
        purchasingIdList: []);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EmployeeReportModel &&
              userId == other.userId;

  @override
  int get hashCode =>
      userId.hashCode ^ userId.hashCode;


}
