import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/controllers/all_position_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/category_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/multiple_cart_list_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/order_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/sub_category_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/subscribers_controller.dart';
import 'package:ya_bazaar/res/home/home_services/home_services.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/subscribers_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/positions/positions_controllers/multiple_positions_controller.dart';
import 'package:ya_bazaar/res/positions/positions_controllers/only_owner_positions_controller.dart';
import 'package:ya_bazaar/res/positions/positions_controllers/positions_controller.dart';

final categoryProvider = StreamProvider<QuerySnapshot>(
    (_) => HomeFBServices().getCategory(),
    name: 'categoryProvider');

final categoryListProvider =
    StateNotifierProvider<CategoryController, List<CategoryModel>>(
        (_) => CategoryController([]),
        name: 'categoryListProvider');
//----------------------------------------------------------------------
final categoryIdProvider = StateNotifierProvider<CategoryId, String>(
    (_) => CategoryId(),
    name: 'categoryIdProvider');

class CategoryId extends StateNotifier<String> {
  CategoryId({String? categoryId}) : super(categoryId ?? '');

  void updateCategoryId(String categoryId) => state = categoryId;

  void clean() => state = '';
}

//----------------------------------------------------------------------
final categoryNameProvider = StateNotifierProvider<CategoryProduct, String>(
    (_) => CategoryProduct(),
    name: 'categoryProductProvider');

class CategoryProduct extends StateNotifier<String> {
  CategoryProduct({String? categoryProduct}) : super(categoryProduct ?? '');

  void updateCategoryProduct(String categoryProduct) => state = categoryProduct;

  void clean() => state = '';
}
//----------------------------------------------------------------------

final subCategoryProvider = StateNotifierProvider<SubCategory, SubCategoryModel>(
        (_) => SubCategory(),
    name: 'subCategoryProvider');

class SubCategory extends StateNotifier<SubCategoryModel> {
  SubCategory({SubCategoryModel? subCategoryModel}) : super(SubCategoryModel.empty());

  void updateSubCategory(SubCategoryModel subCategoryModel) => state = subCategoryModel;

  void clean() => state = SubCategoryModel.empty();
}
//----------------------------------------------------------------------

final isPositionedProvider = StateNotifierProvider<PositionedBool, bool>(
    (_) => PositionedBool(),
    name: 'isPositionedProvider');

class PositionedBool extends StateNotifier<bool> {
  PositionedBool({bool? positionedBool}) : super(positionedBool ?? false);

  void updateIsPositioned(bool positionedBool) => state = positionedBool;
}

//----------------------------------------------------------------------
final amountProvider = StateNotifierProvider<Amount, double>((_) => Amount(),
    name: 'amountProvider');

class Amount extends StateNotifier<double> {
  Amount({double? amount}) : super(amount ?? 0.0);

  void updateAmount(double amount) => state = amount;

  void clean() => state = 0.0;
}
//----------------------------------------------------------------------

final getSubCategoryByCategoryIdProvider =
    StreamProvider.family<QuerySnapshot, String>(
        (ref, param) => HomeFBServices().getSubCategory(param),
        name: 'getSubCategoryByCategoryIdProvider');

final subCategoryListProvider =
    StateNotifierProvider<SubCategoryListController, List<SubCategoryModel>>(
        (_) => SubCategoryListController(),
        name: "subCategoryListProvider");

final allPositionListProvider =
    StateNotifierProvider<AllPositionListController, List<AllPositionModel>>(
        (_) => AllPositionListController(),
        name: "allPositionListProvider");

final positionsListProvider = StateNotifierProvider<PositionsListController, List<PositionModel>>(
        (_) => PositionsListController(),
        name: "positionsListProvider");

final positionsStateListProvider = StateProvider<List<PositionModel>>(
        (_) => [],
    name: "positionsStateListProvider");

