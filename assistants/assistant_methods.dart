import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ya_bazaar/assistants/request_assistant.dart';
import 'package:ya_bazaar/global/map_key.dart';
import 'package:ya_bazaar/res/models/direction_details_info.dart';
import 'package:ya_bazaar/res/models/directions.dart';

class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.")
    {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      //Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  // static void readCurrentOnlineUserInfo() async
  // {
  //   currentFirebaseUser = fAuth.currentUser;
  //
  //   DatabaseReference userRef = FirebaseDatabase.instance
  //       .ref()
  //       .child("users")
  //       .child(currentFirebaseUser!.uid);
  //
  //   userRef.once().then((snap)
  //   {
  //     if(snap.snapshot.value != null)
  //     {
  //       userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
  //     }
  //   });
  // }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(
      LatLng origionPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    String urlOriginToDestinationDirectionDetails2 = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${origionPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);
    var responseDirectionApi2 = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails2);

    print('responseDirectionApi: $responseDirectionApi');

    if(responseDirectionApi == "Error Occurred, Failed. No Response.")
    {
      return null;
    }



    // print(responseDirectionApi2["results"][0]["address_components"][2]["long_name"]);
    // print(responseDirectionApi2["results"][0]["address_components"][4]["long_name"]);
    // print(responseDirectionApi2["results"][0]["address_components"][4]["short_name"]);

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();




    //directionDetailsInfo.countryCode = responseDirectionApi2["results"][0]["address_components"][4]["short_name"];
    //directionDetailsInfo.country = responseDirectionApi2["results"][0]["address_components"][4]["long_name"];
    //directionDetailsInfo.city = responseDirectionApi2["results"][0]["address_components"][2]["long_name"];

    directionDetailsInfo.region = responseDirectionApi["routes"][0]["legs"][0]["start_address"];
    directionDetailsInfo.ePoints = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distanceText = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distanceValue = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.durationText = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.durationValue = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {
    // Время путешествия Сумма тарифа в минуту
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.durationValue! / 60) * 0.1;
    //Сумма пройденного расстояния в километрах
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.durationValue! / 1000) * 0.1;

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  // static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context) async
  // {
  //   String destinationAddress = userDropOffAddress;
  //
  //   Map<String, String> headerNotification =
  //   {
  //     'Content-Type': 'application/json',
  //     'Authorization': cloudMessagingServerToken,
  //   };
  //
  //   Map bodyNotification =
  //   {
  //     "body":"Destination Address: \n$destinationAddress.",
  //     "title":"New Trip Request"
  //   };
  //
  //   Map dataMap =
  //   {
  //     "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //     "id": "1",
  //     "status": "done",
  //     "rideRequestId": userRideRequestId
  //   };
  //
  //   Map officialNotificationFormat =
  //   {
  //     "notification": bodyNotification,
  //     "data": dataMap,
  //     "priority": "high",
  //     "to": deviceRegistrationToken,
  //   };
  //
  //   var responseNotification = http.post(
  //     Uri.parse("https://fcm.googleapis.com/fcm/send"),
  //     headers: headerNotification,
  //     body: jsonEncode(officialNotificationFormat),
  //   );
  // }

  //retrieve the trips KEYS for online user
  //trip key = ride request key
  // static void readTripsKeysForOnlineUser(context)
  // {
  //   FirebaseDatabase.instance.ref()
  //       .child("All Ride Requests")
  //       .orderByChild("userName")
  //       .equalTo(userModelCurrentInfo!.name)
  //       .once()
  //       .then((snap)
  //   {
  //     if(snap.snapshot.value != null)
  //     {
  //       Map keysTripsId = snap.snapshot.value as Map;
  //
  //       //count total number trips and share it with Provider
  //       int overAllTripsCounter = keysTripsId.length;
  //       Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);
  //
  //       //share trips keys with Provider
  //       List<String> tripsKeysList = [];
  //       keysTripsId.forEach((key, value)
  //       {
  //         tripsKeysList.add(key);
  //       });
  //       Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);
  //
  //       //получить данные ключей поездок - прочитать полную информацию о поездках
  //       readTripsHistoryInformation(context);
  //     }
  //   });
  // }

  // static void readTripsHistoryInformation(context)
  // {
  //   var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;
  //
  //   for(String eachKey in tripsAllKeys)
  //   {
  //     FirebaseDatabase.instance.ref()
  //         .child("All Ride Requests")
  //         .child(eachKey)
  //         .once()
  //         .then((snap)
  //     {
  //       var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);
  //
  //       if((snap.snapshot.value as Map)["status"] == "ended")
  //       {
  //         //update-add each history to OverAllTrips History Data List
  //         Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
  //       }
  //     });
  //   }
  // }
}