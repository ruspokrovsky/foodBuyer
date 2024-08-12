import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:ya_bazaar/auth_checker.dart';
import 'package:ya_bazaar/registration/registration_services/registration_services.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class SignScreen extends ConsumerStatefulWidget {
  static const String routeName = 'signScreen';
  final String whoScreen;

  const SignScreen({super.key, required this.whoScreen});

  @override
  SignScreenState createState() => SignScreenState();
}

class SignScreenState extends ConsumerState<SignScreen> {
  Utils utils = Utils();
  Random random = Random();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController pinPutPhoneNumController = TextEditingController();
  TextEditingController pinPutOtpCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordCheckController = TextEditingController();
  Registration dbr = Registration();
  int phoneLength = 9;
  String countryCode = '';
  String countryName = '';
  String dialCode = '';
  int otpCode = 0;

  bool isAnimContainer = false;
  bool isEmailAndPassword = false;
  bool isWhoSign = false;
  String whoSignStr = '';

  String _generateRandomString() {
    const String allowedChars
    = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-';
    String randomString = '';

    // Генерируем восемь случайных символов
    for (int i = 0; i < 8; i++) {
      int randomIndex = random.nextInt(allowedChars.length);
      randomString += allowedChars[randomIndex];
    }
    return randomString;
  }

