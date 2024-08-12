import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/registration_services/registration_services.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/cart/cart_services/cart_services.dart';
import 'package:ya_bazaar/res/cart/cart_services/real_time_services.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/subscribers_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/orders/orders_controller/order_details_controller.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';
import 'package:ya_bazaar/res/places/place_controllers/places_controller.dart';
import 'package:ya_bazaar/res/places/place_providers/place_providers.dart';
import 'package:ya_bazaar/res/positions/positions_services/positions_services.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/res/widgets/three_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class CartScreen extends ConsumerStatefulWidget {
  static const String routeName = 'cartScreen';
  final IntentRootPlaceArgs navigateSearchArgs;

  const CartScreen({
    super.key,
    required this.navigateSearchArgs,
  });

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends ConsumerState<CartScreen> {
  late CartFBServices dbs = CartFBServices();
  late RealTimeServices rtDbs = RealTimeServices();

  final storageBox = GetStorage();

  Utils utils = Utils();
  Navigation navigation = Navigation();
  PlaceModel? placeData;
  UserModel? rootUserData;

  late num cashback;
  late num limit;

  String customerNameTitle = 'Адрес доставки не добавлен!';

  late List<OrderModel> cartDataList;

  late FocusNode _focusNode;

  String fromWhichScreen = '';

  @override
  void initState() {
    placeData = widget.navigateSearchArgs.placeModel;
    rootUserData = widget.navigateSearchArgs.rootUserModel;
    fromWhichScreen = widget.navigateSearchArgs.fromWhichScreen!;
    limit = rootUserData!.limit ?? 0;
    cashback = rootUserData!.discountPercent ?? 0;
    super.initState();
  }

  String _customerName() {
    String strCustomer;
    MultipleCartModel cartHeader = ref
        .read(multipleCartListProvider.notifier)
        .currentCartData(rootUserData!.uId);
    if (cartHeader.customerId.isNotEmpty) {
      strCustomer = "Адрес доставки: ${cartHeader.customerName}";
    } else {
      strCustomer = 'Адрес доставки не добавлен!';
    }

    return strCustomer;
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {


        String projectRootId = '';
        if(ref.watch(orderListProvider).isNotEmpty){
          projectRootId = ref.watch(orderListProvider).first.projectRootId;
        }

        MultipleCartModel cartHeader
        = ref.read(multipleCartListProvider.notifier).currentCartData(rootUserData!.uId);

        String strCustomer;
        if (cartHeader.customerId.isNotEmpty) {
          strCustomer = cartHeader.customerName;
        }
        else {
          strCustomer = 'не добавлен!';
        }

        int placeQty = 0;
        List<String> placesIdList = [];


        final PlacesListController placesListController
        = ref.read(placesListProvider.notifier);
        ref.watch(getPlaceByUserIdProvider(ref.watch(currentUserProvider).uId))
            .whenData((placesData) async{
          placesListController
            ..clearPlacesList()
            ..buildPlacesList(placesData);
          placeQty = ref.watch(placesListProvider).length;
          placesIdList = ref.watch(placesListProvider).map((e) => e.docId!).toList();
          ref.read(totalsDifferenceDebtProvider.notifier).state
          = await _totalsDifferenceDebt(placesIdList: placesIdList);

            });

        return BaseLayout(
            onWillPop: (){
              //currentDifference = 0;
              //ref.read(numProvider.notifier).state = 0;
              Navigator.pop(context, 'willPopCartScreen');
              return Future.value(false);
            },
            isAppBar: true,
            isBottomNav: false,
            isFloatingContainer: true,
            appBarTitle: rootUserData!.name,
            appBarSubTitle: 'Поставщик',
            avatarUrl: rootUserData!.profilePhoto,
            avatarTap: (){
              if(fromWhichScreen == 'orderPositionsScreen'){
                navigation.navigateToSearchScreen(
                    context,
                    IntentRootPlaceArgs(
                        fromWhichScreen: 'cartScreen',
                        rootUserModel: rootUserData!,
                        placeModel: PlaceModel.empty())).then((value) => Navigator.pop(context));
              }

            },
            flexibleContainerChild: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: EdgeInsets.zero,
                //shrinkWrap:true,
                children: [

                  RichSpanText(spanText: SnapTextModel(title: 'Адрес доставки: ', data: strCustomer, postTitle: '')),
                  RichSpanText(spanText: SnapTextModel(title: 'Кешбэк: ', data: '$cashback', postTitle: ' %')),
                  RichSpanText(spanText: SnapTextModel(title: 'Всего позиций: ', data: ref.watch(orderListProvider).length.toString(), postTitle: '')),
                  RichSpanText(spanText: SnapTextModel(title: 'На сумму: ', data: '${utils.numberParse(value: ref.read(orderListProvider.notifier).totalSum(cashback))}', postTitle: ' UZS')),

                ],
              ),
            ),
            flexibleSpaceBarTitle: const SizedBox.shrink(),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: ref.watch(orderListProvider).length,
                      (BuildContext context, int index) {
                    num qty = ref.watch(orderListProvider)[index].productQuantity;
                    ref.watch(orderListProvider)[index].index = index;

                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(6.0),
                      decoration: styles.positionBoxDecoration,
                      child: Column(
                        children: [
                          Text(
                            ref.watch(orderListProvider)[index].productName,
                            textAlign: TextAlign.center,
                            style: styles.addToCartPriceStyle,
                            softWrap: true,
                          ),
                          const Divider(),
                          Text(
                            '${utils.numberParse(value: ref.watch(orderListProvider)[index].productPrice)} UZS/${ref.watch(orderListProvider)[index].productMeasure}',
                            style: styles.addToCartPriceStyle,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${utils.numberParse(value: ref.watch(orderListProvider)[index].discountPrice)}',
                                        style: styles.addToCartPriceStyle,
                                      ),
                                      Text(
                                        'Цена: UZS/${ref.watch(orderListProvider)[index].productMeasure}',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColor),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        ref.watch(orderListProvider)[index]
                                            .discountPercent.toString(),
                                        style: styles.addToCartPriceStyle,
                                      ),
                                      Text(
                                        'Скидка %',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColor),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${utils.numberParse(value: ref.watch(orderListProvider)[index].amountSum)}',
                                        style: styles.addToCartPriceStyle,
                                      ),
                                      Text(
                                        'Сумма',
                                        style: TextStyle(
                                            color: Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [

                                      IconButton(
                                          onPressed: () async {
                                            if (qty > 1) {
                                              qty--;
                                              ref.read(orderListProvider.notifier)
                                                  .updateQtyPosition(
                                                index: index,
                                                productId: ref.watch(orderListProvider)[index].productId,
                                                qty: qty,
                                                discountList: ref.watch(orderListProvider)[index].discountList,
                                              );

                                              setState(() {});
                                            }
                                          },
                                          icon: Icon(
                                            Icons.remove,
                                            size: 28.0,
                                            color: Theme.of(context)
                                                .primaryColor,
                                          )),
                                      Container(
                                        height: 40,
                                        width: MediaQuery.of(context).size.width / 3,
                                        decoration: styles.cartQtyBoxDecoration,
                                        child: Center(
                                          child: Text(utils.numberParse(value: ref.watch(orderListProvider)[index].productQuantity),
                                            style: styles.addToCartPriceStyle,),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            qty++;

                                            ref.read(orderListProvider.notifier)
                                                .updateQtyPosition(
                                                index: index,
                                                productId: ref.watch(orderListProvider)[index].productId,
                                                qty: qty,
                                                discountList: ref.watch(orderListProvider)[index].discountList);

                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.add,
                                            size: 28.0,
                                            color: Theme.of(context)
                                                .primaryColor,
                                          )),

                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await ref.read(multipleCartListProvider.notifier)
                                            .removeCartListPosition(
                                          ref: ref,
                                          projectRootId: ref.watch(orderListProvider)[index].projectRootId,
                                          productId: ref.watch(orderListProvider)[index].productId,
                                          currentCart: ref.watch(orderListProvider),)
                                            .then((List<OrderModel> value) {
                                          if (value.isEmpty) {
                                            Navigator.pop(context, 'willPopCartScreen');
                                          }
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 35.0,
                                        color: Theme.of(context)
                                            .primaryColor,
                                      )),
                                ],
                              ),
                              // Text(
                              //   ref.watch(orderListProvider)[index].objectId!,
                              //   style: TextStyle(
                              //       color: Theme.of(context)
                              //           .primaryColor),
                              // )
                            ],
                          ),

                        ],
                      ),
                    );
                  },

                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 180.0,),
              )

            ],
            floatingContainer: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                int invoiceNum = 0;
                num allOrdersTotalsSum = 0;//сумма всех заказов
                num allOrdersDebtSum = 0;//сумма не оплаченых заказов
                num allOrdersPaidSum = 0;//сумма оплаченых заказов
                num allLimtBalanceSum = 0;//остаток лимита
                num allOrdersNotPaidSum = 0;//сумма не оплаченых заказов

                List<num> totalsDifferenceDebt = ref.watch(totalsDifferenceDebtProvider);

                print(totalsDifferenceDebt);

                MultipleCartModel currentCartData = ref
                    .read(multipleCartListProvider.notifier)
                    .currentCartData(rootUserData!.uId);

                final IntentCurrentUserIdObjectIdProjectRootId
                objectIdProjectRootId =
                IntentCurrentUserIdObjectIdProjectRootId(
                  currentUserid: ref.watch(currentUserProvider).uId,
                  projectRootId: cartHeader.projectRootId,
                  placeId: cartHeader.customerId,
                );

                final OrderDetailsController ordersController
                = ref.read(ordersDetailListProvider.notifier);
                ref.watch(unitedByRootIdProvider(currentCartData.projectRootId))
                    .whenData((DatabaseEvent event) {
                  ref.read(unitedListProvider.notifier)
                    ..clearUnitedList()
                    ..buildUnitedList(event,currentCartData.projectRootId);
                });
                num currentTotal2 = 0;
                ref.listen(ordersByRootIdProvider(objectIdProjectRootId),
                        (previous, next) async {
                      next.whenData((ordersDetail) {
                        ordersController
                          ..clearOrdersyList()
                          ..buildOrdersDocNumber(ordersDetail, ref.watch(subscribersSortProvider).subscribOwnerList);

                        invoiceNum = ref
                            .watch(ordersDetailListProvider)
                            .fold(1, (maxInvoice, order) => max(maxInvoice, order.invoice +1));
                      });
                    });

                if(totalsDifferenceDebt.isNotEmpty)
                {
                  allOrdersTotalsSum = totalsDifferenceDebt[0];//сумма всех заказов
                  allOrdersDebtSum = totalsDifferenceDebt[1];//сумма не оплаченых заказов
                  allOrdersPaidSum = totalsDifferenceDebt[2];//сумма оплаченых заказов
                  allOrdersNotPaidSum = (allOrdersTotalsSum - allOrdersPaidSum);//сумма не оплаченых заказов
                  allLimtBalanceSum = (limit - allOrdersNotPaidSum);//остаток лимита
                }



                // print('сумма всех заказов: $allOrdersTotalsSum');
                // print('сумма не оплаченых заказов: $allOrdersDebtSum');
                // print('сумма оплаченых заказов : $allOrdersPaidSum');
                // print('сумма не оплаченых заказов : $allOrdersNotPaidSum');
                // print('остаток лимита : $allLimtBalanceSum');
                // print('лимит : $limit');

                num currentTotal = ref.read(orderListProvider.notifier).totalSum(cashback);
                num remainderSum = limit == 0 ? 0 : (allLimtBalanceSum - currentTotal);


                return Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  width: MediaQuery.of(context).size.width,

                  decoration: const BoxDecoration(
                      color: Colors.black54,
                    borderRadius: BorderRadius.all(Radius.circular(6.0))
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Текущая сумма: ${utils.numberParse(value: currentTotal)} UZS',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      Text(
                        limit == 0
                            ? 'Безлимит'
                            : remainderSum < 0
                            ? 'Лимит превышен на: ${Utils().numberParse(value: remainderSum.abs())} UZS'
                            : 'Лимит: ${Utils().numberParse(value: remainderSum.abs())} UZS',

                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ThreeButtonsBlock(
                          positiveText: 'Заказать',
                          positiveClick: () async {

                            if(limit != 0 && remainderSum < 0){
                              Get.snackbar('Лимит превышен на ${Utils().numberParse(value: remainderSum.abs())} UZS!', 'Не допустимая сумма заказа!');
                              return;
                            }
                            else {
                              await _sendOrder(
                                  context: context,
                                  rootUserData: rootUserData!,
                                  placeData: placeData!,
                                  currentCartData: currentCartData,
                                  cashback: cashback,
                                  placeQty: placeQty,
                                  placesIdList: placesIdList,
                                  invoiceNum: invoiceNum).whenComplete(() {
                                //setState(() {});
                              });
                            }
                          },
                          neutralText: 'Очисть корзину',
                          neutralClick: () {
                            ref.read(multipleCartListProvider.notifier)
                                .removeCartList(
                              ref: ref,
                              projectRootId: currentCartData.projectRootId,
                            );
                            ref.read(currentPlaceProvider.notifier).clearPlace();
                            Navigator.pop(context, 'willPopCartScreen');
                          },
                          negativeText: 'Назад',
                          negativeClick: () async {

                            Navigator.pop(context, 'willPopCartScreen');

                            // rtDbs.getUnitedData(rootId: currentCartData.projectRootId).listen((event) {
                            //
                            //   print(event.snapshot.value);
                            //
                            // });

                            //_limit();


                          }),
                    ],
                  ),
                );
              },
            ),
            isProgress: ref.watch(progressBoolProvider),

        radiusCircular: 0.0,
        flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
        expandedHeight: 100.0,
        //collapsedHeight: 60.0,
        isPinned: false,
        );
      },
    );


  }



  Future<List<num>> _totalsDifferenceDebt({
    required placesIdList,
  }) async{

    num allDebtRepayment = 0;
    num allTotals = 0;
    num allDifference = 0;

    try {
      List<OrderDetailsModel> customerAllOrderList = await OrderFBServices().fetchAllOrders(
        placeIdList: placesIdList,
        userId: ref.watch(currentUserProvider).uId,
        projectRootId: rootUserData!.uId,
      );

      allDebtRepayment = customerAllOrderList.map((e) => e.debtRepayment).fold(0,(e, v) => e + v);
      allTotals = customerAllOrderList.map((e) => e.totalSum).fold(0,(e, v) => e + v);
      allDifference = (allTotals - allDebtRepayment);

    } catch (e) {
      print('Error fetching orders: $e');
    }

    return [allTotals, allDifference, allDebtRepayment];
  }









  Future<num> _difference({
    required placesIdList,
}) async{

    num? allDifferenceSum;

    try {
      List<OrderDetailsModel> customerAllOrderList = await OrderFBServices().fetchAllOrders(
        placeIdList: placesIdList,
        userId: ref.watch(currentUserProvider).uId,
        projectRootId: rootUserData!.uId,
      );

      List<num> differenceList = [];

      num allDebtRepayment = customerAllOrderList.map((e) => e.debtRepayment).fold(0,(e, v) => e + v);

      print('allDebtRepayment::: $allDebtRepayment');


      List<OrderDetailsModel> deptOrderList = customerAllOrderList.where((order) => order.totalSum > order.debtRepayment).toList();

      for (OrderDetailsModel order in deptOrderList) {
        num sum = (order.totalSum - order.debtRepayment);
        differenceList.add(sum);
      }

      allDifferenceSum = differenceList.reduce((v, e) => v + e);
    } catch (e) {
      print('Error fetching orders: $e');
    }


    return allDifferenceSum ?? 0;
  }



  Future<num> _limit() async {
    List<PlaceModel> placeModelList = [];
    final PlacesListController placesListController = ref.read(placesListProvider.notifier);
    ref.watch(getPlaceByUserIdProvider(ref.watch(currentUserProvider).uId))
        .whenData((placesData) {
      placesListController
        ..clearPlacesList()
        ..buildPlacesList(placesData);
        placeModelList = ref.watch(placesListProvider);
        });

    for (var element in placeModelList) {
      print(element.docId);
    }

    return 0;
  }

  Future<void> _sendOrder({
    required BuildContext context,
    required UserModel rootUserData,
    required PlaceModel placeData,
    required MultipleCartModel currentCartData,
    required num cashback,
    required num placeQty,
    required List<String> placesIdList,
    required int invoiceNum,
  }) async {

    Navigation navigation = Navigation();
    Utils utils = Utils();

    String currentUserId = ref.watch(currentUserProvider).uId;


    if (currentUserId == 'guest') {

      // await Registration().signInWithGoogle(ref: ref).then((value) async {
      //   await _getCurrentUserData(context, ref, ref.watch(currentUserProvider).uId,)
      //       .then((value) async {
      //     setState(() {});
      //   });
      // });

      await navigation
          .navigationToSignScreen(context, 'cartScreen')
          .then((currentUserId) async {
        if (currentUserId != null) {
          await _getCurrentUserData(context, ref, currentUserId,)
              .then((value) async {

            setState(() {});
          });
        }
        else {

          Get.snackbar(
            'Внимание!',
             'Регистрация не завершилась успешно, повторите попытку...',
          );

        }
      });
    }
    else {
      if (currentCartData.customerId.isEmpty) {
        if (placeQty > 0) {

          utils.dialogBuilder(
              context: context,
              isActions: false,
              title: 'Куда отправить?',
              content: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [

                  SingleButton(
                      title: 'Создать новый адрес',
                      onPressed: () async {
                        await navigation
                            .navigateToCreatePlaceScreen(
                            context,
                            IntentArguments(
                              currentRootId:
                              rootUserData.uId,
                              currentUserId: ref.watch(currentUserProvider).uId,
                              userModel: ref.watch(currentUserProvider),
                              fromWhichScreen:
                              'cartScreen',
                            ))
                            .then((value) async {
                          setState(() {});
                        }).then((value) => Navigator.pop(context));
                      }),
                  const SizedBox(
                    width: 8.0,
                  ),
                  SingleButton(
                    title: 'Выбрать адрес',
                    onPressed: () async {
                    await navigation.navigationToPlacesScreen(
                        context, IntentArguments(
                        currentRootId:
                        rootUserData.uId,
                        fromWhichScreen:
                        'cartScreen'))
                        .then((place) async {
                      setState(() {});
                    }).then((place) {
                      Navigator.pop(context,placeData);
                    });
                  },),
                ],
              ),
              contentPadding: 8.0);
        }
        else {
          navigation
              .navigateToCreatePlaceScreen(
              context, IntentArguments(
                userModel: ref.watch(currentUserProvider),
                currentRootId: rootUserData.uId,
                currentUserId: ref.watch(currentUserProvider).uId,
                fromWhichScreen: 'cartScreen',
              ));
          //.then((value) => Navigator.pop(context));
        }
      }
      else {
        ref.read(progressBoolProvider.notifier).updateProgressBool(true);

        OrderDetailsModel orderDetailsModel = OrderDetailsModel(
          projectRootId: currentCartData.projectRootId,
          userId: ref.watch(currentUserProvider).uId,
          objectId: currentCartData.customerId,
          objectName: currentCartData.customerName,
          requestDate: 0,
          objectDiscount: 0,
          invoice: invoiceNum,
          orderStatus: 0,
          deliverSelectedTime: 0,
          deliverId: '',
          deliverName: '',
          totalSum: ref.read(orderListProvider.notifier).totalSum(cashback),
          positionListLength: ref.watch(orderListProvider).length,
          orderPositionsList: ref.watch(orderListProvider),
          addedAt: 0,
          cashback: cashback,
          debtRepayment: 0,
        );
        SubscribersModel subscribersModel = SubscribersModel(
          customerId: orderDetailsModel.userId,
          projectRootId: orderDetailsModel.projectRootId,
          addedAt: 0,
          discountPercent: 0,
          limit: limit,
        );

        ref.watch(subscribersListProvider).forEach((elem) {
          if(elem.projectRootId == orderDetailsModel.projectRootId){
            subscribersModel.discountPercent = elem.discountPercent;
          }
        });


        await _addOrder(
            context: context,
            ref: ref,
            orderDetailsModel: orderDetailsModel,
            subscribersModel: subscribersModel)
        .whenComplete(() {});
      }
    }
  }
}

