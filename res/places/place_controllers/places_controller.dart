import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class PlacesListController extends StateNotifier<List<PlaceModel>> {
  PlacesListController() : super([]);

  clearPlacesList() {
    state.clear();
  }

  buildPlacesList(placesData,) {
    var data = placesData.docs.map((DocumentSnapshot doc)
    => PlaceModel.fromSnap(doc).toJson()).toList();

    for (var element in data) {
      state.add(PlaceModel(
          docId: element['docId'],
          userId: element['userId'],
          placeName: element['placeName'],
          description: element['description'],
          locationLatLng: element['locationLatLng'],
          placeImage: element['placeImage'],
          locationImage: element['locationImage'],
          addedAt: element['addedAt'],
          placeDiscount: element['placeDiscount'],
          successStatus: element['successStatus'],
          addressDescription: element['addressDescription'],)
      );
    }
  }

  void buildPlacesList2(DocumentSnapshot snap, List<UserModel> subscribCustomersList, List<OrderDetailsModel> placeOrderslList) {

    for (var element in subscribCustomersList) {
      if(element.uId == snap['userId']){

        state.add(PlaceModel(
          docId: snap.id,
          userId: snap['userId'],
          placeName: snap['placeName'],
          description: snap['description'],
          locationLatLng: snap['locationLatLng'],
          placeImage: snap['placeImage'],
          locationImage: snap['locationImage'],
          addedAt: snap['addedAt'],
          placeDiscount: snap['placeDiscount'],
          successStatus: snap['successStatus'],
          addressDescription: snap['addressDescription'],
          userModel: element,
          orderDetailsList: placeOrderslList.where((elem) => elem.objectId == snap.id).toList(),
        ));
      }
    }
  }


  void buildMultiplePlacesList(List<DocumentSnapshot> placesMultiData, List<UserModel> subscribCustomersList,List<OrderDetailsModel> placeOrderslList) {

    for (DocumentSnapshot snap in placesMultiData) {
      buildPlacesList2(snap, subscribCustomersList, placeOrderslList);
    }
  }


  List<PlaceModel> buildMultipleOrdersList(List<OrderDetailsModel> ordersDataList) {

    List<PlaceModel> placeList = state;
    List<OrderDetailsModel> resultList = [];

    for (PlaceModel stateElem in placeList) {

      for (OrderDetailsModel orderElem in ordersDataList) {

        if(orderElem.objectId == stateElem.docId){




          resultList.add(orderElem);

          stateElem.orderDetailsList!.add(orderElem);
        }

      }
    }

    return placeList;
  }
}