import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ya_bazaar/res/fb_services/fb_services.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';

class PositionsFBServices{
  FbService fbService = FbService();
  final fireStore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance;

  Future<List<dynamic>> fetchMultiplePosition({required List<dynamic> projectRootIdList}) async {
    List<dynamic> combinedData = [];

    print('**PositionsFBServices/fetchMultiplePosition/projectRootIdList:$projectRootIdList');

    for (String collectionName in projectRootIdList) {

      CollectionReference collRef = fireStore.collection('aProjectData').doc(collectionName).collection('warehouse');

      await collRef.limit(1).get().then((value) {

        combinedData.add(value);

      });
    }
    return combinedData;
  }


  Future<List<dynamic>> fetchMultiplePositionForSearch({required List<dynamic> projectRootIdList}) async {
    List<dynamic> combinedData = [];

    print('**PositionsFBServices/fetchMultiplePosition/projectRootIdList:$projectRootIdList');

    for (String collectionName in projectRootIdList) {

      CollectionReference collRef = fireStore.collection('aProjectData').doc(collectionName).collection('warehouse');

      await collRef.orderBy('addedAt', descending: true).get().then((value) {

        combinedData.add(value);

      });
    }
    return combinedData;
  }

  Future<List<dynamic>> fetchMultiplePositionDiscount({required List<String> projectRootIdList}) async {
    List<dynamic> combinedData = [];

    try {
      for (String collectionName in projectRootIdList) {
        CollectionReference collRef = FirebaseFirestore.instance.collection('aProjectData').doc(collectionName).collection('warehouse').doc('docId').collection('positionDiscount');

        QuerySnapshot snapshot = await collRef.get();
        combinedData.add(snapshot);
      }
      return combinedData;
    } catch (e) {
      // Обработка ошибок, если они возникают при получении данных из Firestore
      print('Ошибка при получении данных: $e');
      return []; // или верните null или другое значение по умолчанию, в зависимости от вашей логики
    }
  }


  Stream<QuerySnapshot> getOnlyOwnerPositions({required String ownerId}){
    print('ownerId:  $ownerId');
    return fireStore.collection('aProjectData').doc(ownerId).collection('warehouse').limit(10).snapshots();
    //return fireStore.collection('aProjectData').doc(ownerId).collection('warehouse').snapshots();
  }

  Stream<QuerySnapshot> getSubscribers(String userId){
    print('**PositionsFBServices/getSubscribers/userId: $userId');
    return fireStore.collection('aProjectData').doc(userId).collection('subscribers').snapshots();
  }

  // Future<List<dynamic>> subscribersIdList(String userId) async {
  //
  //
  //   List<dynamic>? subscribersList;
  //
  //
  //   CollectionReference collRef = fireStore.collection('aProjectData').doc('r9RxHHyJiVVXoJAb8AFeCK5Qdx32').collection('subscribers');
  //
  //   collRef.get().then((value) async{
  //
  //     for (var element in value.docs) {
  //
  //       subscribersList!.add(element.id);
  //
  //       print('element.id--------${element.id}');
  //     }
  //
  //   });
  //   print('subscribersList--------$subscribersList');
  //   return subscribersList!;
  // }




  Stream<QuerySnapshot> getPositionsByProjectRootId(String projectRootId) {
    return fireStore.collection('aProjectData')
        .doc(projectRootId).collection('warehouse')
        .orderBy('addedAt', descending: true).snapshots();
  }




