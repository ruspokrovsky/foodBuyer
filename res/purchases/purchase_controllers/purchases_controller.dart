import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';

class PurchasesController extends StateNotifier<List<PurchasingModel>>{
  PurchasesController(super.state);

  clearPurchasingList(){
    state.clear();
  }

  buildPurchasing(purchasingData){

    var purchasingList = purchasingData.docs.map((DocumentSnapshot docs)
    => PurchasingModel.fromSnap(docs).toJson()).toList();

    for(var element in purchasingList){
      state.add(PurchasingModel(
          docId: element['docId'],
          projectRootId: element['projectRootId'],
          buyerId: element['buyerId'],
          buyerName: element['buyerName'],
          selectedTime: element['selectedTime'],
          firsPrice: element['firsPrice'],
          actualPrice: element['actualPrice'],
          actualQty: element['actualQty'],
          productName: element['productName'],
          productId: element['productId'],
          productMeasure: element['productMeasure'],
          orderQty: element['orderQty'],
          purchasingStatus: element['purchasingStatus'],
          positionImgUrl: element['positionImgUrl'],
          receivedQuantity: element['receivedQuantity'],
          receivedDate: element['receivedDate'],
      ));

    }

  }





}