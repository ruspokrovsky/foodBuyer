import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';

class PurchaseFBServices {
  //final firebaseStorage = FirebaseStorage.instans;
  final fireStore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllPurchases() {
    return fireStore.collection('purchasing').snapshots();
  }

  Stream<QuerySnapshot> getAllPurchases2(String rootId) {
    return fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('purchasing')
        .orderBy('selectedTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getPurchasesByStatus({
    required String rootId,
  }) {
    return fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('purchasing')
        .where('purchasingStatus', isEqualTo: 0).snapshots();
  }

  Stream<DocumentSnapshot> getPositionQtyById(String productId) {
    return fireStore.collection('product').doc(productId).snapshots();
  }

  Future<void> updatePurchase({
    required PurchasingModel purchasingModel,
    required PositionModel positionModel,
    required List<dynamic> oldNewPrise,
  }) async {
    DocumentReference purchasingDocRef = fireStore
        .collection('aProjectData')
        .doc(purchasingModel.projectRootId)
        .collection('purchasing')
        .doc(purchasingModel.docId);
    DocumentReference positionDocRef = fireStore
        .collection('aProjectData')
        .doc(purchasingModel.projectRootId)
        .collection('warehouse')
        .doc(purchasingModel.productId);


    num currentQty = purchasingModel.actualQty;
    num orderQty = purchasingModel.orderQty;


    try {
      fireStore.runTransaction((Transaction transaction) async {
        transaction.update(purchasingDocRef, {
          'actualPrice': purchasingModel.actualPrice,
          'actualQty': purchasingModel.actualQty,
          'purchasingStatus': purchasingModel.purchasingStatus,
        });
        //по факту закупа обнавляем закупочную и отпускную цены
        transaction.update(positionDocRef, {
          'productFirsPrice': oldNewPrise[0],
          'productPrice': oldNewPrise[1],
          'ndsStatus': purchasingModel.ndsStatus,
        });
        //ели закуп меньше чем заказ значит от заказа отнимаем закуп полученную разницу
        // прибавляем к текщему united
        if (currentQty < orderQty) {

          final DocumentSnapshot docSnapshot = await positionDocRef.get();

          if (docSnapshot.exists) {
            Map<String, dynamic>? data = docSnapshot.data() as Map<String,dynamic>?;

            if (data != null) {

              final num differenceQty = (orderQty - currentQty);
              final num united = data['united'];
              final num newUnited = (united + differenceQty);
              final List<dynamic> currentUnitedList = data['unitedList'];
              currentUnitedList.add(differenceQty);
              transaction.update(positionDocRef, {'united': newUnited,'unitedList': currentUnitedList,});
            }
          }

        }


      });
    } catch (e) {
      print('e----------$e');
    }
  }

  Future<void> updatePurchaseAfterReceivedWarehouse(
      {required PurchasingModel purchasingModel}) async {
    purchasingModel.receivedDate = DateTime.now().millisecondsSinceEpoch;

    try {
      await fireStore
          .collection('purchasing')
          .doc(purchasingModel.docId)
          .update({
        'receivedQuantity': purchasingModel.receivedQuantity,
        'receivedDate': purchasingModel.receivedDate,
        'purchasingStatus': purchasingModel.purchasingStatus,
      });
    } catch (e) {
      print('e----------$e');
    }
  }

