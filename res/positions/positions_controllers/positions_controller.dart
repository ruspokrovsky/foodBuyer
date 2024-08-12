import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';

class PositionsListController extends StateNotifier<List<PositionModel>> {
  PositionsListController() : super([]);

  clearPositions() {
    state.clear();
  }

  updatePositionList(positionsData) {
    state = positionsData;
  }

  buildPositionList(
    positionsData,
  ) {
    var positionElements = positionsData.docs
        .map((DocumentSnapshot doc) => PositionModel.fromSnap(doc).toJson())
        .toList();

    for (var element in positionElements) {
      state.add(PositionModel(
        projectRootId: element['projectRootId'],
        docId: element['docId'],
        productName: element['productName'],
        productMeasure: element['productMeasure'],
        productFirsPrice: element['productFirsPrice'],
        productPrice: element['productPrice'],
        productQuantity: element['productQuantity'],
        marginality: element['marginality'],
        deliverSelectedTime: element['deliverSelectedTime'],
        available: element['available'],
        subCategoryName: element['subCategoryName'],
        subCategoryId: element['subCategoryId'],
        deliverId: element['deliverId'],
        deliverName: element['deliverName'],
        cartQty: element['cartQty'],
        amount: element['amount'] ?? 0,
        productImage: element['productImage'],
        united: element['united'],
        discountList: [],
        unitedList: element['unitedList'],
        ndsStatus: element['ndsStatus'],
        addedAt: element['addedAt'],
      ));
    }
  }

  buildMultiplePositionList(
    List<dynamic> positionsMultiData,
  ) {
    for (var value in positionsMultiData) {
      buildPositionList(
        value,
      );
    }
  }

  addPositionDiscountList(
    String positionId,
    List<DiscountModel> discountList,
  ) {
    for (var stateElem in state) {
      if (stateElem.docId == positionId) {
        stateElem.discountList = discountList;
      }
    }
  }

  num totalSum() {
    List<num> amountList = [];

    for (var stateElem in state) {
      num amount = (stateElem.productQuantity * stateElem.productFirsPrice);
      amountList.add(amount);
    }
    num total = amountList.reduce((value, element) => value + element);
    return total;
  }

  // //создаем список продуктов для SearchScreen
  createContent(WidgetRef ref, String projectRooId) {
    print('**createContent: $projectRooId');

    if (projectRooId.isNotEmpty) {
      state = state
          .where((element) => element.projectRootId == projectRooId)
          .toList();
    }
  }

  // //создаем список продуктов для SearchScreen
  List<PositionModel> positionList(String rootId) {
    return state.where((element) => element.projectRootId == rootId).toList();
  }

  void changePositionsListByProjectRootId(
      List<PositionModel> newList, String projectRootId) {
    state = newList
        .where((element) => element.projectRootId == projectRootId)
        .toList();
  }

  void changePositionsAllList(
    List<PositionModel> newList,
  ) {
    state = newList;
  }

  void onChangedPositionQty(int index, double qty) {
    state[index].cartQty = qty;
  }

  void isSelectedChange(positionId, isSelected) {
    for (var element in state) {
      if (element.docId == positionId) {
        element.isSelected = !isSelected;
      }
    }
  }

  void isSelectedFalseById(
    String positionId,
  ) {
    for (var element in state) {
      if (element.docId == positionId) {
        element.isSelected = false;
      }
    }
  }

  void isSelectedTrueById(
    String positionId,
  ) {
    for (var element in state) {
      if (element.docId == positionId) {
        element.isSelected = true;
      }
    }
  }

  void isSelectedAllChange() {
    for (var element in state) {
      if (element.isSelected == true) {
        element.isSelected = false;
      }
    }
  }

  textEditingController(index) {
    return TextEditingController(text: state[index].cartQty.toString());
  }
}
