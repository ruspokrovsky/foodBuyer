
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';


class OrderController extends StateNotifier<List<OrderModel>> {
  OrderController() : super([]);

  addPosition(OrderModel orderModel) {
    state = [...state, orderModel];
  }

  // createCurrentCart(List<OrderModel> currentCart) {
  //
  //   state = currentCart;
  // }

  void updateCurrentCart(List<OrderModel> currentCartList) {
    state = currentCartList;
  }

  updateQtyPosition({
    required int index,
    required String productId,
    required num qty,
    required List<DiscountModel>? discountList}) {
    state[index].productQuantity = qty;
    //state[index].amountSum = (state[index].productQuantity * state[index].productPrice);

    num amount1 = (state[index].productQuantity * state[index].productPrice);

    // Переменная для хранения последней примененной скидки
    num? lastAppliedDiscountPersent;

    // Если есть скидки
    if (discountList != null && discountList.isNotEmpty) {
      discountList.sort((a, b) => a.quantity.compareTo(b.quantity));
      for (var discount in discountList) {
        print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${discount.positionId}');
        if(state[index].productId == discount.positionId){

          if (state[index].productQuantity >= discount.quantity) {
            // Сохраняем последнюю примененную скидку
            lastAppliedDiscountPersent = discount.percent;
          }

        }

      }
    }
    // Если была применена хотя бы одна скидка, пересчитываем сумму с учетом последней скидки
    if (lastAppliedDiscountPersent != null) {
      double persentSum2 = (state[index].productPrice * lastAppliedDiscountPersent) / 100;
      // Присваеваем цену со скидкой для view
      state[index].discountPrice = (state[index].productPrice - persentSum2);
      state[index].discountPercent = lastAppliedDiscountPersent;
      double persentSum = (amount1 * lastAppliedDiscountPersent) / 100;
      amount1 -= persentSum;
    }else{
      state[index].discountPrice = state[index].productPrice;
      state[index].discountPercent = 0;

    }
    // Обновляем сумму после применения всех скидок (или без них)
    state[index].amountSum = amount1;


    // for (var stateElement in state) {
    //
    //   if(stateElement.productId == productId){
    //
    //     stateElement.productQuantity = qty;
    //     //state[index].amountSum = (state[index].productQuantity * state[index].productPrice);
    //
    //
    //     num amount1 = (stateElement.productQuantity * stateElement.productPrice);
    //
    //     // Переменная для хранения последней примененной скидки
    //     num? lastAppliedDiscountPersent;
    //
    //     // Если есть скидки
    //     if (discountList != null && discountList.isNotEmpty) {
    //       discountList.sort((a, b) => a.quantity.compareTo(b.quantity));
    //       for (var discount in discountList) {
    //         print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${discount.positionId}');
    //         if(stateElement.productId == discount.positionId){
    //
    //           if (stateElement.productQuantity >= discount.quantity) {
    //             // Сохраняем последнюю примененную скидку
    //             lastAppliedDiscountPersent = discount.percent;
    //           }
    //
    //         }
    //
    //       }
    //     }
    //     // Если была применена хотя бы одна скидка, пересчитываем сумму с учетом последней скидки
    //     if (lastAppliedDiscountPersent != null) {
    //       double persentSum2 = (stateElement.productPrice * lastAppliedDiscountPersent) / 100;
    //       // Присваеваем цену со скидкой для view
    //       stateElement.discountPrice = (stateElement.productPrice - persentSum2);
    //       stateElement.discountPercent = lastAppliedDiscountPersent;
    //       double persentSum = (amount1 * lastAppliedDiscountPersent) / 100;
    //       amount1 -= persentSum;
    //     }else{
    //       stateElement.discountPrice = stateElement.productPrice;
    //       stateElement.discountPercent = 0;
    //
    //     }
    //     // Обновляем сумму после применения всех скидок (или без них)
    //     stateElement.amountSum = amount1;
    //
    //   }
    //
    // }

  }


//когда у ползователя еще нет адреса доставки, но в корзине есть товар,
// при добовлении адреса доставки обновляем поля objectId,objectName в
  setObjectIdAndName(String objectId,String objectName) {
    state.map((e) => e.objectId = objectId).toList();
    state.map((e) => e.objectName = objectName).toList();
  }



  num totalSum(num cashback) {

    if(state.map((e) => e.amountSum).toList().isNotEmpty){

      num total = state.map((e) => e.amountSum).toList().reduce((v, e) => v + e);

      num percent = (total * cashback) / 100;

      num totalResult = (total - percent);

      return totalResult;
    }else{
      return 0.0;
    }

  }

  deletePosition(String productId) {
    state = state.where((e) => e.productId != productId).toList();
  }

  clean() {
    state.clear();
  }



}