Future<void> _getCurrentUserData(
    BuildContext context,
    WidgetRef ref,
    String currentUserId,
    ) async {
  late Registration dbs = Registration();
  var streamUser = dbs.getCurrentUser2(currentUserId);
  streamUser.listen(
        (userData) {
      ref.read(currentUserProvider.notifier).buildCurrentUser(userData);
    },
  );
  await _createContent232(ref: ref, currentUseId: currentUserId);
}

Future<void> _createContent232({
  required WidgetRef ref,
  required String currentUseId,
}) async {
//получаем всех подписчиков
  PositionsFBServices().getSubscribers(currentUseId).listen((event) {
//очищаем промежуточных массивов для сортировки
    ref.read(subscribersSortProvider.notifier).clearSubscribersSortLists();
    ref
        .read(subscribersSortProvider.notifier)
        .clearSubscribCustomersSortLists();
    ref.read(subscribersListProvider.notifier)
      ..clearSubscribersList()
//формируем список подписчиков
      ..buildSubscribersList(event)
//формируем список пользователей
      ..buildSubscribAndNotSubscrib(ref,)
//формируем список закзчиков
      ..buildCustomerSubscribers(ref,);
  });
}

Future<void> _addOrder({
  required BuildContext context,
  required WidgetRef ref,
  required OrderDetailsModel orderDetailsModel,
  required SubscribersModel subscribersModel,
}) async{

  late CartFBServices dbs = CartFBServices();
  //late RealTimeServices rtDbs = RealTimeServices();
  //List<PurchasingModel> purchasingListStatus0 = List<PurchasingModel>.from(ref.watch(allPurchasesListProvider));

  await dbs.addOrder2(
    orderData: orderDetailsModel,
    userData: ref.watch(currentUserProvider),
    subscribersModel: subscribersModel,
    placeStatus: 1,).whenComplete(() async {

    ref.read(multipleCartListProvider.notifier)
        .removeCartList(ref: ref, projectRootId: orderDetailsModel.projectRootId,);

    ref.read(currentPlaceProvider.notifier).clearPlace();
    ref.read(currentLimitDifferenceProvider.notifier).state = 0;
    ref.read(progressBoolProvider.notifier).updateProgressBool(false);

    }).whenComplete(() => Navigator.pop(context, 'cartScreen'));

}



