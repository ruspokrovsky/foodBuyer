import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';
import 'package:ya_bazaar/res/fb_services/fb_services.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';

class PlaceFBServices{

  //final firebaseStorage = FirebaseStorage.instans;
  final fireStore = FirebaseFirestore.instance;
  final FbService fbService = FbService();

  //----------REQUEST----------------------------------------------


  Future addFoodPlace({
    required PlaceModel placeModel,
    required File placeImageFile,
    required File locationImageFile,
  }) async {

    String placeImage;
    String locationImage;

    if(placeImageFile.existsSync()){
      placeImage = await fbService.uploadSingleImgToStorage(
          dirName1: placeModel.placeName,
          fileName: placeModel.docId!,
          imageFile: placeImageFile, );
    }else{
      placeImage = '';
    }

    if(locationImageFile.existsSync()){
      locationImage = await fbService.uploadSingleImgToStorage(
          dirName1: placeModel.placeName,
          fileName: '',
          imageFile: locationImageFile);
    }else{
      locationImage = '';
    }

    placeModel.placeImage = placeImage;
    placeModel.locationImage = locationImage;
    placeModel.addedAt = DateTime.now().millisecondsSinceEpoch;



    DocumentReference docRef = fireStore.collection('usersN').doc(placeModel.userId).collection('objects').doc();



    try {
      fireStore.runTransaction((Transaction transaction) async {
        transaction.set(docRef, placeModel.toJson());
      });

      //await fireStore.collection('foodPlaces').add(placeModel.toJson());

    } catch (e) {
      print('e----------$e');
    }

    return 'addObjectSuccess';
  }

  Future addPlace({
    required PlaceModel placeModel,
    required File placeImageFile,
    required File locationImageFile,
  }) async {

    String placeImage;
    String locationImage;




    placeModel.addedAt = DateTime.now().millisecondsSinceEpoch;

    DocumentReference docRef = fireStore.collection('aProjectData').doc(placeModel.userId).collection('places').doc();

    try {
      fireStore.runTransaction((Transaction transaction) async {
        transaction.set(docRef, placeModel.toJson());


        if(placeImageFile.existsSync()){
          placeImage = await fbService.uploadSingleImgToStorage(
              dirName1: 'placeProfileImage',
              fileName: docRef.id,
              imageFile: placeImageFile);
        }else{
          placeImage = '';
        }

        if(locationImageFile.existsSync()){
          locationImage = await fbService.uploadSingleImgToStorage(
              dirName1: 'placeProfileImage',
              fileName: '',
              imageFile: locationImageFile);
        }else{
          locationImage = '';
        }

        transaction.update(docRef, {'locationImage':locationImage,'placeImage':placeImage});


      });







    } catch (e) {
      print('e----------$e');
    }

    return docRef.id;
  }

