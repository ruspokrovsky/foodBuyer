import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class OrdersForPlaceController extends StateNotifier<List<OrderDetailsModel>>{
  OrdersForPlaceController(super.state);

  clearOrdersyList(){
    state.clear();
  }



  // buildOrdersForPlace(QuerySnapshot data,){
  //
  //   var orderData = data.docs.map((DocumentSnapshot docs)
  //   => OrderDetailsModel.fromSnap(docs).toJson()).toList();
  //
  //     for(var order in orderData){
  //       state.add(OrderDetailsModel(
  //         projectRootId: order['projectRootId'],
  //         docId: order['docId'],
  //         userId: order['userId'],
  //         objectId: order['objectId'],
  //         objectName: order['objectName'],
  //         requestDate: order['requestDate'],
  //         objectDiscount: order['objectDiscount'],
  //         invoice: order['invoice'],
  //         orderStatus: order['orderStatus'],
  //         deliverSelectedTime: order['deliverSelectedTime'],
  //         deliverId: order['deliverId'],
  //         deliverName: order['deliverName'],
  //         totalSum: order['totalSum'],
  //         positionListLength: order['positionListLength'],
  //         addedAt: order['addedAt'],
  //         orderPositionsList: order['orderModelList'],
  //         cashback: order['cashback'],
  //       ));
  //     }
  // }


  void buildOrdersForPlacesList(DocumentSnapshot order,) {

    state.add(OrderDetailsModel(
      projectRootId: order['projectRootId'],
      //docId: order['docId'],
      userId: order['userId'],
      objectId: order['objectId'],
      objectName: order['objectName'],
      requestDate: order['requestDate'],
      objectDiscount: order['objectDiscount'],
      invoice: order['invoice'],
      orderStatus: order['orderStatus'],
      deliverSelectedTime: order['deliverSelectedTime'],
      deliverId: order['deliverId'],
      deliverName: order['deliverName'],
      totalSum: order['totalSum'],
      positionListLength: order['positionListLength'],
      addedAt: order['addedAt'],
      //orderPositionsList: order['orderModelList'],
      cashback: order['cashback'],
      debtRepayment: order['debtRepayment']??0,
      //debtRepayment: 0,
    ));
  }


  void buildMultipleOrdersList(List<DocumentSnapshot> ordersMultiData) {


    for (DocumentSnapshot snap in ordersMultiData) {
      buildOrdersForPlacesList(snap,);
    }
  }


}