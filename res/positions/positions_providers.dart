import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/positions/positions_controllers/discount_controller.dart';
import 'package:ya_bazaar/res/positions/positions_services/positions_services.dart';

final getSubscribersByIdProvider = StreamProvider.family<QuerySnapshot, String>(
        (ref, param) => PositionsFBServices().getSubscribers(param),
    name: 'getSubscribersByIdProvider');

final joinPositionsProvider = FutureProvider.family<List<dynamic>, List<dynamic>>(
    (_, args) => PositionsFBServices().fetchMultiplePositionForSearch(projectRootIdList: args),
    name: 'joinPositionsProvider');

final onlyOwnerPositionProvider = StreamProvider.family<QuerySnapshot, String>(
        (_, param) => PositionsFBServices().getOnlyOwnerPositions(ownerId: param),
    name: 'onlyOwnerPositionProvider');



final subscribersProvider = FutureProvider.family<List<dynamic>, List<dynamic>>(
        (_, args) => PositionsFBServices().fetchMultiplePosition(projectRootIdList: args),
    name: 'subscribersProvider');




final getPositionsByRootIdProvider = StreamProvider.family<QuerySnapshot, String>(
        (ref, param) => PositionsFBServices().getPositionsByProjectRootId(param),
    name: 'getPositionsByRootIdProvider');

final getPositionsDiscountProvider = StreamProvider.family<QuerySnapshot, DiscountModel>(
        (ref, param) => PositionsFBServices().fetchPositionsDiscount2(arguments: param),
    name: 'getPositionsDiscountProvider');


final discountListProvider =
StateNotifierProvider<DiscountController, List<DiscountModel>>(
        (_) => DiscountController(),
    name: "discountListProvider");

final currentTotalAndQtyPrivider = StateProvider<List<num>>(
        (ref) => [],
name: 'currentTotalAndQtyPrivider');
