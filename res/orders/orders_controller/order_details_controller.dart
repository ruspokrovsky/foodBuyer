import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class OrderDetailsController extends StateNotifier<List<OrderDetailsModel>>{
  OrderDetailsController(super.state);

  clearOrdersyList(){
    state.clear();
  }

  buildOrdersDocNumber(QuerySnapshot data,List<UserModel> subscribUsersList){

    var orderData = data.docs.map((DocumentSnapshot docs)
    => OrderDetailsModel.fromSnap(docs).toJson()).toList();

      for(var order in orderData){
        state.add(OrderDetailsModel(
          projectRootId: order['projectRootId'],
          docId: order['docId'],
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
          orderPositionsList: order['orderModelList'],
          cashback: order['cashback'],
          debtRepayment: order['debtRepayment']??0,
          userModel: UserModel.empty(),
        ));

      }

    ordersReapWithUser(subscribUsersList);
  }

  ordersReapWithUser(List<UserModel> subscribUsersList){
    List<dynamic> subscribUsersIdList = subscribUsersList.map((e) => e.uId).toList();
    for (var stateElem in state) {
      if(subscribUsersIdList.contains(stateElem.projectRootId)){
        for (UserModel user in subscribUsersList) {
          if(stateElem.projectRootId == user.uId){
            stateElem.userModel = user;
          }
        }
      }
      else {

        UserModel userModel = UserModel.empty();
        userModel.uId = stateElem.projectRootId;
        userModel.name = 'Удален из поставщиков';
        stateElem.userModel = userModel;
      }
    }
  }

  buildOrdersForRoot(QuerySnapshot data,){

    var orderData = data.docs.map((DocumentSnapshot docs)
    => OrderDetailsModel.fromSnap(docs).toJson()).toList();

      for(var order in orderData){
        state.add(OrderDetailsModel(
          projectRootId: order['projectRootId'],
          docId: order['docId'],
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
          orderPositionsList: order['orderModelList'],
          cashback: order['cashback'],
          debtRepayment: order['debtRepayment']??0,
        ));

      }

  }

  num invoiceNumber(){
    return state.map((e) => e.invoice).toList().reduce(max);
  }

  num allTotal(){

    List<num> totals = state.map((e) => e.totalSum).toList();

    return totals.reduce((value, element) => value + element);
  }



}