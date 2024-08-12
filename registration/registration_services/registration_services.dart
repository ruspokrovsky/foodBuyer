import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ya_bazaar/res/fb_services/fb_services.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/users/users_controllers/users_controller.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:http/http.dart' as http;

class Registration{

  final FbService fbService = FbService();

  static String  verificationId = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var firebaseStorage = FirebaseStorage.instance;
  var fireStore = FirebaseFirestore.instance;



  Future<String> registerWithEmailAndPassword({
    required String email,
    required String phone,
    required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      UserModel userModel = UserModel.empty();
      User? user = result.user;
      print('-----newUser!.uid: ${user!.uid}');

      userModel.uId = user.uid;
      userModel.rootId = user.uid;
      userModel.email = email;
      userModel.password = password;
      userModel.userPhone = phone;
      userModel.userStatus = 'customer';
      userModel.addedAt = DateTime.now().millisecondsSinceEpoch;
      DocumentReference docRef = fireStore.collection('aProjectData').doc(user.uid);
      //DocumentReference docRef = fireStore.collection('aProjectData').doc('39CRqj7ZCLQIQ25Mlo29rAGBgjz1');
      await fireStore.runTransaction((Transaction transaction) async {

        transaction.set(docRef, userModel.toJson());

      });

      return user.uid;
    } catch (e) {
      print('registerWithEmailAndPassword-error-$e');
      return 'error';
    }
  }

  Future<String> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      print('-----user!.uid');
      print(user!.uid);
      print('-----user!.uid');

