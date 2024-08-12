import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  var fireStore = FirebaseFirestore.instance;


  Future initializeCloudMessaging(BuildContext context) async {
    //1. Terminated
    //Когда приложение полностью закрыто и открывается прямо из push-уведомления
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(remoteMessage.data["toUserId"], context);
        print('Когда приложение полностью закрыто и открывается прямо из push-уведомления');
      }

    });
    //2. Foreground
    //Когда приложение открыто и получает push-уведомление
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(remoteMessage!.data["toUserId"], context);
      print('Когда приложение открыто и получает push-уведомление');
    });
    //3. Background
    //Когда приложение находится в фоновом режиме и открывается прямо из push-уведомления.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(remoteMessage!.data["toUserId"], context);
      print('Когда приложение находится в фоновом режиме и открывается прямо из push-уведомления.');
    });

  }



  readUserRideRequestInformation(String userRideRequestId, BuildContext context) {
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("order")
    //     .child(userRideRequestId)
    //     .once()
    //     .then((snapData) {
    //   if ((snapData.snapshot.value! as Map)["orderStatus"] == 'expectation') {
    //     NotificationModel notificationModel = NotificationModel(
    //       toUserId: userRideRequestId,
    //       fromUserId: (snapData.snapshot.value! as Map)["fromUserId"],
    //       userName: (snapData.snapshot.value! as Map)["userName"],
    //       userPhoto: (snapData.snapshot.value! as Map)["userPhoto"],
    //       objectName: (snapData.snapshot.value! as Map)["objectName"],
    //       objectId: (snapData.snapshot.value! as Map)["objectId"],
    //       invoiceNumber: (snapData.snapshot.value! as Map)["invoiceNumber"],
    //       orderStatus: (snapData.snapshot.value! as Map)["orderStatus"],
    //     );
    //     showDialog(
    //       context: context,
    //       builder: (BuildContext context) =>
    //
    //           NotificationDialogBox(
    //         notificationModel: notificationModel,
    //       ),
    //     );
    //   }
    // });
  }

  Future generateAndGetToken(String userId) async {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token:::::::::::::::::::");
    print(registrationToken);

    await fireStore.collection('usersN').doc(userId).update({'fcmToken': registrationToken});

    // FirebaseDatabase.instance
    //     .ref()
    //     .child("order")
    //     .child(userId)
    //     .child("lineStatus")
    //     .set('onLine');
    //
    // FirebaseDatabase.instance
    //     .ref()
    //     .child("order")
    //     .child(userId)
    //     .child("token")
    //     .set(registrationToken);

    // messaging.subscribeToTopic("eO6z4hrAXTPbAhp057C9TDuWeWj1");
    //messaging.subscribeToTopic("allUsers");
  }
}
