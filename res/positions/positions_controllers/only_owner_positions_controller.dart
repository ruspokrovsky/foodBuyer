import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class OnlyOwnerPositionListController extends StateNotifier<List<PositionModel>> {
  OnlyOwnerPositionListController() : super([]);

  clearPositions() {
    state.clear();
  }

  updatePositionList(positionsData){
    state = positionsData;
}

  buildOnlyOwnerPositionList2(QuerySnapshot positionsData,List<UserModel> notSubscribersList,) {



    //здесь мы вставляем userModel в positionModel для отображения на главной странице в viewPosition

    var positionElements = positionsData.docs.map((DocumentSnapshot doc) => PositionModel.fromSnap(doc).toJson()).toList();

    for (var positionElem in positionElements) {

      for (var userElem in notSubscribersList) {

        if(userElem.uId == positionElem['projectRootId']){
          state.add(
              PositionModel(
                projectRootId: positionElem['projectRootId'],
                docId: positionElem['docId'],
                productName: positionElem['productName'],
                productMeasure: positionElem['productMeasure'],
                productFirsPrice: positionElem['productFirsPrice'],
                productPrice: positionElem['productPrice'],
                productQuantity: positionElem['productQuantity'],
                marginality: positionElem['marginality'],
                deliverSelectedTime: positionElem['deliverSelectedTime'],
                available: positionElem['available'],
                subCategoryName: positionElem['subCategoryName'],
                subCategoryId: positionElem['subCategoryId'],
                deliverId: positionElem['deliverId'],
                deliverName: positionElem['deliverName'],
                cartQty: positionElem['cartQty'],
                amount: positionElem['amount']??0,
                united: positionElem['united'],
                productImage: positionElem['productImage'],
                userModel: userElem,
                addedAt: positionElem['addedAt']??0,
              )
          );

        }

      }
    }
  }

  Future<void> buildOnlyOwnerPositionList(List<dynamic> positionsMultiData, List<UserModel> notSubscribersList,) async{
    for (var value in positionsMultiData) {
      buildOnlyOwnerPositionList2(value,notSubscribersList);
    }
  }

  void createNotSubscribeProduct(WidgetRef ref,) async{
    List<PositionModel> newState = [];
    List<dynamic> notSubscribersIdList = ref.watch(subscribersSortProvider).notSubscribersIdList;
    List<UserModel> notSubscribUsersList = ref.watch(subscribersSortProvider).notSubscribersList;



    if (notSubscribersIdList.isNotEmpty) {
      for (var stateElem in state) {
        if (notSubscribersIdList.contains(stateElem.projectRootId)) {
          var user = notSubscribUsersList.firstWhere((element) => element.uId == stateElem.projectRootId,
            orElse: () => UserModel.empty(),
          );
          stateElem.userModel = user;
          newState.add(stateElem);
        }

      }

      state = newState;
    }

    // if(notSubscribersIdList.isNotEmpty){
    //   for (String subscribersId in notSubscribersIdList) {
    //     removePositionByRootId(subscribersId);
    //   }
    // }


  }

  void buildLocalPositionList(String projectRootId) {

    state = state.where((element) => element.projectRootId == projectRootId).toList();

  }

  void remobePosition(String rootId,) {

    state = state.where((element) => element.projectRootId != rootId).toList();

  }

  void onChangedPositionQty(int index, double qty) {

    state[index].cartQty = qty;

  }

  void isSelectedChange(positionId,isSelected) {

    print('isSelectedChange-------- $positionId');

    for (var element in state) {
      if(element.docId == positionId){
        element.isSelected = !isSelected;
      }
    }

  }

  void removePositionByRootId(String rootId) {
    print('-removePositionByRootId-------$rootId');
    state.removeWhere((element) => element.projectRootId == rootId);
  }

  void isSelectedFalseById(String positionId,) {

    for (var element in state) {

      if(element.docId == positionId){

        element.isSelected = false;
      }

    }
  }

  void isSelectedTrueById(String positionId,) {

    for (var element in state) {

      if(element.docId == positionId){

        element.isSelected = true;
      }

    }
  }

  void isSelectedAllChange() {

    for (var element in state) {

      if(element.isSelected == true){

        element.isSelected = false;
      }

    }
  }








  textEditingController(index){

    return TextEditingController(text: state[index].cartQty.toString());
  }

}