  Future<void> updatePlace({
    required PlaceModel placeModel,
    required File placeImageFile,
    required File locationImageFile,
  }) async {


    DocumentReference docRef = fireStore.collection('aProjectData').doc(placeModel.userId).collection('places').doc(placeModel.docId);

    try {
      String placeImage;
      String locationImage;

      if(placeImageFile.existsSync()){
        placeImage = await fbService.uploadSingleImgToStorage(
            dirName1: 'placeProfileImage',
            fileName: placeModel.docId!,
            imageFile: placeImageFile);
        placeModel.placeImage = placeImage;
      }

      if(locationImageFile.existsSync()){
        locationImage = await fbService.uploadSingleImgToStorage(
            dirName1: 'placeProfileImage',
            fileName: '',
            imageFile: locationImageFile);
        placeModel.locationImage = locationImage;
      }

      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, placeModel.toJson());
      });
    } catch (e) {
      print('errorAddPosition :: $e');
    }
  }



  Future<void> deletePlace({
    required String userId,
    required placeId,
    required String imageUrl,
    required String locationImageUrl,}) async {

    //DocumentReference docRef = fireStore.collection('aProjectData').doc(projectRootId).collection('warehouse').doc(positionId);
    DocumentReference docRef = fireStore.collection('aProjectData').doc(userId).collection('places').doc(placeId);

    try {
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.delete(docRef);
      }).then((value) async {
        await fbService
            .deleteSingleImgFromStorage(imageUrl)
            .then((value) async {
            await fbService.deleteSingleImgFromStorage(locationImageUrl)
                .then((value) => print('deleteSingleImgSuccess'));

        });
      });
    } catch (e) {
      print('errorDeletePosition :: $e');
    }
  }



  Future<String> updatePlaceDiscount({
    required String customerId,
    required String rootId,
    required num discountPercent,
  }) async {
    DocumentReference customerDocRef
    = fireStore.collection('aProjectData')
        .doc(customerId).collection('subscribers').doc(rootId);

    DocumentReference ownerDocRef
    = fireStore.collection('aProjectData')
        .doc(rootId).collection('subscribers').doc(customerId);

    try {
      fireStore.runTransaction((Transaction transaction) async {
        transaction.update(customerDocRef, {'discountPercent': discountPercent});
        transaction.update(ownerDocRef, {'discountPercent': discountPercent});
      });

    } catch (e) {
      print('e----------$e');
    }
      return 'updatePlaceDiscountSuccess';
  }

  Future<String> updateLimit({
    required String customerId,
    required String rootId,
    required num limit,
  }) async {
    DocumentReference customerDocRef
    = fireStore.collection('aProjectData')
        .doc(customerId).collection('subscribers').doc(rootId);

    DocumentReference ownerDocRef
    = fireStore.collection('aProjectData')
        .doc(rootId).collection('subscribers').doc(customerId);

    try {
      fireStore.runTransaction((Transaction transaction) async {
        transaction.update(customerDocRef, {'limit': limit});
        transaction.update(ownerDocRef, {'limit': limit});
      });

    } catch (e) {
      print('e----------$e');
    }
    return 'updateLimitSuccess';
  }





