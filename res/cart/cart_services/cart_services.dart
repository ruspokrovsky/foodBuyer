import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ya_bazaar/res/cart/cart_services/real_time_services.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/models/subscribers_model.dart';
import 'package:ya_bazaar/res/models/united_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class CartFBServices {
  final fireStore = FirebaseFirestore.instance;
  final RealTimeServices realTimeDbs = RealTimeServices();


  Future<void> addOrder({required OrderDetailsModel orderDataList}) async {

    orderDataList.addedAt = DateTime.now().millisecondsSinceEpoch;

    //final DocumentReference docRef = fireStore.collection("ordersN").doc(orderDataList.objectId).collection("orders").doc();

    final DocumentReference docRef = fireStore.collection("aOrders").doc(orderDataList.objectId).collection("orders").doc();
    final CollectionReference collRef = docRef.collection('orderList');
    print('projectRootId: ${orderDataList.orderPositionsList!.first.projectRootId}');

    final DocumentReference subscribersDocRef = fireStore.collection("aSubscribers").doc(orderDataList.orderPositionsList!.first.projectRootId);
    SubscribersModel subscribersModel = SubscribersModel(customerId: orderDataList.objectId, projectRootId: orderDataList.orderPositionsList!.first.projectRootId, addedAt: DateTime.now().millisecondsSinceEpoch, discountPercent: 0, limit: 0);
    try{

      await fireStore.runTransaction((Transaction transaction) async {

        transaction.set(docRef, orderDataList.toJsonForDb());
        for (var element in orderDataList.orderPositionsList!) {
          final DocumentReference newProductRef = collRef.doc();
          transaction.set(newProductRef, element.toJsonForDb());
        }

        transaction.set(subscribersDocRef, subscribersModel.toJson());
      });

    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    }catch(e){
      print('e-addOrder------------$e');

    }
  }


  Future<void> addPurchase({
    required String rootId,
    required PurchasingModel purchasingModel,
  }) async {
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

        transaction.update(productRef, {'united': 0});
      });
    } catch (e) {
      print('e----------$e');
    }
  }



  Future<void> addOrder2({
    required OrderDetailsModel orderData,
    required UserModel userData,
    required SubscribersModel subscribersModel,
    required num placeStatus,
  }) async {

    int curentDateTime = DateTime.now().millisecondsSinceEpoch;

    orderData.addedAt = curentDateTime;
    subscribersModel.addedAt = curentDateTime;

    final DocumentReference placeRef = fireStore.collection("aProjectData").doc(orderData.userId).collection("places").doc(orderData.objectId);

    final DocumentReference docRef = placeRef.collection("orders").doc();
    final CollectionReference collRef = docRef.collection('orderList');

    final DocumentReference subscribersCustomerRef
    = fireStore.collection("aProjectData").doc(orderData.userId).collection("subscribers").doc(orderData.projectRootId);
    final DocumentReference subscribersRootRef
    = fireStore.collection("aProjectData").doc(orderData.projectRootId).collection("subscribers").doc(orderData.userId);
    // в коллекции подписок у снабжения создаем коллекцию id объектов каждого подписанного заказчика, т.к.
    // заявки лежат внутри объекта, соответственно снабжению потребуются id обслуживаемых объектов при ролучении соответствующих заявок
    // эта коллекция нужна только снабжению, закзчик видит все свои заявки от разных поставщиков а снабжение видит только свои заявки у своих заказчиков
    final DocumentReference customerPlacesRef = subscribersRootRef.collection('customerPlaces').doc(orderData.objectId);

    final CollectionReference positionCollRef = fireStore.collection("aProjectData")
        .doc(orderData.projectRootId).collection("warehouse");

    CustomerPlacesModel customerPlacesModel = CustomerPlacesModel(
        placeId: orderData.objectId,
        addedAt: curentDateTime);

    try{

      await fireStore.runTransaction((Transaction transaction) async {

        for (var element in orderData.orderPositionsList!) {
          final DocumentReference newProductRef = collRef.doc();


          OrderModel orderElement = element;
          final DocumentReference docRef = positionCollRef.doc(element.productId);
          final DocumentSnapshot docSnapshot = await docRef.get();

          if (docSnapshot.exists) {
            Map<String, dynamic>? data = docSnapshot.data() as Map<String,dynamic>?;

            if (data != null) {

              final List<dynamic> currentUnitedList = data['unitedList'];
              currentUnitedList.add(orderElement.productQuantity);
              final num currentProductQuantity = data['productQuantity'];
              print('currentUnitedList>>>>>>---$currentUnitedList');

              final num unitedSum = currentUnitedList.reduce((val, elem) => val + elem);
              print('unitedSum>>>>>>---$unitedSum');
              print('currentProductQuantity>>>>>>---$currentProductQuantity');

              if(unitedSum > currentProductQuantity){
                final num newUnited = (unitedSum - currentProductQuantity);
                transaction.update(docRef, {'united': newUnited,'unitedList': currentUnitedList,});
              }
              else {

                transaction.update(docRef, {'united': 0,'unitedList': currentUnitedList,});
              }
            }
          }

          transaction.set(newProductRef, element.toJsonForDb());
        }
        transaction.set(docRef, orderData.toJsonForDb());
        transaction.set(subscribersCustomerRef, subscribersModel.toJson());
        transaction.set(subscribersRootRef, subscribersModel.toJson());
        transaction.set(customerPlacesRef, customerPlacesModel.toJson());
        transaction.update(placeRef, {'successStatus' : placeStatus});
      });

    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    }catch(e){
      print('e-addOrder------------$e');

    }
  }


  Future<void> updateUnitedPosition2({
    required OrderDetailsModel orderDataList,
  }) async {

    final CollectionReference positionCollRef = fireStore.collection("aProjectData")
        .doc(orderDataList.projectRootId).collection("warehouse");

    // Сначала читаем все необходимые данные
    final List<DocumentSnapshot> positionDocSnapshots = [];
    for (OrderModel orderElement in orderDataList.orderPositionsList!) {

      final DocumentReference positionDocRef = positionCollRef.doc(orderElement.productId);
      final DocumentSnapshot docSnapshot = await positionDocRef.get();
      positionDocSnapshots.add(docSnapshot);
    }
    try {

      await fireStore.runTransaction((Transaction transaction) async {

        for (int i = 0; i < orderDataList.orderPositionsList!.length; i++) {

          OrderModel orderElement = orderDataList.orderPositionsList![i];
          final DocumentReference docRef = positionCollRef.doc(orderElement.productId);
          final DocumentSnapshot positiondocSnapshot = positionDocSnapshots[i];

          if (positiondocSnapshot.exists) {
            Map<String, dynamic>? data = positiondocSnapshot.data() as Map<String,dynamic>?;

            if (data != null) {

              final List<dynamic> currentUnitedList = data['unitedList'];
              currentUnitedList.add(orderElement.productQuantity);
              final num currentProductQuantity = data['productQuantity'];

              final num unitedSum = currentUnitedList.reduce((val, elem) => val + elem);

              if(unitedSum > currentProductQuantity){
                final num newUnited = (unitedSum - currentProductQuantity);
                transaction.update(docRef, {'united': newUnited,'unitedList': currentUnitedList,});
              }
              else {

                transaction.update(docRef, {'united': unitedSum,'unitedList': currentUnitedList,});
              }


            }
          } else {
            print('----Поле united отсутствует в документе---------');
          }
        }

      });

    } catch (e) {
      print('e-addUnitedPosition---------$e');
    }
  }



  Future<void> updateUnitedPosition({required OrderDetailsModel orderDataList}) async {
    final CollectionReference collRef = fireStore.collection("product");


    // Сначала читаем все необходимые данные
    final List<DocumentSnapshot> docSnapshots = [];
    for (var element in orderDataList.orderPositionsList!) {
      final DocumentReference docRef = collRef.doc(element.productId);
      final DocumentSnapshot docSnapshot = await docRef.get();
      docSnapshots.add(docSnapshot);
    }

    try {

      await fireStore.runTransaction((Transaction transaction) async {

        for (var i = 0; i < orderDataList.orderPositionsList!.length; i++) {

          final element = orderDataList.orderPositionsList![i];
          final DocumentReference docRef = collRef.doc(element.productId);
          final DocumentSnapshot docSnapshot = docSnapshots[i];

          if (docSnapshot.exists) {
            final num currentUnited = AllPositionModel.snapFromDoc(docSnapshot).united!;
            final num orderQty = element.productQuantity;
            num united = (orderQty + currentUnited);
            transaction.update(docRef, {'united': united});
          }
        }
      });

    } catch (e) {
      print('e-addUnitedPosition---------$e');
    }
  }




  Future<void> addUnitedPosition1({required OrderDetailsModel orderDataList}) async {

    try {

      for (var element in orderDataList.orderPositionsList!) {

       await fireStore.collection("product").doc(element.productId).get()
           .then((value) async {

             num united = value.data()!['united']+element.productQuantity;

         await fireStore.collection("product").doc(element.productId)
             .update({'united': united});
       });

      }
    } catch (e) {
      print('e----------$e');
    }
  }

}
