import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/employee_report_model.dart';

class EmployeeReportController extends StateNotifier<List<EmployeeReportModel>> {
  EmployeeReportController(super.state);

  clearEmployeeReportList() {
    state.clear();
  }

  buildEmployeeReportList(accountabilityData,) {
    var positionElements = accountabilityData.docs
        .map((DocumentSnapshot doc) => EmployeeReportModel.fromSnap(doc).toJson())
        .toList();

    for (var element in positionElements) {
      state.add(EmployeeReportModel(
          docId: element['docId'],
          userId: element['userId'],
          rootId: element['rootId'],
          purchasingTotal: element['purchasingTotal'],
          expensesTotal: element['expensesTotal'],
          description: element['description'],
          purchasingIdList: element['purchasingIdList'],
          addedAt: element['addedAt'],
          employeeReportStatus: element['employeeReportStatus'],
      ));
    }
  }


}
