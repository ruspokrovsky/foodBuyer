import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ya_bazaar/assistants/assistant_methods.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/push_notifications/push_notification_system.dart';
import 'package:ya_bazaar/registration/registration_providers/registration_providers.dart';
import 'package:ya_bazaar/registration/registration_services/registration_services.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/home/widgets/hero_container.dart';
import 'package:ya_bazaar/res/map/map_providers/map_providers.dart';
import 'package:ya_bazaar/res/models/direction_details_info.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/models/subscribers_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/positions/positions_services/positions_services.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/purchases/purchase_services/purchase_services.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/horizontal_%20rectangle_list.dart';
import 'package:ya_bazaar/res/widgets/local_circular_motion.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/root_home_slivers.dart';
import 'package:ya_bazaar/theme.dart';
import 'package:http/http.dart' as http;

class HomePage extends ConsumerStatefulWidget {
  static const String routeName = 'homePage';
  final UserModel currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  PositionsFBServices pFbs = PositionsFBServices();
  UsersFBServices uFbs = UsersFBServices();
  Navigation navigation = Navigation();
  Utils utils = Utils();

  //String? whichUser;
  late UserModel currentUser;

  Future<void> _getCurrentUserData(
    BuildContext context,
    String currentUserId,
  ) async {
    late Registration dbs = Registration();
    var streamUser = dbs.getCurrentUser2(currentUserId);
    streamUser.listen(
      (userData) {
        ref.read(currentUserProvider.notifier).buildCurrentUser(userData);

        // для того чтобы сотрудникам подключиться к контенту склада
        // используем rootId который является главным projectRootId

        if (ref.read(currentUserProvider).userStatus == 'owner') {
          _sortSubscribers(ref.read(currentUserProvider).rootId!);
        } else {
          _sortSubscribers(ref.read(currentUserProvider).uId);
        }
      },
    );

    //_currentPosition(ref);
    //_readFCMInformation(context, ref.watch(currentUserProvider).uId);
  }

  _readFCMInformation(BuildContext context, String uId) async {
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken(uId);
  }

  String region = "Обноружение...";

  @override
  void initState() {
    //getAllPosition();
    _getAllUsers();
    currentUser = widget.currentUser;

    if (currentUser.uId != 'guest') {
      _getCurrentUserData(context, currentUser.uId);
    } else {
      _sortSubscribers(currentUser.uId);
    }
    super.initState();
  }

  Future<void> _getAllUsers() async {
    UsersFBServices().getUsers().listen((event) async {
      ref.read(usersListProvider.notifier)
        ..clearUsersList()
        ..buildUsersList(event);
      setState(() {});
    });
  }

  Future<void> _sortSubscribers(String currentUseId) async {
//получаем всех подписчиков
    pFbs.getSubscribers(currentUseId).listen((event) {
//очищаем промежуточных массивов для сортировки
      ref.read(subscribersSortProvider.notifier).clearSubscribersSortLists();
      ref.read(subscribersSortProvider.notifier).clearSubscribCustomersSortLists();
      ref.read(subscribersSortProvider.notifier).clearSubscribOwnerSortLists();
      ref.read(subscribersListProvider.notifier)
        ..clearSubscribersList()
//формируем список подписчиков
        ..buildSubscribersList(event)
//формируем 2 списка пользователей подписанные и не подписанные
        ..buildSubscribAndNotSubscrib(ref,)
//формируем список закзчиков
        ..buildCustomerSubscribers(ref,)
//формируем список подписанных поставщиков
        ..buildOwnerSubscribers(ref,);

      _createMultiPositionsList(ref.read(subscribersSortProvider));

      //_getOnlyOwner(ref.read(subscribersSortProvider));

      setState(() {});
    });
  }

//метод создает список, по 1 позиции  от каждого не подписанного пользователя
  Future<void> _createMultiPositionsList(
      SubscribersSortModel subscribersSortModel) async {
    await pFbs.fetchMultiplePosition(projectRootIdList: subscribersSortModel.notSubscribersIdList)
        .then((value) async {
      ref.read(notSubscribPositionsListProvider.notifier)
        ..clearPositions()
        ..buildMultiplePositionList(value, subscribersSortModel.notSubscribersList);
    });
    setState(() {});
  }

