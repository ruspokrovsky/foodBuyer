import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/orders_doc_num_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class OrderPositionListController extends StateNotifier<List<OrderModel>>{
  OrderPositionListController(super.state);

  clearOrderPositionsList(){
    state.clear();
  }

  buildOrderPositionsList(QuerySnapshot snap,){

    var positionData = snap.docs.map((DocumentSnapshot docs)
    => OrderModel.fromSnap(docs).toJson()).toList();

      for(var position in positionData){
        state.add(OrderModel(
            projectRootId: position['projectRootId'],
            docId: position['docId'],
            productId: position['productId'],
            productName: position['productName'],
            productMeasure: position['productMeasure'],
            category: position['category'],
            productPrice: position['productPrice'],
            productQuantity: position['productQuantity'],
            amountSum: position['amountSum'],
            acceptedDate: position['acceptedDate'],
            returnQty: position['returnQty'],
            requestNote: position['requestNote'],
            successStatus: position['successStatus'],
            isSelected: position['isSelected'],
            discountPercent: position['discountPercent'],
            lastDiscountPercent: position['lastDiscountPercent'],
            rejectionReason: position['rejectionReason'],
            firstPrice: position['firstPrice'],
            productImage: position['productImage'],
        ),);
      }

  }

  buildOrderPositionsListForRoot(QuerySnapshot snap,){

    var positionData = snap.docs.map((DocumentSnapshot docs)
    => OrderModel.fromSnap(docs).toJson()).toList();

      for(var position in positionData){
        state.add(OrderModel(
            projectRootId: position['projectRootId'],
            docId: position['docId'],
            productId: position['productId'],
            productName: position['productName'],
            productMeasure: position['productMeasure'],
            category: position['category'],
            productPrice: position['productPrice'],
            productQuantity: position['productQuantity'],
            amountSum: position['amountSum'],
            acceptedDate: position['acceptedDate'],
            returnQty: position['returnQty'],
            requestNote: position['requestNote'],
            successStatus: position['successStatus'],
            isSelected: position['isSelected'],
            discountPercent: position['discountPercent'],
            lastDiscountPercent: position['lastDiscountPercent'],
            rejectionReason: position['rejectionReason'],
            firstPrice: position['firstPrice'],
        ),);
      }

  }

  void updateAmount({
    required String positionId,
    required num amount,
    num? discountPercent}) {

    for (var element in state) {
      if(element.docId == positionId){
        element.amountSum = amount;
        element.discountPercent = discountPercent ?? element.discountPercent;
      }
    }

  }

  void isSelectedChange(int index,) {
    state[index].isSelected = !state[index].isSelected!;
  }

  void addIndexForPdfDoc(int index,) {
    state[index].index = index+1;
  }


  void isSelectedChangeById(String positionId,) {

    for (var element in state) {

      if(element.docId == positionId){

        element.isSelected = false;
      }

    }
  }



}