import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';

class MultipleCartListController
    extends StateNotifier<List<MultipleCartModel>> {
  MultipleCartListController() : super([]);

  addCart(MultipleCartModel cart) {
    state = [...state, cart];
  }

  addCartPosition(String projectRootId, OrderModel cartPosition) {
    if (state.isNotEmpty) {
      List<String> projectRootIdList = state.map((e) => e.projectRootId).toList();

      if (projectRootIdList.contains(projectRootId)) {
        for (var element in state) {
          if (element.projectRootId == projectRootId) {
            element.currentCartList.add(cartPosition);
          }
        }
      } else {
        state = [
          ...state,
          MultipleCartModel(
              projectRootId: projectRootId,
              currentCartList: [cartPosition],
              customerId: '',
              projectRootName: '',
              customerName: '')
        ];
      }
    } else {
      state = [
        ...state,
        MultipleCartModel(
            projectRootId: projectRootId, currentCartList: [cartPosition], customerId: '', projectRootName: '', customerName: '')
      ];
    }
  }

  Future<void> createCart(WidgetRef ref, String projectRootId,) async {
    if (state.isNotEmpty) {
      List<String> projectRootIdList = state.map((e) => e.projectRootId).toList();
      if (projectRootIdList.contains(projectRootId)) {
        for (var element in state) {
          if (element.projectRootId == projectRootId) {
            ref.read(orderListProvider.notifier).updateCurrentCart(element.currentCartList);
          }
        }
      } else {ref.read(orderListProvider.notifier).clean();}
    } else {ref.read(orderListProvider.notifier).clean();}

  }



  Future<void> buildSelectedPosition(WidgetRef ref, String projectRootId,) async {

    print('------------buildSelectedPosition--------------------');

    if (state.isNotEmpty) {
      List<String> projectRootIdList = state.map((e) => e.projectRootId).toList();
      if (projectRootIdList.contains(projectRootId)) {
        for (var stateElem in state) {
          if (stateElem.projectRootId == projectRootId) {
            if(stateElem.currentCartList.isNotEmpty){
              ref.read(positionsListProvider.notifier).isSelectedAllChange();
              for (var element in stateElem.currentCartList) {
                ref.read(positionsListProvider.notifier).isSelectedTrueById(element.productId);
              }
            }
            else {
              ref.read(positionsListProvider.notifier).isSelectedAllChange();
            }
          }
        }
      }
    }

  }

  Future <void> setCustomer(MultipleCartModel custoverData) async {
  //Future <void> setCustomer(String rootId, String customerId,String customerName) async {

    for (var stateElem in state) {
      if(stateElem.projectRootId == custoverData.projectRootId){
        stateElem.customerId = custoverData.customerId;
        stateElem.customerName = custoverData.customerName;
      }
    }
  }


  Future<void> buildSelectedMultiPosition(WidgetRef ref) async {

    for (var stateElem in state) {

      for (var element in stateElem.currentCartList) {
        ref.read(positionsListProvider.notifier).isSelectedTrueById(element.productId);
      }

    }
  }



  num buildTotalChip(WidgetRef ref, String projectRootId,String positionId){
    num positionAmount = 0;

    for (var stateElem in state) {
      if (stateElem.projectRootId == projectRootId) {
        if(stateElem.currentCartList.isNotEmpty){
          for (var cartListElem in stateElem.currentCartList) {
            if(cartListElem.productId == positionId){
              positionAmount = cartListElem.amountSum;
            }
          }
        }
      }
    }
    return positionAmount;
  }

  List<String> projectRootIdList(){
    return state.map((e) => e.projectRootId).toList();
  }

  Future<void> removeCartList({
    required WidgetRef ref,
    required String projectRootId,
  }) async {
    state = state.where((element) => element.projectRootId != projectRootId).toList();
    ref.read(orderListProvider.notifier).clean();
    ref.read(positionsListProvider.notifier).isSelectedAllChange();
  }

  updateCart(String projectRootId, List<OrderModel> currentCart) {
    for (var element in state) {
      if (element.projectRootId == projectRootId) {
        element.currentCartList = currentCart;
      }
    }
  }

  Future<List<OrderModel>> removeCartListPosition({
    required WidgetRef ref,
    required String projectRootId,
    required String productId,
    required List<OrderModel> currentCart,}) async {

    for (var stateElem in state) {
      if (stateElem.projectRootId == projectRootId) {

        List<OrderModel> currentCartList = currentCart.where((element) => element.productId != productId).toList();

        stateElem.currentCartList = currentCartList;
        ref.read(orderListProvider.notifier).deletePosition(productId);

        if(currentCartList.isEmpty){
          removeCartList(ref: ref, projectRootId: projectRootId);
        }
        ref.read(positionsListProvider.notifier).isSelectedAllChange();
      }
    }
    return ref.watch(orderListProvider);
  }



  isPlace(String rootId) {
    bool isPlace = false;
    for (var stateElem in state) {
      if (stateElem.projectRootId == rootId) {
        if(stateElem.customerId.isNotEmpty){
          isPlace = true;
        }
      }
    }
    return isPlace;
  }

  currentCartData(String rootId){

    MultipleCartModel multipleCartModel = MultipleCartModel.empty();

    for (var stateElem in state) {
      if (stateElem.projectRootId == rootId) {

        multipleCartModel = MultipleCartModel(
            projectRootId: stateElem.projectRootId,
            projectRootName: stateElem.projectRootName,
            currentCartList: stateElem.currentCartList,
            customerId: stateElem.customerId,
            customerName: stateElem.customerName,);
      }
    }
    return multipleCartModel;
  }



  clean() {
    state.clear();
  }
}
