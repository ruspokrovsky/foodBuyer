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
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const String routeName = 'signUpScreen';
  final String whoScreen;

  const SignUpScreen({super.key, required this.whoScreen});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends ConsumerState<SignUpScreen> {
  Utils utils = Utils();
  Random random = Random();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController pinPutPhoneNumController = TextEditingController();
  TextEditingController pinPutOtpCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Registration dbr = Registration();
  int phoneLength = 9;
  String countryCode = '';
  String countryName = '';
  String dialCode = '';
  int otpCode = 0;

  bool isAnimContainer = false;
  bool isEmailAndPassword = false;

  int _generateRandomPinNumber() {
    // Генерируем рандомное четырехзначное число
    return 1000 + random.nextInt(9000);
  }


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

  Future<void> _getUserDataByPhoneNumber({required String phoneNumber}) async {
    var getUserByPhoneNumber = dbr.getUserByPhoneNumber(phone: phoneNumber);
    getUserByPhoneNumber.listen((QuerySnapshot snapshot) {
      // Проверяем, есть ли документы в снимке
      if (snapshot.docs.isNotEmpty) {
        // Получаем первый документ из списка документов
        var userData = snapshot.docs.first.data();
        print('-проверка на наличие номера телефона-------------------------$userData');

        UserModel userByPhone = UserModel.snapFromQuery(snapshot).first;

        if (userByPhone.userPhone == phoneNumber) {
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
          return;
        }
      } else {
        print('проверка на наличие номера телефона-----------Документы не найдены');

        String randomStr = _generateRandomString();
        String email = '$randomStr$otpCode@gmail.com';
        String password = '$randomStr$otpCode';

        dbr.registerWithEmailAndPassword(email: email, password: password, phone: phoneNumber)
            .then(
          (String currentUserId) async {
            print('-currentUserId----------------------------------------$currentUserId');
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
          },
        );
      }
    });
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

              const SizedBox(
                height: 20,
              ),

              if (isEmailAndPassword)
                Column(
                  children: [
                    EditText(
                      labelText: 'email',
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (v) {},
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    EditText(
                      labelText: 'password',
                      controller: passwordController,
                      onChanged: (v) {},
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TwoButtonsBlock(
                        positiveText: 'SignIn',
                        positiveClick: () async {
                          await dbr
                              .signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim())
                              .then((String currentUserId) async {
                            if (widget.whoScreen == 'homePage') {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const AuthChecker(),
                                  ),
                                  (Route<dynamic> route) => false);
                            } else if (widget.whoScreen == 'cartScreen') {
                              Navigator.pop(context, currentUserId);
                            }
                          });
                        },
                        negativeText: 'SignUp',
                        negativeClick: () async {
                          await dbr
                              .registerWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  phone: '')
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
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),

              Text('Пожалуйста, установите номера телефона',
                  style: styles.worningTextStyle),

              const SizedBox(
                height: 25,
              ),

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
                      autofocus: true,
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
                      onCompleted: (value) async {
                        print('pinPutPhoneNum: $value');
                        //временное ограничение номеров на периуд тестирования
                        //if (dialCode == '+1') {
                        dialCode = '+998';
                        String fullPhoneNumber = '$dialCode${pinPutPhoneNumController.text.trim()}';

                        //await dbr.sendSMS(randomPinNumber: randomPinNumber, phoneNumber: fullPhoneNumber);

                        //_getUserDataByPhoneNumber(phoneNumber: fullPhoneNumber);

                        // var users = ref.watch(usersProvider);
                        // UsersListController usersListController =
                        //     ref.read(usersListProvider.notifier);
                        // users.whenData((value) => usersListController
                        //   ..clearUsersList()
                        //   ..buildUsersList(value));
                        // List<UserModel> usersList = ref.watch(usersListProvider);
                        //
                        // for (var element in usersList) {
                        //   if(element.userPhone == fullPhoneNumber){
                        //     await dbr.signInWithEmailAndPassword(element.email, element.password);
                        //
                        //   }
                        // }
                        //
                        // if(usersPhoneList.contains(fullPhoneNumber)){
                        //
                        //   await dbr.signInWithEmailAndPassword(email, password);
                        //
                        // }
                        //
                        // else {
                        //
                        //int randomPinNumber = 0;
                        // Генерируем рандомное четырехзначное число
                        //randomPinNumber = 1000 + Random().nextInt(9000);

                        int randomPinNumber = _generateRandomPinNumber();
                        if (randomPinNumber != 0) {
                          dbr.create2FAApplication(
                                  randomPinNumber: randomPinNumber.toString(),
                                  phoneNumber: fullPhoneNumber)
                              .then((value) {
                            if (value == 'success') {

                              // setState(() {
                              //   isAnimContainer = true;
                              //   otpCode = randomPinNumber;
                              //   pinPutOtpCodeController.text = otpCode.toString();
                              // });


                              _getUserDataByPhoneNumber(
                                  phoneNumber: fullPhoneNumber);

                            } else {
                              Get.snackbar('Ошибка!', 'Попробуйте еще раз...');
                            }
                          });

                          //     .sendSMS(
                          //         randomPinNumber: randomPinNumber,
                          //         phoneNumber: fullPhoneNumber)
                          //     .then((value) {
                          //   if (value == 'success') {
                          //     setState(() {
                          //       isAnimContainer = true;
                          //       otpCode = randomPinNumber;
                          //     });
                          //   } else {
                          //     Get.snackbar('Ошибка!', 'Попробуйте еще раз...');
                          //   }
                          // });
                        }
                      }

                      // await dbr.verifyPhoneNum(fullPhoneNumber)
                      //     .whenComplete(() {
                      //   setState(() {
                      //     isAnimContainer = true;
                      //   });
                      // });

                      //}
                      // },
                      ),
                ],
              ),

              const SizedBox(
                height: 25,
              ),

              if (isAnimContainer)
                Column(
                  children: [
                    Text(
                      'Пожалуйста, установите пин-код, полученный в SMS-уведомлении.',
                      style: styles.worningTextStyle,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Pinput(
                        controller: pinPutOtpCodeController,
                        length: 4,
                        //length: 6,
                        showCursor: true,
                        autofocus: true,
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
                        onCompleted: (pinCompleted) async {
                          print('---------pinCompleted:$pinCompleted');

                          // var users = ref.watch(usersProvider);
                          // UsersListController usersListController =
                          //     ref.read(usersListProvider.notifier);
                          // users.whenData((value) => usersListController
                          //   ..clearUsersList()
                          //   ..buildUsersList(value));
                          List<String> usersIdList = ref
                              .watch(usersListProvider)
                              .map((e) => e.uId)
                              .toList();
                          // List<String> usersPhoneList = ref
                          //     .watch(usersListProvider)
                          //     .map((e) => e.userPhone)
                          //     .toList();
                          //

                          String fullPhoneNumber =
                              '$dialCode${pinPutPhoneNumController.text.trim()}';

                          if (otpCode.toString() == pinCompleted) {
                            _getUserDataByPhoneNumber(
                                phoneNumber: fullPhoneNumber);

                            // String randomString = '';
                            // // Генерируем четыре случайных символа
                            // for (int i = 0; i < 4; i++) {
                            //   // Генерируем случайный код символа ASCII в диапазоне [33, 126]
                            //   int randomNumber = 33 + Random().nextInt(94);
                            //   // Конвертируем код символа в символ и добавляем его к строке
                            //   randomString += String.fromCharCode(randomNumber);
                            // }
                            //
                            // String email = '$randomString$otpCode@gmail.com';
                            // String password = '$randomString$otpCode';
                            //
                            // await dbr
                            //     .registerWithEmailAndPassword(
                            //         email: email, password: password)
                            //     .then((value) {
                            //   if (value != 'error') {
                            //     print(value);
                            //   } else {
                            //     print('-------------error');
                            //   }
                            // });
                          }

                          // await dbr
                          //     .signUpByPhoneNum(
                          //   pinCode: pinPutOtpCodeController.text.trim(),
                          //   userPhone: fullPhoneNumber,
                          //   usersIdList: usersIdList,
                          // )
                          //     .then(
                          //   (String currentUserId) async {
                          //     if (widget.whoScreen == 'homePage') {
                          //       Navigator.of(context).pushAndRemoveUntil(
                          //           MaterialPageRoute(
                          //             builder: (context) => const AuthChecker(),
                          //           ),
                          //           (Route<dynamic> route) => false);
                          //     } else if (widget.whoScreen == 'cartScreen') {
                          //       Navigator.pop(context, currentUserId);
                          //
                          //       // Navigator.pushReplacement(
                          //       //   context,
                          //       //   MaterialPageRoute(
                          //       //     builder: (BuildContext context) =>
                          //       //     const CartScreen(objectId: ''),
                          //       //   ),
                          //       // );
                          //     }
                          //   },
                          // );
                        }),
                  ],
                )
              else
                const SizedBox.shrink(),

              //const SizedBox(height: 50,),

              // Consumer(
              //   builder: (BuildContext context, WidgetRef ref, Widget? child) {
              //     var users = ref.watch(usersProvider);
              //     UsersListController usersListController = ref.read(usersListProvider.notifier);
              //     users.whenData((value) => usersListController..clearUsersList()..buildUsersList(value));
              //     List<String> usersIdList = ref.watch(usersListProvider).map((e) => e.uId).toList();
              //     return TwoButtonsBlock(
              //         positiveClick: () async{
              //           String fullPhoneNumber = '$dialCode${pinPutPhoneNumController.text.trim()}';
              //           await dbr.verifyPhoneNum(fullPhoneNumber)
              //               .whenComplete(() =>
              //               utils.dialogBuilder(
              //               context: context,
              //               content: SizedBox(height:100,
              //                 child: Pinput(
              //                   controller: pinPutOtpCodeController,
              //                   length: 6,
              //                   showCursor: true,
              //                   autofocus: true,
              //                   defaultPinTheme: const PinTheme(
              //                     width: 18,
              //                     //height: 18,
              //                     padding: EdgeInsets.all(0.0),
              //                     textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
              //                     decoration: BoxDecoration(
              //                       border: Border(bottom: BorderSide(width: 1,)),
              //                     ),
              //                   ),
              //                   onCompleted: (value) {
              //                     print(value);
              //                   },
              //                 ),
              //               ),
              //               onPositivePressed: () async {
              //                 await dbr.signUpByPhoneNum(
              //                   pinCode: pinPutOtpCodeController.text.trim(),
              //                   userPhone: fullPhoneNumber,
              //                   usersIdList: usersIdList,
              //
              //                 ).then((String currentUserId)async{
              //
              //                   if(widget.whoScreen == 'homePage'){
              //
              //                     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              //                     const AuthChecker(),), (Route<dynamic> route) => false);
              //
              //                   }else if(widget.whoScreen == 'cartScreen'){
              //
              //                     Navigator.pushReplacement(
              //                       context,
              //                       MaterialPageRoute(
              //                         builder: (BuildContext context) => CartScreen(navigateSearchArgs: IntentRootPlaceArgs.empty()),
              //                       ),
              //                     );
              //
              //
              //                     //Navigator.pop(context, 'signUpScreen');
              //
              //                   }
              //
              //
              //
              //
              //                   // Navigator.pushReplacement(
              //                   //   context,
              //                   //   MaterialPageRoute(
              //                   //     builder: (BuildContext context) => CreatePlaceScreen(currentUserId:currentUserId),
              //                   //   ),
              //                   // );
              //
              //                 });
              //
              //               },
              //               btnPositiveText: 'btnPositiveText',
              //               contentPadding: 10));
              //
              //
              //         },
              //         negativeClick: ()=> Navigator.pop(context),
              //         negativeText: 'Отмена',
              //         positiveText: 'Отправить'
              //     );
              //   },
              // )
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
