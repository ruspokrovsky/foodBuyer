
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class PlaceDetailsForRootModel{

  late String? docId;
  late String userId;
  late String placeId;
  late String placeName;
  late String description;
  late String addressDescription;
  late List locationLatLng;
  late String placeImage;
  late String locationImage;
  late int addedAt;
  late num placeDiscount;
  late int successStatus;


  late UserModel? userModel;
  late List<OrderDetailsModel>? orderDetailsList;

  PlaceDetailsForRootModel(
      {
      this.docId,
      required this.userId,
      required this.placeName,
      required this.description,
      required this.addressDescription,
      required this.locationLatLng,
      required this.placeImage,
      required this.locationImage,
      required this.addedAt,
      required this.placeDiscount,
      required this.successStatus,
      this.userModel,
      this.orderDetailsList,
      });

  Map<String, dynamic> toJson() => {
    "docId": docId ?? "docId",
    "userId": userId,
    "placeName": placeName,
    "description": description,
    "addressDescription": addressDescription,
    "locationLatLng": locationLatLng,
    "placeImage": placeImage,
    "locationImage": locationImage,
    "addedAt": addedAt,
    "placeDiscount": placeDiscount,
    "successStatus": successStatus,
  };



  static PlaceDetailsForRootModel fromSnap(DocumentSnapshot snap) {

    var snapshot = snap.data() as Map;
    var docId = snap.id;

    return PlaceDetailsForRootModel(
      docId: docId,
      userId: snapshot['userId'] ?? 'userId',
      placeName: snapshot['placeName'] ?? 'placeName',
      description: snapshot['description'] ?? 'description',
      locationLatLng: snapshot['locationLatLng'] ?? [],
      placeImage: snapshot['placeImage'] ?? 'placeImage',
      locationImage: snapshot['locationImage'] ?? 'locationImage',
      addedAt: snapshot['addedAt'] ?? 0,
      placeDiscount: snapshot['placeDiscount'] ?? 0,
      successStatus: snapshot['successStatus'] ?? 0,
      addressDescription: snapshot['addressDescription'] ?? '',
    );
  }

  static empty() {
    return PlaceDetailsForRootModel(
        docId: '',
        userId: '',
        placeName: '',
        description: '',
        locationLatLng: [],
        placeImage: '',
        locationImage: '',
        addedAt: 0,
        placeDiscount: 0,
        successStatus: 0,
        addressDescription: '');
  }


}