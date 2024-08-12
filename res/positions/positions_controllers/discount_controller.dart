
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';


class DiscountController extends StateNotifier<List<DiscountModel>> {
  DiscountController() : super([]);

  addDiscount(DiscountModel discountModel) {
    state = [...state, discountModel];
  }

  removeDiscount(DiscountModel index) {
    state.remove(index);
  }


  buildPositionDiscountList(discountData,) {

    var discountElems = discountData.docs.map((DocumentSnapshot doc)
    => DiscountModel.fromSnap(doc).toJson()).toList();

    for (var element in discountElems) {
      state.add(DiscountModel(
          docId: element['docId'],
          positionId: element['positionId'],
          quantity: element['quantity'],
          percent: element['percent']));
    }
  }

  createDiscountList(List<DiscountModel> dataList){
    state = dataList;
  }





  clean() {
    state.clear();
  }



}
