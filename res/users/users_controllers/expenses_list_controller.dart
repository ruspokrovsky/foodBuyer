import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/expenses_model.dart';

class ExpensesListController extends StateNotifier<List<ExpensesModel>> {
  ExpensesListController(super.state);

  clearExpensesList() {
    state.clear();
  }

  addExpenses(ExpensesModel expensesModel) {
    state = List.from([...state, expensesModel].reversed);
  }

  removeExpenses(DiscountModel index) {
    state.remove(index);
  }


  buildExpensesList(discountData,) {

    var discountElems = discountData.docs.map((DocumentSnapshot doc)
    => DiscountModel.fromSnap(doc).toJson()).toList();

    for (var element in discountElems) {
      //state.add();
    }
  }

  createExpensesList(List<DiscountModel> dataList){
    //state = dataList;
  }





  clean() {
    state.clear();
  }


}
