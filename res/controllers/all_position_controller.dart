import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';

class AllPositionListController extends StateNotifier<List<AllPositionModel>> {
  AllPositionListController() : super([]);

  clearAllPosition() {
    state.clear();
  }

updateAllPositionList(allPositionData){
    state = allPositionData;
}

  buildAllPositionList(allPositionData,) {
    var allPositionElements = allPositionData.docs.map((DocumentSnapshot doc) => AllPositionModel.fromSnap(doc).toJson()).toList();

    for (var element in allPositionElements) {
      state.add(
          AllPositionModel(
              docId: element['docId'],
              productName: element['productName'],
              productMeasure: element['productMeasure'],
              productFirsPrice: element['productFirsPrice'],
              productPrice: element['productPrice'],
              productQuantity: element['productQuantity'],
              marginality: element['marginality'],
              deliverSelectedTime: element['deliverSelectedTime'],
              available: element['available'],
              categoryProduct: element['categoryProduct'],
              deliverId: element['deliverId'],
              deliverName: element['deliverName'],
              cartQty: 0,
              amount: 0,
              isSelected: false,
              united: element['united'],
              productImage: element['productImage'],
          )
      );
    }
  }


  void positionCountPlus(int index) {

    state[index].cartQty ++;

  }

  void positionCountMinus(int index) {

    state[index].cartQty --;

  }

  void onChangedPositionQty(int index, double qty) {

    state[index].cartQty = qty;

  }

  void isSelectedChange(docId,isSelected) {

    for (var element in state) {
      if(element.docId == docId){
        element.isSelected = !isSelected;
      }
    }



    //state[index].isSelected = !state[index].isSelected!;

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