  Future<void> _getUserDataByPassword({
    required String password}) async {
    var getUserByPhoneNumber = dbr.getUserByPassword(password: password);
    getUserByPhoneNumber.listen((QuerySnapshot snapshot) {
      // Проверяем, есть ли документы в снимке
      if (snapshot.docs.isNotEmpty) {
        // Получаем первый документ из списка документов
        var userData = snapshot.docs.first.data();
        print('-проверка на наличие пароля-------------------------$userData');

        UserModel userByPhone = UserModel.snapFromQuery(snapshot).first;

        if (userByPhone.password == password) {
          dbr.signInWithEmailAndPassword(email: userByPhone.email, password: userByPhone.password)
              .then(
            (String currentUserId) async {
              if (widget.whoScreen == 'homePage') {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const AuthChecker(),
                    ),
                    (Route<dynamic> route) => false);
              } else if (widget.whoScreen == 'cartScreen') {
                Navigator.pop(context, currentUserId);
              }
            },
          );
        } else {
          Get.snackbar('Пароль не найден', 'Пароль не найден');
          return;
        }
      } else {
        Get.snackbar('Пароль не найден', 'Пароль не найден');
        return;
      }
    });
  }


  Future<void> _registerNewUser({
    required String password,
    required String phoneNumber,
  }) async {

    String randomStr = _generateRandomString();
    String email = '${randomStr}FBuyer@gmail.com';

    dbr.registerWithEmailAndPassword(email: email, password: password, phone: phoneNumber)
        .then((String currentUserId) async {
        print('-currentUserId----------------------------------------$currentUserId');
        if(currentUserId.isNotEmpty){
          if (widget.whoScreen == 'homePage') {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AuthChecker(),
                ),
                    (Route<dynamic> route) => false);
          } else if (widget.whoScreen == 'cartScreen') {
            print('-cartScreen----------------------------------------$currentUserId');
            Navigator.pop(context, currentUserId);
          }
          Get.snackbar('Регистрация прошла успешно!', 'Регистрация прошла успешно!');
        }
        else {
          Get.snackbar('Ошибка регистрации!', 'Ошибка регистрации!');
        }
      },
    );
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      //checkNotificationPermission();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isEmailAndPassword = !isEmailAndPassword;
                });
              },
              icon: const Icon(
                Icons.alternate_email,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CachedNetworkImg(
                  imageUrl: '', width: 150, height: 150, fit: BoxFit.cover),

              const SizedBox(height: 20,),
              if(!isWhoSign)// вход
              Column(
                children: [
                  EditText(
                    labelText: 'Пароль',
                    controller: passwordController,
                    textInputType: TextInputType.emailAddress,
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 20,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SingleButton(title: 'Вход', onPressed: (){

                            if(passwordController.text.trim().isNotEmpty){
                              _getUserDataByPassword(
                                  password: passwordController.text.trim());
                            }
                            else {
                              Get.snackbar('Введите пароль!', 'Введите пароль!');
                            }


                          }),
                        ),

                        Expanded(
                            flex: 2,
                            child: TextButton(
                                child: Text('Регистрация',style: Theme.of(context).textTheme.bodySmall),
                                onPressed: (){
                                  setState(() {isWhoSign = true;});
                                },
                                ))]),
                ],
              ),
              if(isWhoSign)// регистрация
              Column(
                    children: [
                      Row(
                        children: [
                          CountryCodePicker(
                            padding: EdgeInsets.zero,
                            textStyle: styles.addToCartPriceStyle,
                            searchStyle: styles.addToCartPriceStyle,
                            onChanged: (CountryCode value) {
                              countryName = value.name.toString();
                              countryCode = value.code.toString();
                              dialCode = value.dialCode.toString();

                              if (dialCode == '+1') {
                                phoneLength = 10;
                              } else {
                                phoneLength = 9;
                              }
                              setState(() {});
                            },
                            // Первоначальный выбор и избранное могут быть одним из кода («IT») ИЛИ кода_набора («+39»)
                            initialSelection: 'UZ',
                            favorite: const ['+998', 'UZ'],
                            // необязательный. Показывает только название страны и флаг
                            showCountryOnly: false,
                            // необязательный. Когда всплывающее окно закрыто, показывает только название страны и флаг.
                            showOnlyCountryWhenClosed: false,
                            // необязательный. выравнивает флаг и текст по левому краю
                            //alignLeft: false,
                            //backgroundColor: styles.flexBackgroundColor,
                            dialogBackgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                          ),
                          Pinput(
                              controller: pinPutPhoneNumController,
                              length: phoneLength,
                              showCursor: true,
                              autofocus: false,
                              defaultPinTheme: PinTheme(
                                width: 18,
                                //height: 18,
                                padding: const EdgeInsets.all(0.0),
                                textStyle: styles.addToCartPriceStyle,
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: styles.sideColor!)),
                                ),
                              ),
                              //onCompleted: (value) async {}
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      EditText(
                        labelText: 'Пароль (не менее 8 символов)',
                        controller: passwordController,
                        textInputType: TextInputType.emailAddress,
                        onChanged: (v) {},
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      EditText(
                        labelText: 'Подтвердите пароль',
                        controller: passwordCheckController,
                        textInputType: TextInputType.emailAddress,
                        onChanged: (v) {},
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Expanded(
                              flex: 3,
                              child: SingleButton(
                                  title: 'Регистрация',
                                  onPressed: (){

                                    String fullPhoneNumber = '+998${pinPutPhoneNumController.text.trim()}';
                                    String passwordStr = passwordCheckController.text.trim();

                                    print('fullPhoneNumber: $fullPhoneNumber');
                                    print('passwordStr: $passwordStr');
                                    print('passwordStr.length: ${passwordStr.length}');

                                    if(fullPhoneNumber.isNotEmpty){
                                      if(passwordStr.length >= 8){
                                        if(passwordCheckController.text.trim() ==  passwordController.text.trim()){

                                          _registerNewUser(
                                              password: passwordController.text.trim(),
                                              phoneNumber: fullPhoneNumber);
                                        }
                                        else {

                                          Get.snackbar('Не верное подтверждение пароля', 'Не верное подтверждение пароля');

                                        }
                                      }
                                      else {

                                        Get.snackbar('Пароль менее 8 символов', 'Пароль менее 8 символов');

                                      }

                                    }
                                    else {

                                      Get.snackbar('Номер телефона не установлен!', 'Номер телефона не установлен!');

                                    }






                              }),
                            ),

                            Expanded(
                                flex: 2,
                                child: TextButton(
                                  child: Text('Вход',style: Theme.of(context).textTheme.bodySmall),
                                  onPressed: (){
                                    setState(() {isWhoSign = false;});
                                  },
                                ))]),
                    ]
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      print('Разрешение на уведомления уже предоставлено.');
    } else {
      await _exDiscountDialog(onTap: () async {
        await openAppSettings().then((value) => Navigator.pop(context));
      }).then((value) => Navigator.pop(context));
      print('Разрешение на уведомления еще не предоставлено.');
    }
  }

  Future<void> _exDiscountDialog({
    required VoidCallback onTap,
  }) async {
    String percentValue = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(8.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text('Уведомдения отключены'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: onTap,
              child: const Text('Перейти к настройкам'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Отменить'),
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

Future openAppSettings() async {
  //AppSettings.openAppSettings();
  //AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
  return AppSettings.openAppSettings(type: AppSettingsType.settings);
}
