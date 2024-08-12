import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';

class OrderFBServices {
  //final firebaseStorage = FirebaseStorage.instans;
  final fireStore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getOrdersByObjectId({
    required String objectId,
  }) {
    return fireStore
        .collection("ordersN")
        .doc(objectId)
        .collection('orders')
        .orderBy('addedAt', descending: true) //descending: true (по убыванию)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersByObjectId2({
    required IntentCurrentUserIdObjectIdProjectRootId arguments,
  }) {
    String placeId = arguments.placeId;
    String projectRootId = arguments.projectRootId;

    return fireStore
        .collection("aOrders")
        .doc(placeId)
        .collection('orders')
        .where('projectRootId', isEqualTo: projectRootId)
        .orderBy('addedAt', descending: true) //descending: true (по убыванию)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersByObjectId3({
    required IntentCurrentUserIdObjectIdProjectRootId arguments,
  }) {
    String currentUserId = arguments.currentUserid!;
    String placeId = arguments.placeId;
    String projectRootId = arguments.projectRootId;

    print('-----------------');
    print(currentUserId);
    print(placeId);

    return fireStore
        .collection("aProjectData")
        .doc(currentUserId)
        .collection('places')
        .doc(placeId)
        .collection('orders')
        .orderBy('addedAt', descending: true) //descending: true (по убыванию)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersByRootId({
    required IntentCurrentUserIdObjectIdProjectRootId arguments,
  }) {
    String currentUserId = arguments.currentUserid!;
    String placeId = arguments.placeId;
    String projectRootId = arguments.projectRootId;

    return fireStore
        .collection("aProjectData")
        .doc(currentUserId)
        .collection('places')
        .doc(placeId)
        .collection('orders')
        .where('projectRootId', isEqualTo: projectRootId)
        .orderBy('addedAt', descending: true) //descending: true (по убыванию)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersForRoot({
    required IntentCurrentUserIdObjectIdProjectRootId arguments,
  }) {
    String currentUserId = arguments.currentUserid!;
    String placeId = arguments.placeId;
    String rootId = arguments.projectRootId;

    print('-----------------');
    print('currentUserId: $currentUserId');
    print('placeId: $placeId');
    print('rootId: $rootId');

    return fireStore
        .collection("aProjectData")
        .doc(currentUserId)
        .collection('places')
        .doc(placeId)
        .collection('orders')
        .where('projectRootId', isEqualTo: rootId)
        .orderBy('addedAt', descending: true) //descending: true (по убыванию)
        .snapshots();
  }

