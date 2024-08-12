import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class SubscribersModel {
  String? docId;
  String customerId;
  String projectRootId;
  num discountPercent;
  num limit;
  num? totalSum;
  int addedAt;

  SubscribersModel({
    this.docId,
    required this.customerId,
    required this.projectRootId,
    required this.discountPercent,
    required this.addedAt,
    required this.limit,
    this.totalSum,
  });


  Map<String, dynamic> toJson() => {
        "customerId": customerId,
        "projectRootId": projectRootId,
        "discountPercent": discountPercent,
        "limit": limit,
        "addedAt": addedAt,
      };

  static SubscribersModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;

    return SubscribersModel(
      docId: docId,
      customerId: snapshot['customerId'] ?? '',
      projectRootId: snapshot['projectRootId'] ?? '',
      discountPercent: snapshot['discountPercent'] ?? 0,
      limit: snapshot['limit'] ?? 0,
      addedAt: 0,

    );
  }

  static SubscribersModel empty() {
    return SubscribersModel(
        customerId: '', projectRootId: '', discountPercent: 0, addedAt: 0, limit: 0);
  }
}



class SubscribersSortModel {

  List<UserModel> subscribCustomersList;
  List<dynamic> subscribCustomersIdList;

  List<UserModel> subscribOwnerList;
  List<dynamic> subscribOwnerIdList;

  List<UserModel> subscribersList;
  List<UserModel> notSubscribersList;

  List<dynamic> subscribersIdList;
  List<dynamic> notSubscribersIdList;

  SubscribersSortModel({
    required this.subscribCustomersList,
    required this.subscribCustomersIdList,

    required this.subscribOwnerList,
    required this.subscribOwnerIdList,

    required this.subscribersList,
    required this.notSubscribersList,
    required this.subscribersIdList,
    required this.notSubscribersIdList,
  });

  static empty(){
    return SubscribersSortModel(
        subscribCustomersList: [],
        subscribCustomersIdList: [],
        subscribersList: [],
        notSubscribersList: [],
        subscribersIdList: [],
        notSubscribersIdList: [],
        subscribOwnerList: [],
        subscribOwnerIdList: []);
  }

}



class CustomerPlacesModel {

  String? docId;
  String placeId;
  int addedAt;

  CustomerPlacesModel({
    this.docId,
    required this.placeId,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    "placeId": placeId,
    "addedAt": addedAt,
  };

  static CustomerPlacesModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;

    return CustomerPlacesModel(
      docId: docId,
      placeId: snapshot['placeId'] ?? 'placeId',
      addedAt: snapshot['addedAt'] ?? 0,
    );
  }



 static Map<String, List> createArgumentsMap(value) {
    Map<String, List<dynamic>> argumentsMap = {};
    value.forEach((key, value) {
      List<dynamic> placeList = value.docs.map((DocumentSnapshot doc) => CustomerPlacesModel.fromSnap(doc)).toList();
      argumentsMap[key] = placeList.map((e) => e.placeId).toList();
    });
    return argumentsMap;
  }


  static empty(){
    return CustomerPlacesModel(placeId: '', addedAt: 0);
  }

}