  Future<void> updateProductTransaction({
    required AllPositionModel allPositionModel,
    required PurchasingModel purchasingModel,
    required String purchasingPositionId,
  }) async {
    //final fireStore = FirebaseFirestore.instance;

    final DocumentReference productDocRef =
        fireStore.collection("product").doc(allPositionModel.docId);
    final DocumentReference purchasingDocRef =
        fireStore.collection("purchasing").doc(purchasingPositionId);

    print('------------------------------productDocRef');
    print(productDocRef);
    print(purchasingDocRef);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot docSnapshot =
            await transaction.get(productDocRef);

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

          transaction.update(productDocRef, updateData);
          transaction.update(purchasingDocRef, {
            'receivedQuantity': purchasingModel.receivedQuantity,
            'receivedDate': purchasingModel.receivedDate,
            'purchasingStatus': purchasingModel.purchasingStatus,
          });

          print('Product update successful');
        } else {
          print('Product document does not exist');
        }
      });
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> returnQtyProduct({
    required String projectRootId,
    required String productId,
    required num returnQty,
    required String customerId,
    required String objectId,
    required String orderId,
    required String positionId,
  }) async {

    DocumentReference productDocRef
    = fireStore
        .collection('aProjectData')
        .doc(projectRootId)
        .collection('warehouse')
        .doc(productId);

    final DocumentReference orderPositionRef
    = fireStore
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
        final DocumentSnapshot docSnapshot = await transaction.get(productDocRef);

        if (docSnapshot.exists) {
          final num currentProductQuantity = PositionModel.snapFromDoc(docSnapshot).productQuantity;

          final num newProductQuantity = (currentProductQuantity + returnQty);

          Map<String, dynamic> updatePositionData = {
            'productQuantity': newProductQuantity,
          };

          transaction.update(productDocRef, updatePositionData);

          transaction.update(orderPositionRef, {'returnQty': 0,});

        } else {
          print('Product document does not exist');
        }
      });
    } catch (e) {
      print('Error updating product: $e');
    }
  }






  Future<void> updateProductTransaction2({
    required PositionModel positionModel,
    required PurchasingModel purchasingModel,
  }) async {
    //final fireStore = FirebaseFirestore.instance;

    DocumentReference productDocRef = fireStore
        .collection('aProjectData')
        .doc(purchasingModel.projectRootId)
        .collection('warehouse')
        .doc(purchasingModel.productId);

    DocumentReference purchasingDocRef = fireStore
        .collection('aProjectData')
        .doc(purchasingModel.projectRootId)
        .collection('purchasing')
        .doc(purchasingModel.docId);

    //final DocumentReference productDocRef = fireStore.collection("product").doc(positionModel.docId);
    //final DocumentReference purchasingDocRef = fireStore.collection("purchasing").doc(purchasingPositionId);

    print('------------------------------productDocRef');
    print(productDocRef);
    print(purchasingDocRef);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot docSnapshot =
            await transaction.get(productDocRef);

        if (docSnapshot.exists) {
          final num currentProductQuantity =
              PositionModel.snapFromDoc(docSnapshot).productQuantity;

          final num newProductQuantity =
              (currentProductQuantity + positionModel.productQuantity);

          Map<String, dynamic> updatePositionData = {
            'available': positionModel.available,
            //'productFirsPrice': positionModel.productFirsPrice,
            //'productPrice': positionModel.productPrice,
            'productQuantity': newProductQuantity,
            'deliverId': purchasingModel.buyerId,
            'deliverName': purchasingModel.buyerName,
            'deliverSelectedTime': DateTime.now().millisecondsSinceEpoch,
            'addedAt': DateTime.now().millisecondsSinceEpoch,
          };

          // if (positionModel.united != 0) {
          //   // Получаем текущее значение united и прибавляем его к остатку
          //   final num currentUnited =
          //       PositionModel.snapFromDoc(docSnapshot).united;
          //   final num newUnited = (currentUnited + positionModel.united);
          //
          //   //updatePositionData['united'] = newUnited;
          // }

          transaction.update(productDocRef, updatePositionData);
          transaction.update(purchasingDocRef, {
            'receivedQuantity': purchasingModel.receivedQuantity,
            'receivedDate': purchasingModel.receivedDate,
            'purchasingStatus': purchasingModel.purchasingStatus,
          });

          print('Product update successful');
        } else {
          print('Product document does not exist');
        }
      });
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<String> addPurchase({
    required String rootId,
    required PurchasingModel purchasingModel,
  }) async {

    // Инициализация Completer
    Completer<String> completer = Completer<String>();

    final DocumentReference purchasingRef = fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('purchasing')
        .doc();

    final DocumentReference productRef = fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('warehouse')
        .doc(purchasingModel.productId);

    purchasingModel.selectedTime = DateTime.now().millisecondsSinceEpoch;

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.set(purchasingRef, purchasingModel.toJsonForDb());
        transaction.update(productRef, {'united': 0, 'unitedList': []});
      }).then((_) {
        // Пометка как завершенное, когда вторая транзакция завершается
        completer.complete('TransactionCompletedSuccessfully');
      });
      return await completer.future;
    } catch (e) {
      return "Transaction failed: $e";
    }
  }



  Future<String> addPurchase2({
    required String rootId,
    required PurchasingModel purchasingModel,
  }) async {

    // Инициализация Completer
    Completer<String> completer = Completer<String>();

    final DocumentReference purchasingRef = fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('purchasing')
        .doc();

    final DocumentReference productRef = fireStore
        .collection('aProjectData')
        .doc(rootId)
        .collection('warehouse')
        .doc(purchasingModel.productId);

    purchasingModel.selectedTime = DateTime.now().millisecondsSinceEpoch;

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.set(purchasingRef, purchasingModel.toJsonForDb());
      });
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(productRef, {'united': 0, 'unitedList': []});
      }).then((_) {
        // Пометка как завершенное, когда вторая транзакция завершается
        completer.complete('TransactionCompletedSuccessfully');
      });
      return await completer.future;
    } catch (e) {
      return "Transaction failed: $e";
    }
  }











  // Future<void> resetUnited({required String productId}) async {
  //
  //   try {
  //
  //     await fireStore.collection('product').doc(productId).update({'united':0})
  //         .then((value) => print('united-updates-success'));
  //
  //   } catch (e) {
  //     print('e----------$e');
  //   }
  // }

  Future<void> updateProduct({
    required AllPositionModel allPositionModel,
  }) async {
    try {
      var fireStores =
          fireStore.collection("product").doc(allPositionModel.docId);

      await fireStores.get().then((value) async {
        //получаем текущее значение productQuantity прибавляем его к приходу
        num productQuantity = (double.parse(value.data()!['productQuantity']) +
            double.parse(allPositionModel.productQuantity));

        //проверяем, eсли имеется остаток по закупу
        //получаем текущее значение united прибавляем его к остатку
        if (allPositionModel.united != 0) {
          num united = value.data()!['united'] + allPositionModel.united!;

          await fireStores.update({
            'available': allPositionModel.available,
            'productFirsPrice': allPositionModel.productFirsPrice,
            'productPrice': allPositionModel.productPrice,
            'productQuantity': productQuantity.toString(),
            'united': united,
          }).then((value) => print('product-united-updates-success'));
        } else {
          await fireStores.update({
            'available': allPositionModel.available,
            'productFirsPrice': allPositionModel.productFirsPrice,
            'productPrice': allPositionModel.productPrice,
            'productQuantity': productQuantity.toString(),
          }).then((value) => print('product-updates-success'));
        }
      });
    } catch (e) {
      print('e----------${e.toString()}');
    }
  }
}