final notSubscribPositionsListProvider =
StateNotifierProvider<MultiplePositionsListController, List<PositionModel>>(
        (_) => MultiplePositionsListController(),
    name: "multiplePositionsListProvider");

final onlyOwnerPositionsListProvider =
StateNotifierProvider<OnlyOwnerPositionListController, List<PositionModel>>(
        (_) => OnlyOwnerPositionListController(),
    name: "onlyOwnerPositionsListProvider");

final quantityControllerProvider = StateProvider<TextEditingController>(
    (_) => TextEditingController(),
    name: "quantityControllerProvider");

final quantityProvider =
    StateProvider<double>((_) => 0.0, name: "quantityProvider");

final orderListProvider =
    StateNotifierProvider<OrderController, List<OrderModel>>(
        (_) => OrderController(),
        name: "orderListProvider");

final multipleCartListProvider =
    StateNotifierProvider<MultipleCartListController, List<MultipleCartModel>>(
        (_) => MultipleCartListController(),
        name: "multipleCartListProvider");

final heroTagProvider =
    StateProvider<String>((_) => '', name: "heroTagProvider");


//----------------------------------------------------------------------------------------------------

final fetchDataProvider = FutureProvider.family<Map<String, dynamic>,Locale>((ref, strArgs) async {
  final jsonString = await rootBundle.loadString('assets/translations/$strArgs.json');
  Map<String, dynamic> langData = jsonDecode(jsonString);

  return langData;
});

//----------------------------------------------------------------------------------------------------
final appLocaleProvider = StateNotifierProvider<AppLocale, Map<String, dynamic>>(
        (_) => AppLocale(),
    name: 'appLocaleProvider');

class AppLocale extends StateNotifier<Map<String, dynamic>> {
  AppLocale({Map<String, dynamic>? appLocale}) : super(appLocale ?? {});

  void buildLocale(WidgetRef ref, Locale locale) async {
    state = await ref.read(fetchDataProvider(locale).future);
  }
}

// Расширение для WidgetRef
extension LocalizationExtension on WidgetRef {
  String ln(String key) {
    return watch(appLocaleProvider)[key] ?? '';
  }
}

//----------------------------------------------------------------------------------------------------

final viewListProvider = StateProvider<List<PositionModel>>((ref) => []);

final viewPositionsListProvider = FutureProvider.family<List<PositionModel>, ViewPositionParamModel>(
        (_, args) => ViewPositionsListController().createNotSubscribeProduct(viewPositionParamModel: args),
    name: "viewPositionsListProvider");



class ViewPositionsListController{


  Future <List<PositionModel>> createNotSubscribeProduct({required viewPositionParamModel}) async{
    List<PositionModel> newState = [];

    final List<dynamic> notSubscribersIdList = viewPositionParamModel.notSubscribersIdList;
    final List<UserModel> notSubscribersList = viewPositionParamModel.notSubscribersList;
    final List<PositionModel> viewPositionList = viewPositionParamModel.viewPositionList;



    if(notSubscribersIdList.isNotEmpty){

      if (viewPositionList.isNotEmpty) {

        for (var stateElem in viewPositionList) {

          if (notSubscribersIdList.contains(stateElem.projectRootId)) {
            UserModel user = notSubscribersList.firstWhere((element)
            => element.uId == stateElem.projectRootId, orElse: () => UserModel.empty(),);
            stateElem.userModel = user;
            newState.add(stateElem);
          }
        }
        //newState.remove(value)
      }
      else {
        newState.clear();
      }
    }
    else {
      newState.clear();
    }

    return newState;
  }


}





//----------------------------------------------------------------------------------------------------

final subscribersSortProvider = StateNotifierProvider<SubscribersSortController, SubscribersSortModel>(
        (_) => SubscribersSortController(),
    name: "subscribersSortProvider");


final subscribersListProvider =
StateNotifierProvider<SubscribersController, List<SubscribersModel>>(
        (_) => SubscribersController(),
    name: "subscribersListProvider");