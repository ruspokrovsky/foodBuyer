import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tuple/tuple.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/map/map_providers/map_providers.dart';
import 'package:ya_bazaar/res/models/event_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/places/place_providers/place_providers.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/chip_btn.dart';
import 'package:ya_bazaar/res/widgets/horizontal_%20rectangle_list.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class RootPlacesScreen extends ConsumerStatefulWidget {
  static const String routeName = "rootPlacesScreen";

  final IntentArguments arguments;

  const RootPlacesScreen({super.key, required this.arguments});

  @override
  RootPlacesScreenState createState() => RootPlacesScreenState();
}

class RootPlacesScreenState extends ConsumerState<RootPlacesScreen> {
  Navigation navigation = Navigation();
  String? fromWhichScreen;
  String? currentRootId;
  String _customerId = '';
  bool isMiniPrgress = false;
  List<String> userIdFromOrderList = [];

  late PlaceParametersForRoot parametersForRoot;
  late Map<String, List<String>> argumentsForPlace = {};

  //-------------------------------------------------------------------------

  DateTime _today = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedIndex;
  int? _selectedMilliseconds;

  void _onDaySelected(DateTime day, DateTime focusDay) {
    for (var element
        in ref.watch(subscribersSortProvider).subscribCustomersList) {
      if (element.isSelectedElement!) {
        element.isSelectedElement = false;
      }
    }
    setState(() {
      _today = day;
      _selectedDay = day;
      _customerId = '';
      _selectedIndex = -1;
    });
  }

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final Map<DateTime, List<Event>> _kEventSource = {};

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return _kEventSource[day] ?? [];
  }

  //-------------------------------------------------------------------------

  final StreamController<List<DocumentSnapshot>> _placesStreamController =
      StreamController<List<DocumentSnapshot>>();

  @override
  void dispose() {
    _placesStreamController.close();
    super.dispose();
  }

  //-------------------------------------------------------------------------

  @override
  void initState() {
    fromWhichScreen = widget.arguments.fromWhichScreen;
    currentRootId = widget.arguments.currentRootId;
    _customerId = widget.arguments.customerId ?? '';

    parametersForRoot = PlaceParametersForRoot(
        currentRootId: ref.read(currentUserProvider).rootId!,
        customersIdList:
            ref.read(subscribersSortProvider).subscribCustomersIdList);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {

        List<UserModel> actualUserList = [];
        bool snapshotConnectionState = false;

        List<UserModel> subscribCustomersList =
            ref.watch(subscribersSortProvider).subscribCustomersList;
        Map<String, List<String>> argumentsMap = {};
        List<PlaceModel> placeModelList = [];
        Tuple2 tuple2ForOrders = const Tuple2('', '');

        return ref.watch(getPlaceArgumentsProvider(parametersForRoot)).when(
            data: (data) {
              argumentsMap = data;

              tuple2ForOrders = Tuple2<String, Map<String, List<String>>>(
                  ref.watch(currentUserProvider).rootId!, argumentsMap);

              return BaseLayout(
                onWillPop: () {
                  return Future.value(true);
                },
                isAppBar: true,
                isBottomNav: false,
                isFloatingContainer: true,
                avatarUrl: ref.watch(currentUserProvider).profilePhoto,
                appBarTitle: ref.watch(currentUserProvider).name,
                appBarSubTitle: 'Снабжение',
                actions: [
                  PopupMenuButton<int>(
                      onSelected: (int itemIndex) {
                        if (itemIndex == 0) {
                          navigation.navigateToUnitedPositionScreen(context);
                        } else if (itemIndex == 1) {
                          navigation.navigateToPurchaseListScreen(context);
                        } else if (itemIndex == 2) {
                          navigation.navigateToOwnerSearchScreen(
                            context,
                            IntentRootPlaceArgs(
                                fromWhichScreen: 'placesScreen',
                                rootUserModel: ref.watch(currentUserProvider),
                                placeModel: PlaceModel.empty()),
                          );
                        } else if (itemIndex == 3) {
                          UserModel rootUserModel = UserModel.empty();
                          rootUserModel.rootId =
                              ref.watch(currentUserProvider).rootId;
                          Navigation().navigationToQrImageScreen(
                              context, rootUserModel);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                                value: 0,
                                child: Text(
                                  'Объемы на закуп',
                                )),
                            const PopupMenuItem(
                                value: 1,
                                child: Text(
                                  'Мониторинг',
                                )),
                            const PopupMenuItem(
                                value: 2,
                                child: Text(
                                  'Склад',
                                )),
                            const PopupMenuItem(
                                value: 3,
                                child: Text(
                                  'Подписать клиента',
                                ))
                          ]),
                ],

                flexibleContainerChild: ListView(
                  padding: EdgeInsets.zero,
                  //shrinkWrap:true,
                  children: [
                    Consumer(
                      builder: (BuildContext context, WidgetRef ref, Widget? child) {

                        List<UserModel> actualUserList = [];

                        // ref.listen(getOrdersForPlacesProvider(tuple2ForOrders),
                        //     (previous, next) {
                        //   print('next.value::: ${next.value}');
                        //   print(next.value);
                        // });

                        return ref
                            .watch(getOrdersForPlacesProvider(tuple2ForOrders))
                            .when(
                                data: (data) {
                                  List<OrderDetailsModel> ordersList = [];
                                  ref.read(ordersListForPlaceProvider.notifier)
                                    ..clearOrdersyList()
                                    ..buildMultipleOrdersList(data);

                                  _kEventSource.clear();

                                  if (_customerId.isNotEmpty) {
                                    ordersList = ref.watch(ordersListForPlaceProvider)
                                        .where((element) => element.userId == _customerId)
                                        .toList();
                                  } else {
                                    ordersList = ref.watch(ordersListForPlaceProvider);
                                  }
                                  for (var element in ordersList) {
                                    DateTime milliseconds =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            element.addedAt);

                                    // Создаем событие на основе дня
                                    Event event = Event(
                                        '${milliseconds.year}${milliseconds.month}${milliseconds.day}',
                                        element.orderStatus);

                                    //print('ordersList: $ordersList');

                                    // Создаем DateTime.utc() для использования в качестве ключа
                                    DateTime dateTimeFromMilliseconds =
                                        DateTime.utc(
                                      milliseconds.year,
                                      milliseconds.month,
                                      milliseconds.day,
                                    );

                                    // Проверяем, существует ли уже список событий для данного дня
                                    if (_kEventSource.containsKey(
                                        dateTimeFromMilliseconds)) {
                                      // Добавляем событие в существующий список
                                      _kEventSource[dateTimeFromMilliseconds]!.add(event);
                                      // Сортируем список событий по дням
                                      _kEventSource[dateTimeFromMilliseconds]!.sort((a, b)
                                      => a.title.compareTo(b.title));
                                    } else {
                                      // Создаем новый список событий для данного дня и добавляем событие в него
                                      _kEventSource[dateTimeFromMilliseconds] = [event];
                                    }
                                  }
                                  return TableCalendar<Event>(
                                    locale: "ru_RU",
                                    firstDay: kFirstDay,
                                    lastDay: kLastDay,
                                    focusedDay: _today,
                                    availableGestures: AvailableGestures.all,
                                    selectedDayPredicate: (day) =>
                                        isSameDay(day, _today),
                                    calendarFormat: _calendarFormat,
                                    eventLoader: _getEventsForDay,
                                    startingDayOfWeek: StartingDayOfWeek.monday,
                                    calendarStyle: styles.calendarStyle!,
                                    headerStyle: styles.calendarHeaderStyle!,
                                    daysOfWeekStyle: styles.daysOfWeekStyle!,
                                    onDaySelected: _onDaySelected,
                                    // onPageChanged: (focusedDay) {
                                    //   _today = focusedDay;
                                    // },

                                    calendarBuilders: CalendarBuilders(
                                      todayBuilder: (context, date, events) {
                                        return null;
                                      },
                                      markerBuilder: (context, date, events) {
                                        if (events.isNotEmpty) {
                                          bool isNewOrder = events.where((el) => el.status == 0).toList().isNotEmpty;
                                          return Stack(children: [
                                            Positioned(
                                              right: 10.0,
                                              bottom: -6.0,
                                              child: Container(
                                                padding: const EdgeInsets.all(3.0),
                                                decoration: styles.calendarMarkerDecoration!,
                                                child: AvatarGlow(
                                                  animate: isNewOrder,
                                                  glowColor: isNewOrder
                                                      ? styles.glowColor!
                                                      : styles.glowColorStop!,
                                                  glowShape: BoxShape.circle,
                                                  curve: Curves.ease,
                                                  glowCount: 3,
                                                  glowRadiusFactor: 1.8,
                                                  child: Text(
                                                    '${events.length}',
                                                    style: styles.calendarMarkerTextStyle!,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]);
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  );
                                },
                                error: (_, __) => const Placeholder(),
                                loading: () => argumentsMap.isNotEmpty
                                    ? const ProgressMini()
                                    : Center(
                                        child: Text(
                                        'Здесь будут отображаться Ваши клиенты, календарь событий и адреса доставки',
                                        textAlign: TextAlign.center,
                                        style: styles.worningTextStyle,
                                      )));
                      },
                    ),
                    FutureBuilder<List<UserModel>>(
                      future: _userListForRectangle(
                          subscribCustomersList: subscribCustomersList,
                          ordersList: ref.watch(ordersListForPlaceProvider)),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<UserModel>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: ProgressMini());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Данных пока нет!');
                        } else {
                          snapshotConnectionState = true;
                          actualUserList = snapshot.data!;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RectangleHorizontalList(
                                rootUsersList: actualUserList,
                                isSubContent: true,
                                selectedIndex: -1,
                                height: 190.0,
                                onTapElement: (UserModel userByIndex, int index) {
                                  setState(() {
                                    for (var element in subscribCustomersList) {
                                      if (element.isSelectedElement!) {
                                        element.isSelectedElement = false;
                                      }
                                    }
                                    userByIndex.isSelectedElement = true;
                                    _customerId = userByIndex.uId;
                                    _selectedDay = null;
                                    _today = DateTime.now();
                                  });
                                },
                                onDoubleTapElement: (UserModel userData) {
                                  navigation
                                      .navigationToCreatePlaceDiscountScreen(
                                          context, userData)
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                              ),
                              if (_customerId.isNotEmpty || _selectedDay != null)
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleButton(
                                      title: 'Сбросить фильтры',
                                      onPressed: () {
                                        for (var element in subscribCustomersList) {
                                          if (element.isSelectedElement!) {
                                            element.isSelectedElement = false;
                                          }
                                        }
                                        setState(() {
                                          _customerId = '';
                                          _selectedDay = null;
                                          _today = DateTime.now();
                                        });
                                      }),
                                ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
                flexibleSpaceBarTitle: const SizedBox.shrink(),
                slivers: [
                  _contentListView(
                    argumentsMap: argumentsMap,
                    onTapMap: (PlaceModel placeModel) {


                      LatLng latLng = LatLng(
                          placeModel.locationLatLng[0],
                          placeModel.locationLatLng[1]);
                      ref.read(centerPositionProvider.notifier).state = latLng;
                      Navigation().navigateToMapScreen(context: context, args: {
                        'objecLatLng': latLng,
                        'distanceText': 'distanceText',
                        'durationText': 'durationText',
                        'totalKGS': 'totalKGS',
                        'fromWhichScreen': 'rootPlacesScreen',
                      });
                    },


                    onTapAddDiscount: (PlaceModel placeData) {},
                    onTapToOrders: (PlaceModel placeData) async {
                      if (ref
                          .watch(currentUserProvider)
                          .userRoles!
                          .contains('deliveryman')) {
                        await navigation
                            .navigateToRootOrdersScreen(
                                context,
                                IntentCurrentUserIdObjectIdProjectRootId(
                                  currentUserid: placeData.userId,
                                  projectRootId:
                                      ref.watch(currentUserProvider).rootId!,
                                  placeId: placeData.docId!,
                                  place: placeData,
                                ))
                            .then((value) => setState(() {}));
                      } else {
                        Get.snackbar('У Вас нет доступа', 'У Вас нет доступа');
                      }
                    },
                    onTapItems: () {},
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100.0,
                    ),
                  )
                ],
                isProgress: ref.watch(progressBoolProvider),
                isMiniPrgress: isMiniPrgress,
                radiusCircular: 0.0,
                //flexContainerColor: Colors.white,
                flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
                expandedHeight: 576.0,
                isPinned: false,
              );
            },
            error: (_, __) => const Placeholder(),
            loading: () => const ProgressMiniSplash());
      },
    );
  }

  Widget _contentListView({
    //required List<PlaceModel> placeModelList,
    required Map<String, List<String>> argumentsMap,
    //required List<OrderDetailsModel> placeOrderslList,
    required Function onTapMap,
    required Function onTapAddDiscount,
    required Function onTapToOrders,
    required VoidCallback onTapItems,
  }) {
    AppStyles styles = AppStyles.appStyle(context);
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        List<PlaceModel> placeModelList = [];
        ref.watch(getPlacesForRootProvider(argumentsMap)).whenData(
          (data) async {
            ref.read(placesListProvider.notifier)
              ..clearPlacesList()
              ..buildMultiplePlacesList(
                  data,
                  ref.watch(subscribersSortProvider).subscribCustomersList,
                  ref.watch(ordersListForPlaceProvider));
          },
        );

        if (_customerId.isNotEmpty && _selectedDay == null) {
          placeModelList = ref
              .watch(placesListProvider)
              .where((element) => element.userId == _customerId)
              .toList();
        } else if (_customerId.isEmpty && _selectedDay != null) {
          placeModelList = ref
              .watch(placesListProvider)
              .where((element) => element.orderDetailsList!.any((e) {
                    DateTime orderDate = DateTime.fromMillisecondsSinceEpoch(e.addedAt);
                    return orderDate.day == _today.day &&
                        orderDate.month == _today.month &&
                        orderDate.year == _today.year;})).toList();

          userIdFromOrderList = placeModelList.map((e) => e.userId).toList();
        } else {
          placeModelList = ref.watch(placesListProvider);
        }

        print('placeModelList:::: ${placeModelList.length}');

        return SliverPadding(
          padding: const EdgeInsets.all(5.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: placeModelList.length,
              (BuildContext context, int index) {
                String addressDescription;
                String placeName;

                if (placeModelList[index].placeName.length > 30) {
                  placeName = placeModelList[index].placeName.substring(0, 30);
                } else {
                  placeName = placeModelList[index].placeName;
                }

                if (placeModelList[index].addressDescription.length > 35) {
                  addressDescription =
                      placeModelList[index].addressDescription.substring(0, 35);
                } else {
                  addressDescription = placeModelList[index].addressDescription;
                }

                IntentCurrentUserIdObjectIdProjectRootId args =
                    IntentCurrentUserIdObjectIdProjectRootId(
                        currentUserid: placeModelList[index].userId,
                        projectRootId: ref.watch(currentUserProvider).rootId!,
                        placeId: placeModelList[index].docId!);

                return Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: const EdgeInsets.only(bottom: 5.0),
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.grey),
                  //     borderRadius: const BorderRadius.all(Radius.circular(10.0))),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100.0,
                        child: Row(
                          children: [
                            Flexible(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                child: CachedNetworkImg(
                                    imageUrl: placeModelList[index].placeImage,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Flexible(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                child: GestureDetector(
                                  onTap: () => onTapMap(placeModelList[index]),
                                  child: CachedNetworkImg(
                                      imageUrl:
                                          placeModelList[index].locationImage,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // _placeDetails(
                      //   placeModel: placeModelList[index],
                      //   onPressed: () {
                      //     onTapToOrders(placeModelList[index]);
                      //   },
                      // ),

                      FutureBuilder(
                        future:
                            Future.delayed(const Duration(milliseconds: 300)),
                        builder: (BuildContext context, _) {
                          return _placeDetails(
                            placeModel: placeModelList[index],
                            onPressed: () {
                              onTapToOrders(placeModelList[index]);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _placeDetails({
    required PlaceModel placeModel,
    required VoidCallback onPressed,
  }) {
    List<OrderDetailsModel> ordesList = ref
        .watch(ordersListForPlaceProvider)
        .where((element) => element.objectId == placeModel.docId)
        .toList();

    num ordersListLength = 0;
    num allTotal = 0;
    List<num> ordersStatusList = [];
    String ordersStatus = '';
    bool isSuccess0 = false;
    bool isSuccess1 = false;
    bool isSuccess2 = false;

    if (ordesList.isNotEmpty) {
      ordersListLength = ordesList.length;
      allTotal = ordesList.map((e) => e.totalSum).reduce((v, e) => v + e);

      ordersStatusList = ordesList.map((e) => e.orderStatus).toList();

      isSuccess0 = ordersStatusList.contains(0);
      isSuccess1 =
          (!ordersStatusList.contains(0) && ordersStatusList.contains(1) ||
              ordersStatusList.contains(2));
      isSuccess2 = (!ordersStatusList.contains(0) &&
          !ordersStatusList.contains(1) &&
          !ordersStatusList.contains(2));

      if (isSuccess0) {
        ordersStatus = 'Новый заказ';
      } else if (isSuccess1) {
        ordersStatus = 'Незакрытые заказы';
      } else if (isSuccess2) {
        ordersStatus = 'Все закрыты';
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichSpanTextMini(
                        spanText: SnapTextModel(
                            title: 'Заказчик: ',
                            data: placeModel.placeName,
                            postTitle: '')),
                    RichSpanTextMini(
                        spanText: SnapTextModel(
                            title: 'Кешбэк: ',
                            data: placeModel.userModel!.discountPercent
                                .toString(),
                            postTitle: ' %')),
                    RichSpanTextMini(
                        spanText: SnapTextModel(
                            title: 'Создан: ',
                            data: Utils()
                                .dateParse(milliseconds: placeModel.addedAt),
                            postTitle: '')),
                  ],
                ),
              ),
              //const SizedBox(width: 3.0,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichSpanTextMini(
                        spanText: SnapTextModel(
                            title: 'Заказов: ',
                            data: ordesList.length.toString(),
                            postTitle: '')),
                    RichSpanTextMini(
                        spanText: SnapTextModel(
                            title: 'Сумма: ',
                            data: Utils().numberParse(value: allTotal),
                            postTitle: ' UZS')),

                    // RichSpanText(
                    //     spanText: SnapTextModel(
                    //         title: 'Статус: ',
                    //         data: ordersStatus,
                    //         postTitle: '')),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8.0,
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleButton(
              title: ordersStatus,
              onPressed: onPressed,
            ),
          ),

          // AvatarGlow(
          //   animate: isSuccess0,
          //   glowColor: isSuccess0 ? Theme.of(context).primaryColorLight : Colors.white,
          //   glowShape: BoxShape.circle,
          //   curve: Curves.ease,
          //   glowCount: 3,
          //   glowRadiusFactor:1.5,
          //   child: SizedBox(
          //     width: MediaQuery.of(context).size.width,
          //     child: SingleButton(
          //       title: ordersStatus,
          //       onPressed: onPressed,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<List<UserModel>> _userListForRectangle({
    required List<UserModel> subscribCustomersList,
    required List<OrderDetailsModel> ordersList,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    List<UserModel> newUserList = [];
    List<UserModel> customersList = [];
    num allOrdersTotalsSum = 0;
    num allOrdersPaidSum = 0;
    num allOrdersNotPaidSum = 0;

    if (_customerId.isNotEmpty){
      customersList = subscribCustomersList.where((user) => user.uId == _customerId).toList();
    }
    else if(_selectedDay != null){
      for (String userId in userIdFromOrderList) {
        for (UserModel user in subscribCustomersList) {
          if(userId == user.uId && !customersList.contains(user)){
            customersList.add(user);
          }
        }
      }
    }
    else {
      customersList = subscribCustomersList;
    }

      for (OrderDetailsModel order in ordersList) {

        allOrdersTotalsSum = ordersList
            .where((elem) => elem.userId == order.userId)
            .map((e) => e.totalSum).toList()
            .fold(0,(v, e) => v + e);

        allOrdersPaidSum = ordersList
            .where((elem) => elem.userId == order.userId)
            .map((e) => e.debtRepayment).toList()
            .fold(0,(v, e) => v + e);

        newUserList = customersList.map((e) {
          if(e.uId == order.userId){
            allOrdersNotPaidSum = (allOrdersTotalsSum - allOrdersPaidSum);
            e.limitRemainder = (e.limit! - allOrdersNotPaidSum);
            e.debt = allOrdersNotPaidSum;
          }
          return e;
        }).toList();
      }
    return newUserList;
  }

 }

Widget _popUpMenuBtn(BuildContext context, navigation, WidgetRef ref) {
  return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      onSelected: (int itemIndex) {
        if (itemIndex == 0) {
          navigation.navigateToUnitedPositionScreen(context);
        } else if (itemIndex == 1) {
          navigation.navigateToPurchaseListScreen(context);
        } else if (itemIndex == 2) {
        } else if (itemIndex == 3) {
        } else if (itemIndex == 4) {
          pickAndReadExcelFile();
        }
      },
      itemBuilder: (BuildContext context) => [
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 0,
                child: const Text('Объем на закуп')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 1,
                child: const Text('Мониторинг')),
// PopupMenuItem(
//     textStyle: Theme.of(context).textTheme.bodyMedium,
//     value: 2,
//     child: const Text('Добавить объект')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 3,
                child: const Text('Склад')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 4,
                child: const Text('pickerFile')),
          ]);
}

void pickAndReadExcelFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xls', 'xlsx'],
  );

  if (result != null) {
    PlatformFile file = result.files.first;

    print(file);

// Здесь вызывайте функцию для чтения Excel файла
    readExcelFile(file.path!);
  } else {
// Пользователь не выбрал файл
  }
}

void readExcelFile2(String filePath) async {
  List<PositionModel> positionsList = [];

  var bytes = File(filePath).readAsBytesSync();
  var excel = excel_lib.Excel.decodeBytes(bytes);

  for (var table in excel.tables.keys) {
    print('table-------$table'); // Имя листа Excel

    var rows = excel.tables[table]!.rows;
    var firstRow = rows[0];
//print('firstRow----------$firstRow');
//print('firstRow.runtimeType----------${firstRow.runtimeType}');
//print('firstRow[0]!.value----------${firstRow[0]!.value}');

//for (var fir in rows) {
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
//for (var firstRowCell in rows[i]) {
        for (int y = 0; y < rows[i].length; y++) {
          var ff = rows[i][y];

          if (ff != null) {
            print('runtimeType----------${ff.runtimeType}');
            print('cellIndex----------${ff.cellIndex}');
            print('columnIndex----------${ff.columnIndex}');
            print('rowIndex----------${ff.rowIndex}');
            print('value----------${ff.value}');

// positionsList.add(PositionModel(
//     projectRootId: projectRootId,
//     productName: ddd[0],
//     productMeasure: productMeasure,
//     productFirsPrice: productFirsPrice,
//     productPrice: productPrice,
//     productQuantity: productQuantity,
//     marginality: marginality,
//     deliverSelectedTime: deliverSelectedTime,
//     available: available,
//     subCategoryName: subCategoryName,
//     subCategoryId: subCategoryId,
//     deliverId: deliverId,
//     deliverName: deliverName,
//     amount: amount,
//     united: united,
//     productImage: productImage));
          }
        }
      }

//print('row----------$row'); // Вывод содержимого каждой строки в листе
    }
  }
}

void readExcelFile(String filePath) async {
  List<PositionModel> positionsList = [];
  var bytes = File(filePath).readAsBytesSync();
  var excel = excel_lib.Excel.decodeBytes(bytes);

  for (var table in excel.tables.keys) {
    var rows = excel.tables[table]!.rows;

    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        var rowData = rows[i]; // Получаем данные из строки

// Пример создания объекта PositionModel из данных строки
        var position = PositionModel(
          projectRootId: '',
          productName: rowData[0]?.value?.toString() ?? '',
          productMeasure: rowData[1]?.value?.toString() ?? '',
          productFirsPrice: 0,
          productPrice: 0,
          productQuantity: 0,
          marginality: 0,
          deliverSelectedTime: 0,
          available: true,
          subCategoryName: '',
          subCategoryId: '',
          deliverId: '',
          deliverName: '',
          amount: 0,
          united: 0,
          productImage: '',
          addedAt: 0,
        );

        positionsList.add(position); // Добавляем созданный объект в список
      }
    }
  }
}