//----------RESPONSE----------------------------------------------

  Stream<QuerySnapshot> getPlaceByUserId(String userId){
    return fireStore.collection('foodPlaces').where('userId', isEqualTo: userId).snapshots();
  }


  Stream<QuerySnapshot> getPlaceByUserId2(String userId){
    print('**PlaceFBServices/getPlaceByUserId2/userId:$userId');
    return fireStore.collection('aProjectData')
        .doc(userId)
        .collection('places')
        .orderBy('addedAt', descending: true).snapshots();
  }



  Stream<QuerySnapshot> getAllPlaces(){
    return fireStore.collection('foodPlaces').snapshots();
  }



  Future<Map<String, List<String>>> fetchMultiplePlacesqw({required PlaceParametersForRoot args}) async {
    Map<String, List<String>> resultMap = {};
    final String rootId = args.currentRootId;
    final List<String> customersIdList = args.customersIdList.cast<String>(); // Преобразуйте в список строк, если необходимо

    await Future.forEach(customersIdList, (customerId) async {
      var snapshot = await fireStore
          .collection('aProjectData')
          .doc(rootId)
          .collection('subscribers')
          .doc(customerId)
          .collection('customerPlaces')
          .get();

      List<String> documentIds = snapshot.docs.map((doc) => doc.id).toList();
      resultMap[customerId] = documentIds;
    });

    return resultMap;
  }


  // Future <Stream<QuerySnapshot>> getPlaceForRoot(PlaceParametersForRoot args){
  //   Map<String, List<String>> resultMap = {};
  //   final String userId = args.currentRootId;
  //   final List<String> customersIdList = args.customersIdList.cast<String>();
  //   Future.forEach(customersIdList, (customerId) async {
  //     var snapshot = fireStore
  //         .collection('aProjectData')
  //         .doc(userId)
  //         .collection('subscribers')
  //         .doc(customerId)
  //         .collection('customerPlaces')
  //         .snapshots();
  //
  //     List<String> documentIds = snapshot.docs.map((doc) => doc.id).toList();
  //     resultMap[customerId] = documentIds;
  //   });
  //
  //   return resultMap;
  //
  //
  //
  //
  //   //return fireStore.collection('aProjectData').doc(userId).collection('places').snapshots();
  // }

  Stream<Map<String, List<String>>> getPlaceForRoot23({required PlaceParametersForRoot args}) async* {
    final String userId = args.currentRootId;
    final List<String> customersIdList = args.customersIdList.cast<String>();

    for (final customerId in customersIdList) {
      var snapshot = await fireStore
          .collection('aProjectData')
          .doc(userId)
          .collection('subscribers')
          .doc(customerId)
          .collection('customerPlaces')
          .get();

      List<String> documentIds = snapshot.docs.map((doc) => doc.id).toList();

      yield {customerId: documentIds};
    }
  }




  Stream<Map<String, List<String>>> getPlaceArguments({required PlaceParametersForRoot args}) async* {
    Map<String, List<String>> resultMap = {};
    final String rootId = args.currentRootId;
    final List<dynamic> customersIdList = args.customersIdList;

    CollectionReference collRef = fireStore.collection('aProjectData').doc(rootId).collection('subscribers');

    for (final customerId in customersIdList) {
      var snapshot = await collRef
          .doc(customerId)
          .collection('customerPlaces')
          .get();

      List<String> placeDocIds = snapshot.docs.map((doc) => doc.id).toList();
      resultMap[customerId] = placeDocIds;
    }
    yield resultMap;
  }


  Future<List<DocumentSnapshot>> fetchMultiplePlaceForRoot({required Map<String, List<String>> collectionData}) async {
    List<DocumentSnapshot> result = [];


    await Future.forEach(collectionData.entries, (entry) async {
      String collectionName = entry.key; // Имя коллекции
      List<String> documentIds = entry.value; // Список идентификаторов документов

      await Future.forEach(documentIds, (docId) async {
        var snapshot = await FirebaseFirestore.instance
            .collection('aProjectData')
            .doc(collectionName) // Имя первой коллекции
            .collection('places')
            .doc(docId) // ID документа из второй коллекции
            .get();

        if (snapshot.exists) {
          result.add(snapshot);
        }
      });
    });

    return result;
  }

  Stream<List<DocumentSnapshot>> fetchMultiplePlaceForRootStream({required Map<String, List<String>> collectionData}) async* {
    List<DocumentSnapshot> result = [];

    for (var entry in collectionData.entries) {
      String collectionName = entry.key; // Имя коллекции
      List<String> documentIds = entry.value; // Список идентификаторов документов

      for (var docId in documentIds) {
        var snapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName) // Имя первой коллекции
            .collection('places')
            .doc(docId) // ID документа из второй коллекции
            .get();

        if (snapshot.exists) {
          result.add(snapshot);
        }
      }

       // Генерация текущего состояния списка в Stream
    }

    print('-------------------------result');
    print(result.length);

    yield result;
  }

  Stream<List<DocumentSnapshot>> fetchMultipleOrdersForRootStream({
    required Tuple2 arguments,
  }) async* {
    List<DocumentSnapshot> result = [];

    String rootId = arguments.item1;
    Map<String, List<String>> collectionData = arguments.item2;


    for (var entry in collectionData.entries) {
      String collectionName = entry.key; // Имя коллекции
      List<String> documentIds = entry.value; // Список идентификаторов документов

      for (var docId in documentIds) {
        var snapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName) // Имя первой коллекции
            .collection('places')
            .doc(docId) // ID документа из второй коллекции
            .collection('orders')
            .where('projectRootId', isEqualTo: rootId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            result.add(doc); // Добавление каждого документа из результатов запроса
          }
        }
      }


      yield result; // Генерация текущего состояния списка в Stream
    }
  }


  Stream<List<DocumentSnapshot>> fetchDataForRootStream1({
    required Tuple2 arguments,
  }) async* {

    StreamController<List<DocumentSnapshot>> controller =
    StreamController<List<DocumentSnapshot>>();

    String rootId = arguments.item1;
    Map<String, List<String>> collectionData = arguments.item2;

    List<DocumentSnapshot> result = [];

    for (var entry in collectionData.entries) {
      String collectionName = entry.key;
      List<String> documentIds = entry.value;

      for (var docId in documentIds) {
        var placeSnapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName)
            .collection('places')
            .doc(docId)
            .get();

        if (placeSnapshot.exists) {
          result.add(placeSnapshot);
        }

        var orderSnapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName)
            .collection('places')
            .doc(docId)
            .collection('orders')
            .where('projectRootId', isEqualTo: rootId)
            .get();

        if (orderSnapshot.docs.isNotEmpty) {
          for (var doc in orderSnapshot.docs) {
            result.add(doc);
          }
        }
      }
    }

    // Дождитесь завершения всех асинхронных операций и отправьте результаты через контроллер потока
    controller.add(result);
    controller.close();

    // Вернуть поток данных
    yield* controller.stream;
  }

  Stream<List<DocumentSnapshot>> fetchDataForRootStream({
    required Tuple2 arguments,
  }) async* {
    StreamController<List<DocumentSnapshot>> placeController =
    StreamController<List<DocumentSnapshot>>();

    StreamController<List<DocumentSnapshot>> orderController =
    StreamController<List<DocumentSnapshot>>();

    List<DocumentSnapshot> placeResult = [];
    List<DocumentSnapshot> orderResult = [];
    String rootId = arguments.item1;
    Map<String, List<String>> collectionData = arguments.item2;

    for (var entry in collectionData.entries) {
      String collectionName = entry.key;
      List<String> documentIds = entry.value;

      for (var docId in documentIds) {
        var placeSnapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName)
            .collection('places')
            .doc(docId)
            .get();

        if (placeSnapshot.exists) {
          placeResult.add(placeSnapshot);
        }

        var orderSnapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName)
            .collection('places')
            .doc(docId)
            .collection('orders')
            .where('projectRootId', isEqualTo: rootId)
            .get();

        if (orderSnapshot.docs.isNotEmpty) {
          for (var doc in orderSnapshot.docs) {
            orderResult.add(doc);
          }
        }
      }
    }

    // Отправить результаты в соответствующие контроллеры потоков
    placeController.add(placeResult);
    orderController.add(orderResult);

    // Закрыть контроллеры потоков
    placeController.close();
    orderController.close();

    // Вернуть потоки данных
    yield* placeController.stream;
    yield* orderController.stream;
  }






  Future<List<DocumentSnapshot>> fetchMultiplePlace({required Map<String, List<String>> collectionData}) async {
    List<DocumentSnapshot> result = [];

    await Future.forEach(collectionData.entries, (entry) async {
      String collectionName = entry.key; // Имя коллекции
      List<String> documentIds = entry.value; // Список идентификаторов документов

      await Future.forEach(documentIds, (docId) async {
        var snapshot = await FirebaseFirestore.instance
            .collection('aProjectData')
            .doc(collectionName) // Имя первой коллекции
            .collection('places')
            .doc(docId) // ID документа из второй коллекции
            .get();

        if (snapshot.exists) {
          result.add(snapshot);
        }
      });
    });

    return result;
  }



  Future<QuerySnapshot> fetchPlace({
    required String userId,

  }) async {
    return await FirebaseFirestore.instance
        .collection('aProjectData')
        .doc(userId)
        .collection('places')
        .get();
  }








  // //получаем id объектов подписанных заказчиков
  // //имея доступ к подписанным закзчикам, получаем соответствующие объекты по id из коллекции customerPlaces
  // Future<Map<dynamic, dynamic>> fetchMultiplePlacesqw({required PlaceParametersForRoot args}) async {
  //   Map<dynamic, dynamic> resultMap = {};
  //   final String userId = args.currentRootId;
  //   final List<dynamic> customersIdList = args.customersIdList;
  //
  //   await Future.forEach(customersIdList, (customerId) async {
  //     var snapshot = await fireStore
  //         .collection('aProjectData')
  //         .doc(userId)
  //         .collection('subscribers')
  //         .doc(customerId)
  //         .collection('customerPlaces')
  //         .get();
  //
  //     resultMap[customerId] = snapshot;
  //   });
  //
  //   return resultMap;
  // }
  //
  // Future<List<DocumentSnapshot>> fetchMultiplePlace({required Map<dynamic, dynamic> collectionData}) async {
  //   List<DocumentSnapshot> result = [];
  //
  //   // Перебираем каждую пару ключ-значение из предоставленной структуры
  //   await Future.forEach(collectionData.entries, (entry) async {
  //     String collectionName = entry.key; // Имя коллекции
  //     List<dynamic> documentIds = entry.value; // Список идентификаторов документов
  //
  //     // Получаем данные для каждой коллекции и списка документов
  //     await Future.forEach(documentIds, (docId) async {
  //       await FirebaseFirestore.instance
  //           .collection('aProjectData') // Имя первой коллекции
  //           .doc(collectionName)
  //           .collection('places')
  //           .doc(docId)// ID документа из второй коллекции
  //           .get().then((value) {
  //         result.add(value);
  //       });
  //
  //     });
  //   });
  //
  //   return result;
  // }
  //


  Future<List<dynamic>> fetchMultiplePlaces({required List<dynamic> customersIdList}) async {
    List<dynamic> combinedData = [];

    print('**PlaceFBServices/fetchMultiplePlaces/customersIdList:$customersIdList');

    for (String collectionName in customersIdList) {

      CollectionReference collRef = fireStore.collection('aProjectData').doc(collectionName).collection('places');

      await collRef.get().then((value) {

        combinedData.add(value);

      });
    }
    return combinedData;
  }





  Stream<QuerySnapshot> getCategory(){
    return fireStore.collection('category').snapshots();
  }

  Stream<QuerySnapshot> getSubCategory(String categoryId){
    return fireStore.collection('subCategory')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots();
  }


  Stream<QuerySnapshot> getAllPosition() {
    return fireStore.collection('product').snapshots();
  }


  Stream<QuerySnapshot> getAllPositionByObjectId(String objectId) {
    return fireStore.collection('product').snapshots();
  }

}