  _getOnlyOwner(SubscribersSortModel subscribersSortModel) async {
    UserModel onlyOwner = subscribersSortModel.notSubscribersList.firstWhere(
        (elem) => elem.uId == 'GLtxID9s8MUtdzeprpNZaktmodV2',
        orElse: () => UserModel.empty());

    if (onlyOwner.uId.isNotEmpty) {
      var stream = pFbs.getOnlyOwnerPositions(ownerId: onlyOwner.uId);
      stream.listen((event) async {
        ref.read(onlyOwnerPositionsListProvider.notifier)
          ..clearPositions()
          ..buildOnlyOwnerPositionList([event], [onlyOwner]);
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return BaseLayout(
      onWillPop: () {
        return Future.value(true);
      },
      isAppBar: true,
      titleContainer: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          bool themeStatus;
          bool languageStatus;
          bool userStatus;
          var currentThemeMode = AdaptiveTheme.of(context).mode;
          var currentUser = ref.watch(currentUserProvider);

          if (context.locale == const Locale('ru')) {
            languageStatus = true;
          } else {
            languageStatus = false;
          }

          if (currentThemeMode == AdaptiveThemeMode.light) {
            themeStatus = true;
          } else {
            themeStatus = false;
          }

          if (currentUser.userStatus == 'customer') {
            userStatus = true;
          } else {
            userStatus = false;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () async {
                  if (ref.watch(currentUserProvider).uId != 'guest') {
                    if (ref.watch(currentUserProvider).userStatus == 'owner') {
                      navigation.navigateToOwnerSearchScreen(
                        context,
                        IntentRootPlaceArgs(
                            fromWhichScreen: 'placesScreen',
                            rootUserModel: ref.watch(currentUserProvider),
                            placeModel: PlaceModel.empty()),
                      );
                    } else if (ref.watch(currentUserProvider).userStatus == 'customer') {
                      navigation.navigationToPlacesScreen(
                          context, IntentArguments.empty());
                    }
                  } else {
                    navigation.navigationToSignScreen(context, 'homePage');
                    //await Registration().signInWithGoogle(ref: ref);
                  }
                },
                icon: const Icon(
                  Icons.person_2,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (ref.watch(currentUserProvider).uId != 'guest') {
                    if (ref.watch(currentUserProvider).userStatus == 'owner') {
                      navigation.navigationToRootPlacesScreen(
                          context, IntentArguments.empty());
                    } else if (ref.watch(currentUserProvider).userStatus == 'customer') {
                      navigation.navigateToSearchScreen(
                        context,
                        IntentRootPlaceArgs(
                            fromWhichScreen: 'placesScreen',
                            rootUserModel: UserModel.empty(),
                            placeModel: PlaceModel.empty()),
                      );
                    }
                  } else {
                    navigation.navigationToSignScreen(context, 'homePage');
                    //await Registration().signInWithGoogle(ref: ref);
                  }
                },
                icon: const Icon(
                  Icons.search,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  Utils().bottomSheetBuilder(
                    context: context,
                    languageStatus: languageStatus,
                    themeStatus: themeStatus,
                    userStatus: userStatus,
                    onLanguageToggle: (bool value) {
                      languageStatus = value;
                      if (value) {
                        context.setLocale(const Locale('ru'));
                      } else {
                        context.setLocale(const Locale('uz'));
                      }
                      ref
                          .read(appLocaleProvider.notifier)
                          .buildLocale(ref, context.locale);

                      print('locale::: ${context.locale}');
                      print('cancel::: ${ref.ln('cancel')}');
                      print('appLocaleProvider::: ${ref.watch(appLocaleProvider)['cancel']}');

                      setState(() {});
                    },
                    onDarkLightToggle: (bool value) {
                      themeStatus = value;
                      if (themeStatus) {
                        AdaptiveTheme.of(context).setLight();
                      } else {
                        AdaptiveTheme.of(context).setDark();
                      }
                      setState(() {});
                      Navigator.pop(context);
                    },
                    onStatusToggle: (bool value) {
                      userStatus = value;
                      // ref.read(progressBoolProvider.notifier).updateProgressBool(true);
                      // if (userStatus) {
                      //   uFbs.updateUserStatus(
                      //       userId: currentUser.uId,
                      //       userStatus: 'customer').then((value){
                      //         ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                      //   } ).then((value) => Navigator.pop(context));
                      // } else {
                      //   uFbs.updateUserStatus(
                      //       userId: currentUser.uId,
                      //       userStatus: 'owner').then((value){
                      //     ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                      //   } ).then((value) => Navigator.pop(context));
                      // }
                      setState(() {});
                    },
                    exitTap: () {
                      //print('------=========--------');
                      Registration().signOut();
                      SystemNavigator.pop();
                    },
                    onTapCodeScaner: () {
                      UserModel userData = ref.watch(currentUserProvider);
                      userData.fromWhichScreen = 'homePage';
                      Navigation().navigationToQrScanerScreen(
                          context, userData);
                    },
                    onTapSignOut: () {

                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            insetPadding: EdgeInsets.zero,
                            actionsPadding: EdgeInsets.zero,
                            contentPadding: const EdgeInsets.all(8.0),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                            title: const Text('Выход из приложения...'),
                            content: Text(
                              'Следует учесть, что, при входе в приложение потребуется авторизация... ',
                              style: styles.worningTextStyle,
                            ),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: Theme.of(context).textTheme.labelLarge,
                                ),
                                onPressed: () {
                                  //Registration().signOutWithGoogle();
                                  ref.watch(authenticationProvider).signOut();
                                  SystemNavigator.pop();
                                },
                                child: const Text('Выход'),
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


                  },
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () async {
                  SystemNavigator.pop();
                },
                icon: const Icon(
                  Icons.sensor_door_outlined,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
            ],
          );
        },
      ),
      isBottomNav: false,
      isFloatingContainer: false,
      flexibleContainerChild: ListView(
        //padding: const EdgeInsets.only(top: 42),
        children: [
          if (usersListForRectangle(ref).isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Text(
                'С началом взаимодействия с пользователями здесь будет отоброжаться список Ваших подписок.',
                textAlign: TextAlign.center,
                style: styles.worningTextStyle,
              ),
            ),
          _rectangleHorizontalList(
            context: context,
            rootUsersList: usersListForRectangle(ref),
            //ref.watch(subscribersSortProvider).subscribOwnerList,
            onTapElement: (UserModel projectRootUser, int index) {
              if (ref.watch(currentUserProvider).userStatus == 'owner') {
                usersListForRectangle(ref).forEach((element) {
                  if (element.uId == projectRootUser.uId) {
                    projectRootUser.isSelectedElement = true;
                  } else {
                    element.isSelectedElement = false;
                  }
                });

                navigation.navigationToRootPlacesScreen(
                    context, IntentArguments(customerId: projectRootUser.uId));
              } else {
                print(
                    'user из rectangleHorizontalList: ${projectRootUser.limit}');
                navigation.navigateToSearchScreen(
                    context,
                    IntentRootPlaceArgs(
                        fromWhichScreen: 'homePage',
                        rootUserModel: projectRootUser,
                        placeModel: PlaceModel.empty()));
              }
            },
            onTapFilter: () {},
            //onDoubleTapElement: (elementId, elementName) {},
            region: region,
            argumentsIdList: [],
          ),

        ],
      ),
      flexibleSpaceBarTitle: const SizedBox.shrink(),
      slivers: [
        if (ref.watch(currentUserProvider).userStatus == 'owner')
          RootHomeSlivers(
              onTapToRootPlace: () {
            navigation.navigationToRootPlacesScreen(
                context, IntentArguments.empty());
          },
              onTapToRootUsers: () {
            if (ref.watch(currentUserProvider).userRoles!.contains('admin')){
              navigation.navigationToRootUsersScreen(context, ref.watch(currentUserProvider));
            } else {
              Get.snackbar('У Вас нет доступа','У Вас нет доступа');
            }

          },
              onTapToUnitedPosition: () {

            navigation.navigateToUnitedPositionScreen(context);

          },
              onTapToOwnerSearch: () {

            if (ref.watch(currentUserProvider).userRoles!.contains('admin')){
              navigation.navigateToOwnerSearchScreen(
                context,
                IntentRootPlaceArgs(
                    fromWhichScreen: 'placesScreen',
                    rootUserModel: ref.watch(currentUserProvider),
                    placeModel: PlaceModel.empty()),
              );
            }
            else {
              Get.snackbar('У Вас нет доступа','У Вас нет доступа');
            }

          },
              onTapToPurchaseList: () {
            navigation.navigateToPurchaseListScreen(context);
          },
              onTapToStatistics: () async {})
        else

          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),

                  ),
                  child: Text(
                    'Данное приложение разработано для оптимизации процессов снабжения объектов общественного питания.',
                    style: styles.worningTextStyle,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),

                  ),
                  child: Text(
                    'В контексте приложения предусматриваются закупка товаров на местных рынках по факту заказа, их доставка и отчетность.',
                    style: styles.worningTextStyle,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),

                  ),
                  child: Text(
                    'Интерфейс приложения позволяет быстро оформлять заказы, отслеживать статус заказа, использовать предыдущие заказы в качестве шаблонов, оперативно принимать товары по позициям или все сразу, отказываться от позиций с указанием причины, а также выгружать данные в виде документа или файла.',
                    style: styles.worningTextStyle,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),

                  ),
                  child: Text(
                    'Разработчики продолжают улучшать приложение, внимательно отслеживая работу всех методов и оперативно реагируя на ваши пожелания и замечания, внося необходимые корректировки.',
                    style: styles.worningTextStyle,
                  ),
                ),
              ],
            ),

          ),

        _allDataView2(
            context: context,
            userDataList: ref.watch(subscribersSortProvider).notSubscribersList)


          // _allDataView(
          //   context: context,
          //   currentPositionList: ref.watch(notSubscribPositionsListProvider),
          //   ref: ref,
          //   query: '',
          //   onTapPosition: (UserModel userData) async {
          //     print('user из allDataView: ${userData.limit}');
          //     navigation.navigateToSearchScreen(
          //         context,
          //         IntentRootPlaceArgs(
          //             fromWhichScreen: 'homePage',
          //             rootUserModel: userData,
          //             placeModel: PlaceModel.empty()));
          //   },
          //   onLongPressPosition: (PositionModel currentPositionData) {
          //     // Navigation().navigationToCreatePositionScreeen(
          //     //     context, currentPositionData);
          //   },
          // ),
      ],
      isProgress: ref.watch(progressBoolProvider),
      expandedHeight: 116.0,
      //collapsedHeight: 10.0,
      radiusCircular: 0.0,
      isPinned: false,
      isFloating: true,
    );
  }
}