  Future<void> addPosition2({
    required String projectRootId,
    required PositionModel positionModel,
    required File positionImage,
  }) async {
    try {
      await fireStore.runTransaction((Transaction transaction) async {

        DocumentReference productDocRef = fireStore.collection('aProjectData').doc(projectRootId).collection('warehouse').doc();

        transaction.set(productDocRef,positionModel.toJsonForDb());

        if (positionImage.existsSync()) {
          await fbService.uploadSingleImg(
              dirName1: 'product_image',
              fileName: productDocRef.id,
              imageFile: positionImage,
              ).then((String downloadUrl)  {
            transaction.update(productDocRef, {'productImage': downloadUrl});
          });
        }
        return productDocRef.id;
      }).then((value) => print('transaction addPosition success: $value'));
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }


  Future<void> addPosition(
      {required AllPositionModel allPositionModel,
        required File positionImage}) async {
    try {
      await fireStore.runTransaction((Transaction transaction) async {
        await fireStore
            .collection('product')
            .add(allPositionModel.toJsonForDb())
            .then((value) async {
          DocumentReference docRef = fireStore.collection('product').doc(value.id);

          if (positionImage.existsSync()) {
            String downloadUrl = await fbService.uploadSingleImg(
                dirName1: 'product_image',
                fileName: value.id,
                imageFile: positionImage,
                );
            transaction.update(docRef, {'productImage': downloadUrl});
          }
        });
      });
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }

  Future<void> addPosition3({
     String? projectRootId,
     PositionModel? positionModel,
     List<PositionModel>? positionModelList,
  }) async {

    DocumentReference productDocRef = fireStore.collection('aProjectData').doc(projectRootId).collection('warehouse').doc();
    CollectionReference productCollRef = fireStore.collection('aProjectData').doc(projectRootId).collection('warehouse');

    try {

      await fireStore.runTransaction((Transaction transaction) async {

        // for (var element in positionModelList!) {
        //   print(element.docId);
        //   DocumentReference productDocRef = productCollRef.doc(element.docId);
        //   transaction.update(productDocRef, {'productQuantity': 0});
        // }


        transaction.set(productDocRef, positionModel!.toJsonForDb());

      }).then((value) => print('transaction addPosition success: $value'));
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }




  Future<void> updatePosition({
    required PositionModel positionModel,
    required File positionImage,
  }) async {
    DocumentReference docRef = fireStore.collection('product').doc(positionModel.docId);
    try {
      if (positionImage.existsSync()) {
        String downloadUrl = await fbService.uploadSingleImg(
            dirName1: 'product_image',
            fileName: positionModel.docId!,
            imageFile: positionImage,
            );
        positionModel.productImage = downloadUrl;
      }

      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, positionModel.toJsonForDb());
      });
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }


  Future<String> updateAllPosition({
    required PositionModel positionModel,
  }) async {

    DocumentReference docRef = fireStore.collection('aProjectData').doc(positionModel.projectRootId).collection('warehouse').doc(positionModel.docId);
    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, {'unitedList':[],'united':0,'productQuantity':0,});
      });
    } catch (e) {
      print('errorAddPosition :: $e');
    }

    return docRef.id;
  }



  Future<void> updatePosition2({
    required PositionModel positionModel,
    required File positionImage,
  }) async {

    DocumentReference docRef = fireStore.collection('aProjectData').doc(positionModel.projectRootId).collection('warehouse').doc(positionModel.docId);
    try {
      if (positionImage.existsSync()) {
        String downloadUrl = await fbService.uploadSingleImg(
          dirName1: 'product_image',
          fileName: positionModel.docId!,
          imageFile: positionImage,
        );
        positionModel.productImage = downloadUrl;
      }

      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, positionModel.toJsonForDb());
      });
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }




  Future<void> deletePosition({
    required String projectRootId,
    required positionId,
    required String imageUrl,}) async {

    DocumentReference docRef = fireStore.collection('aProjectData').doc(projectRootId).collection('warehouse').doc(positionId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.delete(docRef);
      }).then((value) async {
        await fbService
            .deleteSingleImgFromStorage(imageUrl)
            .then((value) => print('deleteSingleImgSuccess'));
      });
    } catch (e) {
      print('errorDeletePosition :: $e');
    }
  }


  Future<void> deletePositionDiscount({
    required String projectRootId,
    required String positionId,
    required String discountId,}) async {

    DocumentReference docRef
    = fireStore.collection('aProjectData')
        .doc(projectRootId).collection('warehouse')
        .doc(positionId).collection('positionDiscount').doc(discountId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.delete(docRef);
      });
    } catch (e) {
      print('errorDeletePositionDiscount :: $e');
    }
  }





  Future<void> addPositionDiscount({
    required String projectRootId,
    required String positionId,
    required List<DiscountModel> discountList,
  }) async {

    print('projectRootId: $projectRootId');
    print('positionId: $positionId');
    print('discountList.length: ${discountList.length}');

    try {
      await fireStore.runTransaction((transaction) async {
        CollectionReference positionDiscountCollection = fireStore.collection('aProjectData')
            .doc(projectRootId)
            .collection('warehouse')
            .doc(positionId)
            .collection('positionDiscount');

        for (var element in discountList) {
          // Создаем уникальный DocumentReference для каждой скидки
          DocumentReference discountDocRef = positionDiscountCollection.doc();

          // Устанавливаем данные для каждого документа скидки
          transaction.set(discountDocRef, element.toJsonForDb());
        }
      }).then((_) => print('transaction addPosition success'));
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }

  Future<void> addPositionDiscount2({
    required String projectRootId,
    required String positionId,
    required DiscountModel discount,
  }) async {
    try {
      await fireStore.runTransaction((transaction) async {
        DocumentReference positionDiscountDoc = fireStore.collection('aProjectData')
            .doc(projectRootId)
            .collection('warehouse')
            .doc(positionId)
            .collection('positionDiscount')
            .doc();

        transaction.set(positionDiscountDoc, discount.toJsonForDb());


      }).then((_) => print('addPositionSingleDiscount success'));
    } catch (e) {
      print('errorAddPositionSingleDiscount :: $e');
    }
  }


  Future<void> updatePositionDiscount({
    required String projectRootId,
    required String positionId,
    required List<DiscountModel> discountList,
  }) async {
    try {
      await fireStore.runTransaction((transaction) async {
        CollectionReference positionDiscountCollection = fireStore.collection('aProjectData')
            .doc(projectRootId)
            .collection('warehouse')
            .doc(positionId)
            .collection('positionDiscount');

        for (var element in discountList) {

          print('element.docId -- ${element.docId}');


          // Создаем уникальный DocumentReference для каждой скидки
          DocumentReference discountDocRef = positionDiscountCollection.doc();

          // Устанавливаем данные для каждого документа скидки
          //transaction.update(discountDocRef, element.toJson());
        }
      }).then((_) => print('transaction updatePosition success'));
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }

  Future <QuerySnapshot> fetchPositionsDiscount({
    required DiscountModel arguments,}) async {
    
    final String rootId = arguments.rootId!;
    final String positionId = arguments.positionId;
    
    print('**PositionsFBServices/getPositionsDiscount/rootId:$rootId');
    print('**PositionsFBServices/getPositionsDiscount/positionId:$positionId');
    
    return await fireStore.collection('aProjectData')
        .doc(rootId).collection('warehouse')
        .doc(positionId).collection('positionDiscount').get();
  }

  Stream<QuerySnapshot> fetchPositionsDiscount2({
    required DiscountModel arguments,}) {

    final String rootId = arguments.rootId!;
    final String positionId = arguments.positionId;

    print('**PositionsFBServices/fetchPositionsDiscount2/rootId:$rootId');
    print('**PositionsFBServices/fetchPositionsDiscount2/positionId:$positionId');

    return fireStore.collection('aProjectData')
        .doc(rootId).collection('warehouse')
        .doc(positionId).collection('positionDiscount').snapshots();
  }



}