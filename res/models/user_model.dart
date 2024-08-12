import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? docId;
  String uId;
  String name;
  String email;
  String userRole;
  String password;
  String profilePhoto;
  String userPhone;
  String? lineStatus;
  int? lastActive;
  int? addedAt;
  String? fcmToken;
  String? userStatus;
  bool? isSelectedElement;


  String? rootId;
  //String? rootName;
  //List? rootLatLng;

  List<dynamic>? userRoles;
  num? discountPercent;
  num? limit;
  num? limitRemainder;
  num? debt;
  num? totalSum;

  String? subjectName;
  String? subjectImg;
  List<dynamic>? subjectLatLng;
  List<dynamic>? statusList;
  List<dynamic>? purchasingIdList;
  num? currentPurchaseAmount;
  String? fromWhichScreen;


  UserModel({

      this.docId,
      required this.uId,
      required this.name,
      required this.email,
      required this.userRole,
      required this.password,
      required this.profilePhoto,
      required this.userPhone,
      this.lineStatus,
      this.lastActive,
      this.addedAt,
      this.fcmToken,
      this.userStatus,
      this.isSelectedElement,

      this.rootId,
      //this.rootName,
      //this.rootLatLng,
      this.userRoles,
      this.discountPercent,
      this.limit,
      this.limitRemainder,
      this.debt,
      this.totalSum,
      this.subjectName,
      this.subjectImg,
      this.subjectLatLng,
      this.statusList,
      this.purchasingIdList,
      this.currentPurchaseAmount,
      this.fromWhichScreen,
  });

  Map<String, dynamic> toJson() => {
        "uId": uId,
        "name": name,
        "profilePhoto": profilePhoto,
        "email": email,
        "userRole": userRole,
        "password": password,
        "userPhone": userPhone,
        "lineStatus": lineStatus,
        "lastActive": lastActive,
        "addedAt": addedAt,
        "fcmToken": fcmToken,
        "userStatus": userStatus,
        "rootId": rootId,
    //"rootName": rootName,
    //"rootLatLng": rootLatLng,

    "userRoles": userRoles,
    "subjectName": subjectName??'',
    "subjectImg": subjectImg??'',
    "subjectLatLng": subjectLatLng??[],
    "statusList": statusList??[],
      };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;
    return UserModel(
      docId: docId,
      uId: snapshot['uId'],
      name: snapshot['name'],
      email: snapshot['email'],
      userRole: snapshot['userRole'],
      password: snapshot['password'],
      profilePhoto: snapshot['profilePhoto'],
      userPhone: snapshot['userPhone']??'userPhone',
      lineStatus: snapshot['lineStatus']??'lineStatus',
      lastActive: snapshot['lastActive']?? 0,
      addedAt: snapshot['addedAt']?? 0,
      fcmToken: snapshot['fcmToken']?? '',
      userStatus: snapshot['userStatus']?? '',

      rootId: snapshot['rootId']?? '',
      //rootName: snapshot['rootName']?? '',
      //rootLatLng: snapshot['rootLatLng']?? [],

      userRoles: snapshot['userRoles']?? [],
      subjectName: snapshot['subjectName']?? '',
      subjectImg: snapshot['subjectImg']?? '',
      subjectLatLng: snapshot['subjectLatLng']?? [],
      statusList: snapshot['statusList']?? [],
    );
  }



  static UserModel snapFromDoc(DocumentSnapshot snap) {

    return UserModel(
        uId: snap['uId']??'',
        name: snap['name']??'',
        email: snap['email']??'',
        userRole: snap['userRole']??'',
        password: snap['password']??'',
        profilePhoto: snap['profilePhoto']??'',
        userPhone: snap['userPhone']??'',
        lineStatus: snap['lineStatus']??'',
        lastActive: snap['lastActive']?? 0,
        addedAt: snap['addedAt']?? 0,
        fcmToken: snap['fcmToken']??'',
        userStatus: snap['userStatus']??'',

      rootId: snap['rootId']??'',
      //rootName: snap['rootName'],
      //rootLatLng: snap['rootLatLng'],
      userRoles: snap['userRoles']??[],
      subjectName: snap['subjectName']??'',
      subjectImg: snap['subjectImg']??'',
      subjectLatLng: snap['subjectLatLng']??[],
      statusList: snap['statusList']??[],
    );
  }


  static List<UserModel> snapFromQuery(QuerySnapshot snap) {
    return snap.docs.map((doc) => UserModel(
      uId: doc['uId']??'',
      name: doc['name']??'',
      email: doc['email']??'',
      userRole: doc['userRole']??'',
      password: doc['password']??'',
      profilePhoto: doc['profilePhoto']??'',
      userPhone: doc['userPhone']??'',
      lineStatus: doc['lineStatus']??'',
      lastActive: doc['lastActive']?? 0,
      addedAt: doc['addedAt']?? 0,
      fcmToken: doc['fcmToken']??'',
      userStatus: doc['userStatus']??'',

      rootId: doc['rootId']??'',
      //rootName: snap['rootName'],
      //rootLatLng: snap['rootLatLng'],
      userRoles: doc['userRoles']??[],
      subjectName: doc['subjectName']??'',
      subjectImg: doc['subjectImg']??'',
      subjectLatLng: doc['subjectLatLng']??[],
      statusList: doc['statusList']??[],
    )).toList();
  }

  static UserModel empty() {
    return UserModel(
      //docId: '',
      uId: '',
      name: '',
      email: '',
      userRole: '',
      password: '',
      profilePhoto: '',
      subjectImg: '',
      userPhone: '',
      lineStatus: '',
      lastActive: 0,

      rootId: '',
      //rootName: '',
      //rootLatLng: [],

      userRoles: [],
    );
  }
}