List<UserModel> usersListForRectangle(WidgetRef ref) {
  List<UserModel> data = [];
  UserModel userModel = ref.watch(currentUserProvider);
  String userStatus = userModel.userStatus.toString();
  if (userStatus == 'owner') {
    data = ref.watch(subscribersSortProvider).subscribCustomersList;
  } else if (userStatus == 'customer') {
    data = ref.watch(subscribersSortProvider).subscribOwnerList.map((e) {
      e.name = e.subjectName!;
      e.profilePhoto = e.subjectImg!;
      return e;
    }).toList();
  }

  return data;
}

Widget _allDataView2({
  required BuildContext context,
  required List<UserModel> userDataList
}) {
  List<UserModel> usersDataList = [];

  usersDataList = userDataList.where((element) => element.statusList!.contains('bazaar')).toList();
  var size = MediaQuery.of(context).size;
  final double itemHeight = size.height / 5.5;
  final double itemWidth = size.width / 2;

  AppStyles styles = AppStyles.appStyle(context);

  return SliverPadding(
    padding: const EdgeInsets.all(5.0),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: (itemWidth / itemHeight)),
      delegate: SliverChildBuilderDelegate(
        childCount: usersDataList.length,
            (BuildContext context, int index) {

          return GestureDetector(
            onTap: () {},
            onLongPress: () {},
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: styles.positionBoxDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: HeroContainer(
                      width: double.infinity,
                      height: double.infinity,
                      boxFit: BoxFit.cover,
                      borderRadius: 12.0,
                      heroTag: usersDataList[index].uId,
                      imgPatch: usersDataList[index].profilePhoto,
                    ),
                  ),
                  // Text(
                  //   userDataList[index].subjectName!,
                  //   textAlign: TextAlign.center,
                  //   style: Theme.of(context).textTheme.bodyLarge,
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget _allDataView({
  required BuildContext context,
  required String query,
  required WidgetRef ref,
  required Function onTapPosition,
  required Function onLongPressPosition,
  //required List<UserModel> userDataList,
  required List<PositionModel> currentPositionList,
}) {
  //List<PositionModel> positionsList = [];
  var size = MediaQuery.of(context).size;
  final double itemHeight = size.height / 2.8;
  final double itemWidth = size.width / 2;

  AppStyles styles = AppStyles.appStyle(context);


  return SliverPadding(
    padding: const EdgeInsets.all(5.0),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: (itemWidth / itemHeight)),
      delegate: SliverChildBuilderDelegate(
        childCount: currentPositionList.length,
        (BuildContext context, int index) {
          Widget rootItem() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                    child: CachedNetworkImg(
                        imageUrl:
                            currentPositionList[index].userModel!.profilePhoto,
                        width: 25.0,
                        height: 25.0,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(
                    width: 3.0,
                  ),
                  Text(currentPositionList[index].userModel!.subjectName!)
                ],
              ),
            );
          }

          return GestureDetector(
            onTap: () => onTapPosition(currentPositionList[index].userModel),
            onLongPress: () => onLongPressPosition(currentPositionList[index]),
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: styles.positionBoxDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  rootItem(),
                  Expanded(
                    child: HeroContainer(
                      width: double.infinity,
                      height: double.infinity,
                      boxFit: BoxFit.cover,
                      borderRadius: 12.0,
                      heroTag: currentPositionList[index].productName,
                      imgPatch: currentPositionList[index].productImage,
                    ),
                  ),
                  Text(
                    currentPositionList[index].productName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'UZS: ',
                              data: Utils().numberParse(
                                  value:
                                      currentPositionList[index].productPrice),
                              postTitle: '')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Обновлено: ',
                              data: Utils().dateParse(
                                  milliseconds:
                                      currentPositionList[index].addedAt),
                              postTitle: '')),
                      if (currentPositionList[index].isSelected!)
                        Center(
                          child: Chip(
                            backgroundColor: Colors.deepOrange,
                            label: Text(
                              'Добавлено',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            //avatar: Icon(Icons.shopping_cart_outlined),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget _rectangleHorizontalList({
  required BuildContext context,
  required List<UserModel> rootUsersList,
  required Function onTapElement,
  Function? onDoubleTapElement,
  required VoidCallback onTapFilter,
  required List<dynamic> argumentsIdList,
  required String region,
}) {
  return RectangleHorizontalList(
    rootUsersList: rootUsersList,
    isSubContent: false,
    height: 156,
    onTapElement: (UserModel userByIndex, int index) =>
        onTapElement(userByIndex, index),
    onDoubleTapElement: (elementId, elementName) =>
        onDoubleTapElement!(elementId, elementName),
    selectedIndex: -1,
  );
}

Future<List<String>> _currentAddress(WidgetRef ref) async {
  List<String> addressList = [];
  return await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          ref.watch(centerPositionProvider), ref.watch(centerPositionProvider))
      .then((DirectionDetailsInfo? directionDetailsInfo) {
    addressList = directionDetailsInfo!.region.toString().split(',').toList();

    String country = addressList.last;
    String country2 = directionDetailsInfo.country!;
    String sity = addressList[addressList.length - 2];
    String sity2 = directionDetailsInfo.city!;
    String countryCode = directionDetailsInfo.countryCode!;
    ref.read(strCenterPositionProvider.notifier).state =
        '$country $sity $countryCode';
    return addressList;
  });
}

void exitApp() {
  const platform = MethodChannel('exit_app');
  platform.invokeMethod('exit');
}


Future<LocationData>? _currentPosition(WidgetRef ref) async {
  LocationData? currentLocation;
  Location location = Location();

  location.getLocation().then((location) {
    ref.read(centerPositionProvider.notifier).state =
        LatLng(location.latitude!, location.longitude!);
  });

  location.onLocationChanged.listen((newLoc) {
    currentLocation = newLoc;
    // ref.read(centerPositionProvider.notifier).state = LatLng(newLoc.latitude!, newLoc.longitude!);
    _currentAddress(ref);
  });

  return currentLocation!;
}
