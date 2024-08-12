import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/cart/cart_services/real_time_services.dart';
import 'package:ya_bazaar/res/controllers/united_controller.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/models/united_model.dart';
import 'package:ya_bazaar/res/orders/orders_controller/order_details_controller.dart';
import 'package:ya_bazaar/res/orders/orders_controller/order_positions_controller.dart';
import 'package:ya_bazaar/res/orders/orders_controller/orders_for_place_controller.dart';
import 'package:ya_bazaar/res/orders/orders_controller/single_position_controller.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';


final ordersByObjectIdProvider = StreamProvider.family<QuerySnapshot, String>(
        (_,args) => OrderFBServices().getOrdersByObjectId(objectId: args),
    name: 'ordersByObjectIdProvider');

final ordersByObjectIdProvider2 = StreamProvider.family<QuerySnapshot, IntentCurrentUserIdObjectIdProjectRootId>(
        (_, arguments) => OrderFBServices().getOrdersByObjectId2(arguments: arguments,),
    name: 'ordersByObjectIdProvider2');

final ordersByObjectIdProvider3 = StreamProvider.family<QuerySnapshot, IntentCurrentUserIdObjectIdProjectRootId>(
        (_, arguments) => OrderFBServices().getOrdersByObjectId3(arguments: arguments,),
    name: 'ordersByObjectIdProvider3');

final ordersByRootIdProvider = StreamProvider.family<QuerySnapshot, IntentCurrentUserIdObjectIdProjectRootId>(
        (_, arguments) => OrderFBServices().getOrdersByRootId(arguments: arguments,),
    name: 'ordersByRootIdProvider');

// final ordersForPlaceProvider = StreamProvider.family<QuerySnapshot, IntentCurrentUserIdObjectIdProjectRootId>(
//         (_, arguments) => OrderFBServices().getOrdersByRootId(arguments: arguments,),
//     name: 'ordersForPlaceProvider');

final orderPositionsByOrderIdProvider = StreamProvider.family<QuerySnapshot, OrderDetailsModel>(
        (_,args) => OrderFBServices().getOrderPositionsByOrderId(args: args,),
    name: 'orderPositionsByOrderIdProvider');

final orderPositionsByOrderIdProvider2 = StreamProvider.family<QuerySnapshot, OrderDetailsModel>(
        (_,args) => OrderFBServices().getOrderPositionsByOrderId2(args: args,),
    name: 'orderPositionsByOrderIdProvider2');

final orderPositionsForRootProvider = StreamProvider.family<QuerySnapshot, OrderDetailsModel>(
        (_,args) => OrderFBServices().getOrderPositionsForRoot(args: args,),
    name: 'orderPositionsForRootProvider');

final ordersDetailListProvider =
StateNotifierProvider<OrderDetailsController, List<OrderDetailsModel>>(
        (_) => OrderDetailsController([]),
    name: 'ordersDetailListProvider');

final ordersListForPlaceProvider = StateNotifierProvider<OrdersForPlaceController, List<OrderDetailsModel>>(
        (_) => OrdersForPlaceController([]),
    name: 'ordersListForPlaceProvider');


final ordersPositionListProvider =
StateNotifierProvider<OrderPositionListController, List<OrderModel>>(
        (_) => OrderPositionListController([]),
    name: 'ordersPositionListProvider');


// final getPositionByIdProvider = StreamProvider.family<DocumentSnapshot,String>(
//         (_, positionId) => OrderFBServices().getPositionById(positionId: positionId),
//     name: 'getPositionByIdProvider');

final getPositionByIdProvider2 = StreamProvider.family<DocumentSnapshot,PurchasingModel>(
        (_, purchasingData) => OrderFBServices().getPositionById2(purchasingData: purchasingData),
    name: 'getPositionByIdProvider2');


final getPositionByIdProvider3 = StreamProvider.family<DocumentSnapshot,GetPositionArgs>(
        (_, arguments) => OrderFBServices().getPositionById(getPositionArgs: arguments),
    name: 'getPositionByIdProvider3');


final singlePositionController = StateNotifierProvider<SinglePositionController, PositionModel>(
        (_) => SinglePositionController(),
    name: 'singlePositionController');



final unitedByRootIdProvider = StreamProvider.family<DatabaseEvent, String>(
        (_, rootId) => RealTimeServices().getUnitedData(rootId: rootId),
    name: 'getUnitedByIdProvider');

final unitedListProvider = StateNotifierProvider<UnitedController, List<UnitedModel>>(
        (_) => UnitedController(),
    name: 'unitedListProvider');

final currentLimitDifferenceProvider = StateProvider<num>(
        (_) => 0,
    name: 'currentLimitDifferenceProvider');

final totalsDifferenceDebtProvider = StateProvider<List<num>>(
        (_) => [],
    name: 'totalsDifferenceDebtProvider');

//----------------------------------------------------------------------

// final ordersProvider = StateNotifierProvider<Orders,String>(
//         (_) => Orders(),
//     name: 'ordersProvider');
//
// class Orders extends StateNotifier<String>{
//   Orders({String? categoryId}) : super(categoryId ?? '');
//
//   void updateCategoryId(String categoryId) => state = categoryId;
//   void clean() => state = '';
// }
//----------------------------------------------------------------------