import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/accountability_model.dart';

class AccountabilityListController extends StateNotifier<List<AccountabilityModel>> {
  AccountabilityListController(super.state);

  clearAccountabilityList() {
    state.clear();
  }

  buildAccountabilityList(accountabilityData,) {
    var positionElements = accountabilityData.docs
        .map((DocumentSnapshot doc) => AccountabilityModel.fromSnap(doc).toJson())
        .toList();

    for (var element in positionElements) {
      state.add(AccountabilityModel(
          docId: element['docId'],
          rootId: element['rootId'],
          userId: element['userId'],
          amountIssued: element['amountIssued'],
          amountSpent: element['amountSpent'],
          refundAmount: element['refundAmount'],
          accountabilityStatus: element['accountabilityStatus'],
          invoiceNum: element['invoiceNum'],
          addedAt: element['addedAt'],));
    }
  }
}
