import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/expenses_model.dart';

class EmployeeReportDetailsController extends StateNotifier<List<ExpensesModel>> {
  EmployeeReportDetailsController(super.state);

  clearEmployeeReportDetailsList() {
    state.clear();
  }

  buildEmployeeReportDetailsList(employeeReportDetailsData,) {
    var positionElements = employeeReportDetailsData.docs
        .map((DocumentSnapshot doc) => ExpensesModel.fromSnap(doc).toJson())
        .toList();

    for (var element in positionElements) {
      state.add(
        ExpensesModel(
            docId: element['docId'],
            userId: element['userId'],
            rootId: element['rootId'],
            expensesName: element['expensesName'],
            expensesPrice: element['expensesPrice'],
            description: element['description'],
            addedAt: element['addedAt'])
      );
    }
  }


}