class CombinedData {
  Stream<List<DocumentSnapshot>> placeStream;
  Stream<List<DocumentSnapshot>> orderStream;

  CombinedData(this.placeStream, this.orderStream);
}

CombinedData fetchDataForRootStream({
  required Tuple2 arguments,
}) {
  final fireStore = FirebaseFirestore.instance;
  StreamController<List<DocumentSnapshot>> placeController =
  StreamController<List<DocumentSnapshot>>.broadcast();

  StreamController<List<DocumentSnapshot>> orderController =
  StreamController<List<DocumentSnapshot>>.broadcast();

  List<DocumentSnapshot> placeResult = [];
  List<DocumentSnapshot> orderResult = [];


  String rootId = arguments.item1;
  Map<String, List<String>> collectionData = arguments.item2;

  Future<void> fetchPlaceAndOrderData() async {
    for (var entry in collectionData.entries) {
      String collectionName = entry.key;
      List<String> documentIds = entry.value;

      for (var docId in documentIds) {
        var placeSnapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName)
            .collection('places')
            .doc(docId)
            .get();

        if (placeSnapshot.exists) {
          placeResult.add(placeSnapshot);
          placeController.add(placeResult);
        }

        var orderSnapshot = await fireStore
            .collection('aProjectData')
            .doc(collectionName)
            .collection('places')
            .doc(docId)
            .collection('orders')
            .where('projectRootId', isEqualTo: rootId)
            .get();

        if (orderSnapshot.docs.isNotEmpty) {
          for (var doc in orderSnapshot.docs) {
            orderResult.add(doc);
            orderController.add(orderResult);
          }
        }
      }
    }

    placeController.close();
    orderController.close();
  }

  fetchPlaceAndOrderData();

  return CombinedData(placeController.stream, orderController.stream);
}