      return user.uid;
    } catch (e) {
      return 'null';
    }
  }




  //--------------------------------------------------------------------

  Future<String> create2FAApplication({
    required randomPinNumber,
    required phoneNumber}) async {
    try {
      var appId = await createApplication();
      print('appId::::: $appId');
      var messageId = await sendPINMessage(appId: appId, randomPinNumber: randomPinNumber);
      print('messageId::::: $messageId');
      var pinId = await sendPIN(appId: appId, messageId: messageId, phoneNum: phoneNumber);
      print('pinId::::: $pinId');
      await verifyPIN(pinId, randomPinNumber);
      Get.snackbar('Success', 'Запрос на проверку отправлен');
      return 'success';
    } catch (error) {
      print("Error: $error");
      Get.snackbar('Error!', 'Ошибка при отправке SMS');
      throw Exception("Failed to create application: $error");
    }
  }

  Future<String> createApplication() async {
    var url = Uri.parse("https://1vqwwx.api.infobip.com/2fa/2/applications");

    var headers = {
      "Authorization": "App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var body = json.encode({
      "name": "buyerApplication",//имя вашего приложения
      "enabled": true,//приложение включено и готово к использованию
      "configuration": {
        "pinAttempts": 10,//колличество попыток
        "allowMultiplePinVerifications": true,//разрешается ли множественная верификация одного PIN-кода
        "pinTimeToLive": "15m",//Время жизни PIN-кода.
        "verifyPinLimit": "1/3s",//пользователь может запросить верификацию PIN-кода один раз за 3 секунды
        "sendPinPerApplicationLimit": "100/1d",//приложение может отправлять максимум 100 PIN-кодов в течение одного дня
        "sendPinPerPhoneNumberLimit": "10/1d"//на один номер телефона можно отправлять максимум 10 PIN-кодов в течение одного дня
      }
    });

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 201) {
      print("Application created successfully");
      Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['applicationId'];
    } else {
      throw Exception("Failed to create application: ${response.statusCode}");
    }
  }

  Future<String> sendPINMessage({required String appId, required String randomPinNumber}) async {
    var url = Uri.parse("https://1vqwwx.api.infobip.com/2fa/2/applications/$appId/messages");

    var headers = {
      "Authorization": "App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var body = json.encode({
      "pinType": "NUMERIC",
      "messageText": "Your pin is $randomPinNumber",
      "pinLength": 4,
      "senderId": "ServiceSMS"
    });

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print("PIN message sent successfully: ${response.body}");

      Map<String, dynamic> responseData = json.decode(response.body);

      return responseData['messageId'];

    } else {
      throw Exception("Failed to send PIN message: ${response.statusCode}");
    }
  }

  Future<String> sendPIN({
    required String appId,
    required String messageId,
    required String phoneNum,
  }) async {
    var url = Uri.parse("https://1vqwwx.api.infobip.com/2fa/2/pin");

    var headers = {
      "Authorization": "App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var body = json.encode({
      "applicationId": appId,
      "messageId": messageId,
      "from": "ServiceSMS",
      "to": phoneNum
    });

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print("PIN sent successfully");

      Map<String, dynamic> responseData = json.decode(response.body);

      print('responsePinData:::: $responseData');
      print('responsePinData:::: ${responseData['pinId']}');

      return responseData['pinId'];

    } else {
      throw Exception("Failed to send PIN: ${response.statusCode}");
    }
  }


  Future<void>  verifyPIN(String pinId, String pinCode) async {
    print('verifyPINpinCode::: $pinCode');
    var url = Uri.parse("https://1vqwwx.api.infobip.com/2fa/2/pin/$pinId/verify");

    var headers = {
      "Authorization": "App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c",
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

    var body = json.encode({
      "pin": pinCode
    });

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("PIN verified successfully: ${response.body}");
      } else {
        print("Failed to verify PIN: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }


  //--------------------------------------------------------------------

  // void create2FAApplication() async {
  //   var url = Uri.parse("https://1vqwwx.api.infobip.com/2fa/2/applications");
  //
  //   var headers = {
  //     "Authorization": "App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c",
  //     "Content-Type": "application/json",
  //     "Accept": "application/json"
  //   };
  //
  //   var body = json.encode({
  //     "name": "2fa test application",
  //     "enabled": true,
  //     "configuration": {
  //       "pinAttempts": 10,
  //       "allowMultiplePinVerifications": true,
  //       "pinTimeToLive": "15m",
  //       "verifyPinLimit": "1/3s",
  //       "sendPinPerApplicationLimit": "100/1d",
  //       "sendPinPerPhoneNumberLimit": "10/1d"
  //     }
  //   });
  //
  //   try {
  //     var response = await http.post(url, headers: headers, body: body);
  //     if (response.statusCode == 201) {
  //
  //       print('response.body::::::: ${response.body}');
  //       Map<String, dynamic> responseData = json.decode(response.body);
  //       print('responseData::::::: $responseData');
  //       var appId = responseData['applicationId'];
  //       print("Application created successfully. App ID: $appId");
  //     } else {
  //       print("Failed to create application: ${response.statusCode}");
  //     }
  //   } catch (error) {
  //     print("Error: $error");
  //   }
  //
  //   // try {
  //   //   var response = await http.post(url, headers: headers, body: body);
  //   //   if (response.statusCode == 200) {
  //   //     print("Application created successfully: ${response.body}");
  //   //   } else {
  //   //     print("Failed to create application: ${response.statusCode}");
  //   //   }
  //   // } catch (error) {
  //   //   print("Error: $error");
  //   // }
  // }
  //
  // void sendPINMessage() async {
  //   var appId = "A61A34FA5572FE68F04669EF0757EAA7"; // Замените на реальное значение appId
  //   var url = Uri.parse("https://1vqwwx.api.infobip.com/2fa/2/applications/$appId/messages");
  //
  //   var headers = {
  //     "Authorization": "App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c",
  //     "Content-Type": "application/json",
  //     "Accept": "application/json"
  //   };
  //
  //   var body = json.encode({
  //     "pinType": "NUMERIC",
  //     "messageText": "Your pin is ${1223}",
  //     "pinLength": 4,
  //     "senderId": "ServiceSMS"
  //   });
  //
  //   try {
  //     var response = await http.post(url, headers: headers, body: body);
  //     if (response.statusCode == 200) {
  //       print("PIN message sent successfully: ${response.body}");
  //     } else {
  //       print("Failed to send PIN message: ${response.statusCode}");
  //     }
  //   } catch (error) {
  //     print("Error: $error");
  //   }
  // }
  //
  // void sendPIN() async {
  //   var url = Uri.parse("https://1vqwwx.api.infobip.com/2fa/2/pin");
  //
  //   var headers = {
  //     "Authorization": "App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c",
  //     "Content-Type": "application/json",
  //     "Accept": "application/json"
  //   };
  //
  //   var body = json.encode({
  //     "applicationId": "A61A34FA5572FE68F04669EF0757EAA7",
  //     "messageId": "7E8D9DC13112E241A7DDA49D30DB61BB",
  //     "from": "ServiceSMS",
  //     "to": "998771367578"
  //   });
  //
  //   try {
  //     var response = await http.post(url, headers: headers, body: body);
  //     if (response.statusCode == 200) {
  //       print("PIN sent successfully: ${response.body}");
  //     } else {
  //       print("Failed to send PIN: ${response.statusCode}");
  //     }
  //   } catch (error) {
  //     print("Error: $error");
  //   }
  // }

//--------------------------------------------------------------------
  Future<String> sendSMS({
    required int randomPinNumber,
    required String phoneNumber,
  }) async {
    // URL и тело запроса
    String url = 'https://1vqwwx.api.infobip.com/2fa/2/applications';
    //String url = 'https://1vqwwx.api.infobip.com/sms/2/text/advanced';
    //String url = 'https://1vqwwx.api.infobip.com/2fa/2/applications/{appId}/messages';
    String body = '{"messages":[{"destinations":[{"to":"$phoneNumber"}],"from":"BuyerService","text":"Ваш код: $randomPinNumber"}]}';

    // Отправка POST запроса
    http.Response res = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'App 9503d93bb99e78cbe61fcf268d571bba-341fbdcc-f5f2-4822-a659-93f243693b6c',
        'Accept': 'application/json',
      },
      body: body,
    );
    // Обработка ответа
    if (res.statusCode == 200) {
      Get.snackbar('Success', 'Запрос на проверку отправлен');
      print('Ответ сервера: ${res.body}');
      return 'success';
    } else {
      Get.snackbar('Error!', 'Ошибка при отправке SMS');
      print('Код ошибки: ${res.statusCode}');
      print('Текст ошибки: ${res.body}');
      return 'error';
    }
  }






  Future<void> verifyPhoneNum(String phoneNumber) async {

    print('=========phoneNumber===$phoneNumber');

    try {

      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
            print('PhoneAuthCredential++++++++ $phoneAuthCredential');
          },
          verificationFailed: (FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              print('The provided phone number is not valid.');
            }
          },
          codeSent: (String verificationId, int? resendToken) async {

            print('verificationId++++++++ $verificationId');
            print('resendToken++++++++ $resendToken');

            Registration.verificationId = verificationId;

          },
          codeAutoRetrievalTimeout: (String verificationId) {});


    } on FirebaseAuthException catch (e) {
      print('Error++++: $e');
    } catch (e) {
      if (e == 'email-already-in-use') {
        print('Email already in use.');
      } else {
        print('Error++++: $e');
      }
    }
  }

  Future<String> signUpByPhoneNum({
  required String pinCode,
  required String userPhone,
  required List<String> usersIdList,
  }) async {
    String userId = '';
    try {
      PhoneAuthCredential phoneAuthCredential
      = PhoneAuthProvider.credential(verificationId: Registration.verificationId, smsCode: pinCode);

      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential).then((value) async {
        userId = value.user!.uid;
        UserModel userModel = UserModel.empty();

        if(!usersIdList.contains(userId)){
          DocumentReference docRef = fireStore.collection('aProjectData').doc(userId);
          userModel.uId = value.user!.uid;
          userModel.rootId = value.user!.uid;
          userModel.userPhone = userPhone;
          userModel.userStatus = 'customer';
          userModel.addedAt = DateTime.now().millisecondsSinceEpoch;

          await fireStore.runTransaction((Transaction transaction) async {

            transaction.set(docRef, userModel.toJson());

          });

          // var userModel = UserModel(
          //   uId: value.user!.uid,
          //   name: '',
          //   email: '',
          //   userRole: '',
          //   password: '',
          //   profilePhoto: '',
          //   userPhone: userPhone,
          //   lastActive: 0,
          //   lineStatus: '',
          //   userStatus: '',
          //   addedAt: DateTime.now().millisecondsSinceEpoch,
          // );



          //await fireStore.collection('projectData').doc(value.user!.uid).set(userModel.toJson());

        }

      });

    } catch (e) {
      print(e.toString());
    }

    return userId;
  }



  Future<String> signInByGoogle({
    required String pinCode,
    required String userPhone,
    required List<String> usersIdList,
  }) async {
    String userId = '';
    try {
      PhoneAuthCredential phoneAuthCredential
      = PhoneAuthProvider.credential(verificationId: Registration.verificationId, smsCode: pinCode);

      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential).then((value) async {
        userId = value.user!.uid;
        UserModel userModel = UserModel.empty();

        if(!usersIdList.contains(userId)){
          DocumentReference docRef = fireStore.collection('aProjectData').doc(userId);
          userModel.uId = value.user!.uid;
          userModel.rootId = value.user!.uid;
          userModel.userPhone = userPhone;
          userModel.userStatus = 'customer';
          userModel.addedAt = DateTime.now().millisecondsSinceEpoch;

          await fireStore.runTransaction((Transaction transaction) async {

            transaction.set(docRef, userModel.toJson());

          });

          // var userModel = UserModel(
          //   uId: value.user!.uid,
          //   name: '',
          //   email: '',
          //   userRole: '',
          //   password: '',
          //   profilePhoto: '',
          //   userPhone: userPhone,
          //   lastActive: 0,
          //   lineStatus: '',
          //   userStatus: '',
          //   addedAt: DateTime.now().millisecondsSinceEpoch,
          // );



          //await fireStore.collection('projectData').doc(value.user!.uid).set(userModel.toJson());

        }

      });

    } catch (e) {
      print(e.toString());
    }

    return userId;
  }



  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<DocumentSnapshot> getCurrentUser2(String currentUserId){
    return fireStore.collection('aProjectData').doc(currentUserId).snapshots();

  }

  Stream<DocumentSnapshot> getCurrentUser(String currentUserId){
    return fireStore.collection('usersN').doc(currentUserId).snapshots();

  }

  Stream<QuerySnapshot> getUserByPhoneNumber({
    required String phone,
  }) {
    return fireStore
        .collection("aProjectData")
        .where('userPhone', isEqualTo: phone)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserByPassword({
    required String password,
  }) {
    return fireStore
        .collection("aProjectData")
        .where('password', isEqualTo: password)
        .snapshots();
  }




  Future<void> updateUserData({required UserModel userModel, required File imageFile}) async {


    try{

      String profileImage;

      if(imageFile.existsSync()){
        profileImage = await fbService.uploadSingleImgToStorage(
            dirName1: 'usersProfileImage',
            fileName: userModel.uId,
            imageFile: imageFile,);
            userModel.profilePhoto = profileImage;
      }
      DocumentReference docRef = fireStore.collection('aProjectData').doc(userModel.uId);
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, userModel.toJson());
      });
    }
    catch(e){
      print('updateUserData-error: $e');
    }


  }

  Future<void> updateSubject({
    required UserModel userModel,
    required File imageFile}) async {


    try{

      String subjectImage;

      if(imageFile.existsSync()){
        subjectImage = await fbService.uploadSingleImgToStorage(
            dirName1: 'subjectImage',
            fileName: userModel.uId,
            imageFile: imageFile,);
            userModel.subjectImg = subjectImage;
      }
      DocumentReference docRef = fireStore.collection('aProjectData').doc(userModel.uId);
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.update(docRef, userModel.toJson());
      });
    }
    catch(e){
      print('updateUserData-error: $e');
    }


  }



  Future<void> signOutWithGoogle() async {
    // Получите экземпляр объекта GoogleSignIn
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Выход из учетной записи Google
      await googleSignIn.signOut();

      // Выход из учетной записи Firebase
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Обработайте возможные ошибки
      print("Error signing out with Google: $e");
    }
  }

  Future<void> signInWithGoogle({required WidgetRef ref}) async {
    String userId = '';
    UserModel userModel = UserModel.empty();
    // Запуск потока аутентификации
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Получить данные авторизации из запроса
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Создать новые учетные данные
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // После входа в систему верните UserCredential
    UserCredential value = await FirebaseAuth.instance.signInWithCredential(credential);
    User user = value.user!;

    // Поолучаем список существующих пользователей для проверки
    var users = ref.watch(usersProvider);
    UsersListController usersListController = ref.read(usersListProvider.notifier);
    users.whenData((value) => usersListController
      ..clearUsersList()
      ..buildUsersList(value));
    List<String> usersIdList = ref.watch(usersListProvider).map((e) => e.uId).toList();

    if(!usersIdList.contains(user.uid)){
      DocumentReference docRef = fireStore.collection('aProjectData').doc(userId);
      userModel.uId = user.uid;
      userModel.rootId = user.uid;
      userModel.name = user.displayName!;
      userModel.userPhone = user.phoneNumber??"";
      userModel.email = user.email!;
      userModel.profilePhoto = user.photoURL!;
      userModel.userStatus = 'customer';
      userModel.addedAt = DateTime.now().millisecondsSinceEpoch;

      await fireStore.runTransaction((Transaction transaction) async {
        transaction.set(docRef, userModel.toJson());
      });
    }

  }
}


