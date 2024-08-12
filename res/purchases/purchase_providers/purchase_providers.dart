import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/purchases/purchase_controllers/purchases_controller.dart';
import 'package:ya_bazaar/res/purchases/purchase_services/purchase_services.dart';

final getAllPurchasesProvider = StreamProvider((_) => PurchaseFBServices().getAllPurchases(),
    name: 'getAllPurchasesProvider');

final getAllPurchasesProvider2 = StreamProvider.family<QuerySnapshot, String>(
        (_, rootId) => PurchaseFBServices().getAllPurchases2(rootId),
    name: 'getAllPurchasesProvider');

final getPurchasesByStatusProvider = StreamProvider.family<QuerySnapshot, String>(
        (_, rootId) => PurchaseFBServices().getPurchasesByStatus(rootId: rootId),
    name: 'getPurchasesByStatusProvider');

final allPurchasesListProvider = StateNotifierProvider<PurchasesController,List<PurchasingModel>>(
        (_) => PurchasesController([]),
    name: "allPurchasesListProvider");


final getPositionByIdProvider = StreamProvider.family<DocumentSnapshot, String>(
        (ref, args) => PurchaseFBServices().getPositionQtyById(args),
    name: 'getPositionByIdProvider');

final navigationAwaitProvider = StateProvider<String>(
        (ref,) => '',
    name: 'navigationAwaitProvider');