//готовим запрос к заказам от снабжения
  Stream<QuerySnapshot> getOrdersByObjectId435({
    required IntentCurrentUserIdObjectIdProjectRootId arguments,
  }) {
    String currentUserId = arguments.currentUserid!;
    String placeId = arguments.placeId;
    String projectRootId = arguments.projectRootId;

    print('-----------------');
    print(currentUserId);
    print(placeId);

    return fireStore
        .collection("aProjectData")
        .doc(currentUserId)
        .collection('places')
        .doc(placeId)
        .collection('orders')
        .where('projectRootId', isEqualTo: projectRootId)
        .orderBy('addedAt', descending: true) //descending: true (по убыванию)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrderPositionsByOrderId({
    required OrderDetailsModel args,
  }) {
    String objectId = args.objectId;
    String docId = args.docId!;

    return fireStore
        .collection("aOrders")
        .doc(objectId)
        .collection('orders')
        .doc(docId)
        .collection('orderList')
        .snapshots();
  }

  Future<List<OrderDetailsModel>> fetchAllOrders(
      {required String userId,
        required List<String> placeIdList,
        required String projectRootId,

      }) async {
    List<OrderDetailsModel> customerAllOrderList = [];

    for (var placeId in placeIdList) {
      QuerySnapshot collectionList = await fireStore
          .collection("aProjectData")
          .doc(userId)
          .collection('places')
          .doc(placeId)
          .collection('orders')
          .where('projectRootId', isEqualTo: projectRootId)
          .get();
      for (QueryDocumentSnapshot collection in collectionList.docs) {
        OrderDetailsModel orderDetailsModel = OrderDetailsModel.fromSnap(collection);
        customerAllOrderList.add(orderDetailsModel);
      }
    }

    return customerAllOrderList;
  }

  Stream<QuerySnapshot> getOrderPositionsByOrderId2({
    required OrderDetailsModel args,
  }) {
    String objectId = args.objectId;
    String docId = args.docId!;
    String userId = args.userId;

    return fireStore
        .collection("aProjectData")
        .doc(userId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(docId)
        .collection('orderList')
        .snapshots();
  }

  Stream<QuerySnapshot> getOrderPositionsForRoot({
    required OrderDetailsModel args,
  }) {
    String objectId = args.objectId;
    String docId = args.docId!;
    String consumerId = args.userId;
    String rootId = args.projectRootId;

    print('-----------getOrderPositionsForRoot---------');
    print('rootId: $rootId');
    print('docId: $docId');
    print('objectId: $objectId');

    return fireStore
        .collection('aProjectData')
        .doc(consumerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(docId)
        .collection('orderList')
        //.where('projectRootId',isEqualTo: rootId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getPositionById({
    required GetPositionArgs getPositionArgs,
  }) {
    print('**OrderFBServices/getPositionById/rootId:${getPositionArgs.rootId}');
    print(
        '**OrderFBServices/getPositionById/rootId:${getPositionArgs.positionId}');

    return fireStore
        .collection('aProjectData')
        .doc(getPositionArgs.rootId)
        .collection('warehouse')
        .doc(getPositionArgs.positionId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getPositionById2(
      {required PurchasingModel purchasingData}) {
    print(purchasingData.projectRootId);
    print(purchasingData.productId);

    return fireStore
        .collection("aProjectData")
        .doc(purchasingData.projectRootId)
        .collection('warehouse')
        .doc(purchasingData.productId)
        .snapshots();
  }

  void positionStatusUpdate(
      {required String objectId,
      required String orderId,
      required String positionId}) async {
    print('objectId------$objectId');
    print('orderId-------$orderId');
    print('positionId-------$positionId');
    try {
      fireStore
          .collection('ordersN')
          .doc(objectId)
          .collection('orders')
          .doc(orderId)
          .collection('orderList')
          .doc(positionId)
          .update({'successStatus': 5});
    } catch (e) {
      print('e----------$e');
    }
  }

  void positionAcceptUpdate(
      {required String objectId,
      required String orderId,
      required String positionId}) async {
    print('objectId------$objectId');
    print('orderId-------$orderId');
    print('positionId-------$positionId');
    try {
      fireStore
          .collection('ordersN')
          .doc(objectId)
          .collection('orders')
          .doc(orderId)
          .collection('orderList')
          .doc(positionId)
          .update({
        'acceptedDate': 5,
        'amountSum': 5,
        'productQuantity': 5,
        'successStatus': 5,
      });
    } catch (e) {
      print('e----------$e');
    }
  }

  Future<void> updateShipmentOrders({
    required String objectId,
    required String rootId,
    required String customerId,
    required String orderId,
    required String positionId,
    required String productId,
    required num amountSum,
    required num firsPrice,
    required num actualPrice,
    required num productQuantity,
    required List<OrderModel> currentOrderList,
    required int successStatus,
    required num actualDiscountPercent,
  }) async {
    final DocumentReference orderDetailsRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId);

    final DocumentReference positionRef =
        orderDetailsRef.collection('orderList').doc(positionId);

    final DocumentReference productDocRef = fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('warehouse')
        .doc(productId);

    num totalSum =
        currentOrderList.map((e) => e.amountSum).reduce((v, e) => v + e);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(positionRef, {
          'firstPrice': firsPrice,
          'productPrice': actualPrice,
          'amountSum': amountSum,
          'productQuantity': productQuantity,
          'discountPercent': actualDiscountPercent,
          'successStatus': successStatus,
        });

        transaction.update(orderDetailsRef, {
          'totalSum': totalSum,
        });

        final DocumentSnapshot docSnapshot = await productDocRef.get();

        if (docSnapshot.exists) {
          Map<String, dynamic>? data =
              docSnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            final num currentQty = data['productQuantity'];
            num newProductQuantity = (currentQty - productQuantity);

            transaction.update(productDocRef, {
              'productQuantity': newProductQuantity,
            });
          }
        }
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> acceptanceOrdersPosition({
    required String customerId,
    required String rootId,
    required String objectId,
    required String orderId,
    required String positionId,
    required String productId,
    required double amountSum,
    required double productQuantity,
    required double factOrderedQty,
    required List<OrderModel> currentOrderList,
    required int successStatus,
  }) async {
    num returnQty = 0;

    print('**OrderFBServices/acceptanceOrdersPosition/');
    print('customerId: $customerId');
    print('rootId: $rootId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('positionId: $positionId');
    print('productId: $productId');
    print('amountSum: $amountSum');
    print('successStatus: $successStatus');
    print('successStatus: $successStatus');
    print('---------------------------------------');

    final DocumentReference orderDetailsRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId);

    final DocumentReference positionRef =
        orderDetailsRef.collection('orderList').doc(positionId);

    final DocumentReference productDocRef = fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('warehouse')
        .doc(productId);

    double totalSum = currentOrderList
        .map((e) => e.amountSum)
        .reduce((v, e) => v + e)
        .toDouble();

    if (factOrderedQty > productQuantity) {
      returnQty = (factOrderedQty - productQuantity);
    }

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(positionRef, {
          'amountSum': amountSum,
          'productQuantity': productQuantity,
          'returnQty': returnQty,
          'successStatus': successStatus,
        });

        transaction.update(orderDetailsRef, {
          'totalSum': totalSum,
        });
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<String> acceptanceOrdersAllPosition({
    required String userId,
    required String placeId,
    required String orderId,
    required int successStatus,
    required List<OrderModel> currentOrderList,
  }) async {
    final CollectionReference collRef = fireStore
        .collection("aProjectData")
        .doc(userId)
        .collection("places")
        .doc(placeId)
        .collection("orders")
        .doc(orderId)
        .collection('orderList');

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        for (var element in currentOrderList) {
          final DocumentReference docRef = collRef.doc(element.docId);
          transaction.update(docRef, {
            'successStatus': successStatus,
          });
        }
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-addOrder------------$e');
    }

    return 'acceptanceSuccess';
  }

  Future<void> updateOrdersPositionStatus({
    required String customerId,
    required String objectId,
    required String orderId,
    required String positionId,
    required int successStatus,
    required String rejectionReason,
  }) async {
    print('**OrderFBServices/updateOrdersPositionStatus/');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('positionId: $positionId');
    print('successStatus: $successStatus');
    print('---------------------------------------');

    final DocumentReference docRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId)
        .collection('orderList')
        .doc(positionId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, {
          'successStatus': successStatus,
          'rejectionReason': rejectionReason,
        });
      });
    } on FirebaseException catch (e) {
      print('~~~~> FirebaseException <~~~~: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> addLastDiscountPercent({
    required String customerId,
    required String objectId,
    required String orderId,
    required String positionId,
    required num amountSum,
    required num lastDiscountPercent,
  }) async {
    print('**OrderFBServices/updateOrdersPositionStatus/');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('positionId: $positionId');
    print('amountSum: $amountSum');
    print('lastDiscountPercent: $lastDiscountPercent');
    print('---------------------------------------');

    final DocumentReference docRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId)
        .collection('orderList')
        .doc(positionId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, {
          'lastDiscountPercent': lastDiscountPercent,
          //'amountSum': amountSum,
        });
      });
    } on FirebaseException catch (e) {
      print('~~~~> FirebaseException <~~~~: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> updateOrderStatus({
    required int orderStatus,
    required String customerId,
    required String objectId,
    required String orderId,
    required num totalSum,
    required num placeStatus,
  }) async {
    print('**OrderFBServices/updateOrderStatus/');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('---------------------------------------');

    final DocumentReference placeRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId);

    final DocumentReference orderDetailsRef =
        placeRef.collection('orders').doc(orderId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(orderDetailsRef, {
          'orderStatus': orderStatus,
          'totalSum': totalSum,
          'requestDate': DateTime.now().millisecondsSinceEpoch,
        });

        transaction.update(placeRef, {'successStatus': 2});
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }



  Future<void> updateOrderStatus2({
    required int orderStatus,
    required String customerId,
    required String objectId,
    required String orderId,
  }) async {
    print('**OrderFBServices/updateOrderStatus/');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('---------------------------------------');

    final DocumentReference orderDetailsRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(orderDetailsRef, {
          'orderStatus': orderStatus,
        });
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> updateOrderTotalSum({
    required String customerId,
    required String objectId,
    required String orderId,
    required num totalSum,
  }) async {
    print('**OrderFBServices/updateOrderStatus/');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('totalSum: $totalSum');
    print('---------------------------------------');

    //rootId: lvpZHkol5ETBMunLDsa2OmRMMZj2
    //docId: IvHAOQpL3V2YpETX9H6l
    //objectId: GcD4Ry12ZoWMvUiMOUfh

    final DocumentReference orderDetailsRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(orderDetailsRef, {
          'totalSum': totalSum,
        });
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> debtRepayment({
    required String customerId,
    required String objectId,
    required String orderId,
    required num debtRepaymentSum,
    num? orderStatus,
  }) async {
    print('**OrderFBServices/updateOrderStatus/');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('debtRepaymentSum: $debtRepaymentSum');
    print('---------------------------------------');

    //rootId: lvpZHkol5ETBMunLDsa2OmRMMZj2
    //docId: IvHAOQpL3V2YpETX9H6l
    //objectId: GcD4Ry12ZoWMvUiMOUfh

    final DocumentReference orderDetailsRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(orderDetailsRef, {
          'debtRepayment': debtRepaymentSum,
        });
      });

      if(orderStatus != null){
        await fireStore.runTransaction((Transaction transaction) async {
          transaction.update(orderDetailsRef, {
            'orderStatus': orderStatus,
          });
        });
      }

    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> updateOrderStatus3({
    required int orderStatus,
    required String customerId,
    required String objectId,
    required String orderId,
  }) async {
    print('**OrderFBServices/updateOrderStatus/');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('---------------------------------------');

    final DocumentReference orderDetailsRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(orderDetailsRef, {
          'orderStatus': orderStatus,
        });
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> addOrderDeliver({
    required int orderStatus,
    required String deliverId,
    required String deliverName,
    required String customerId,
    required String objectId,
    required String orderId,
  }) async {
    print('**OrderFBServices/updateOrderStatus/');
    print('deliverId: $deliverId');
    print('deliverName: $deliverName');
    print('customerId: $customerId');
    print('objectId: $objectId');
    print('orderId: $orderId');
    print('---------------------------------------');

    final DocumentReference orderDetailsRef = fireStore
        .collection("aProjectData")
        .doc(customerId)
        .collection('places')
        .doc(objectId)
        .collection('orders')
        .doc(orderId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(orderDetailsRef, {
          'deliverId': deliverId,
          'deliverName': deliverName,
          'orderStatus': orderStatus,
          'deliverSelectedTime': DateTime.now().millisecondsSinceEpoch,
        });
      });
    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    } catch (e) {
      print('e-updateShipmentOrders------------$e');
    }
  }

  Future<void> updateProductTransaction233(
      {required AllPositionModel allPositionModel}) async {
    //final fireStore = FirebaseFirestore.instance;

    try {
      final DocumentReference docRef =
          fireStore.collection("product").doc(allPositionModel.docId);

      await fireStore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          final num currentProductQuantity = double.parse(
              AllPositionModel.snapFromDoc(docSnapshot).productQuantity);

          final num newProductQuantity = currentProductQuantity +
              double.parse(allPositionModel.productQuantity);

          Map<String, dynamic> updateData = {
            'available': allPositionModel.available,
            'productFirsPrice': allPositionModel.productFirsPrice,
            'productPrice': allPositionModel.productPrice,
            'productQuantity': newProductQuantity.toString(),
          };

          if (allPositionModel.united != 0) {
            // Получаем текущее значение united и прибавляем его к остатку
            final num currentUnited =
                AllPositionModel.snapFromDoc(docSnapshot).united!;
            final num newUnited = (currentUnited + allPositionModel.united!);

            updateData['united'] = newUnited;
          }

          transaction.update(docRef, updateData);

          print('Product update successful');
        } else {
          print('Product document does not exist');
        }
      });
    } catch (e) {
      print('Error updating product: $e');
    }
  }
}
