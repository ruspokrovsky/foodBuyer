
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';
import 'package:ya_bazaar/res/pdf_service.dart';
import 'package:ya_bazaar/res/places/place_providers/place_providers.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/chip_btn.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/search_widget.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class OrderPositionsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'orderPositionsScreen';

  //final OrderDetailsModel orderDetailsPosition;
  final IntentArguments intentArguments;

  const OrderPositionsScreen({
    super.key,
    required this.intentArguments,
  });

  @override
  OrderPositionsScreenState createState() => OrderPositionsScreenState();
}

class OrderPositionsScreenState extends ConsumerState<OrderPositionsScreen> {
  List<OrderModel> orderPositionsList = [];
  String query = '';

  late OrderDetailsModel orderDetailsPosition;
  late PlaceModel placeData;

  @override
  void initState() {
    orderDetailsPosition = widget.intentArguments.orderDetailsModel!;
    placeData = widget.intentArguments.placeModel!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        num actualTotal = 0;
        num currentTotal = 0;
        num incomeTotal = 0;
        //List<OrderModel> orderPositionsList = [];
        List<OrderModel> orderListForPrint = [];
        //orderDetailsPosition.projectRootId = ref.watch(currentUserProvider).rootId!;

        List<UserModel> rootUserList = ref.watch(subscribersSortProvider).subscribOwnerList;
        UserModel? rootUser = rootUserList.firstWhere(
          (user) => user.uId == orderDetailsPosition.projectRootId,
          orElse: () => UserModel.empty(),
        );

        return ref
            .watch(orderPositionsByOrderIdProvider2(orderDetailsPosition))
            .when(
                data: (positionData) {
                  ref.read(ordersPositionListProvider.notifier)
                    ..clearOrderPositionsList()
                    ..buildOrderPositionsList(
                      positionData,
                    );
                  orderPositionsList = ref.watch(ordersPositionListProvider);

                  for (var element in orderPositionsList) {
                    element.discountPrice = element.productPrice;
                    element.objectId = orderDetailsPosition.objectId;
                    DiscountModel arguments = DiscountModel(
                      rootId: orderDetailsPosition.projectRootId,
                      positionId: element.productId,
                      quantity: 0,
                      percent: 0,
                    );

                    ref.watch(getPositionsDiscountProvider(arguments)).whenData(
                      (QuerySnapshot value) async {
                        ref.read(discountListProvider.notifier)
                          ..clean()
                          ..buildPositionDiscountList(value);
                      },
                    );

                    element.discountList = List<DiscountModel>.from(
                        ref.watch(discountListProvider));
                  }


                  //подсчитываем actualTotal из контроллера для динамического изменения
                  if (orderPositionsList.isNotEmpty) {
                    orderListForPrint = ref
                        .watch(ordersPositionListProvider)
                        //.where((element) => element.successStatus != 4)
                        .where((element) => element.successStatus == 3)
                        .toList();

                    if (orderListForPrint.isNotEmpty) {
                      actualTotal = orderListForPrint
                          .map((e) {
                            num lastPercentSum = (e.amountSum * e.lastDiscountPercent) / 100;
                            return (e.amountSum - lastPercentSum);
                          })
                          .reduce((value, element) => value + element)
                          .toDouble();
                      // нумеруем позиции для накладной
                      for (int i = 0; i < orderListForPrint.length; i++) {
                        orderListForPrint[i].index = i + 1;
                      }
                    }

                    currentTotal = orderPositionsList.map((e) => e.amountSum)
                        .toList().fold(0, (e, v) => e + v);
                  }

                  String invoiceName =
                      '${orderDetailsPosition.invoice}/${Utils().monthParse(milliseconds: orderDetailsPosition.addedAt)}';
                  String fileName = orderDetailsPosition.objectName;

                  String acceptedDate = 'Черновик';
                  if (orderDetailsPosition.orderStatus == 2) {
                    acceptedDate = Utils().dateTimeParse(
                        milliseconds: orderDetailsPosition.requestDate);
                  }

                  orderPositionsList = ref.watch(ordersPositionListProvider);
                  if (orderPositionsList.isNotEmpty) {
                    if (query.isNotEmpty) {
                      orderPositionsList = orderPositionsList.where((book) {
                        final titleLower = book.productName.toLowerCase();
                        final searchLower = query.toLowerCase();
                        return titleLower.contains(searchLower);
                      }).toList();
                    }
                  }

                  return BaseLayout(
                    onWillPop: () {
                      Navigator.pop(context, 'orderPositionsScreen');
                    return  Future.value(false);
                    },
                    isAppBar: true,
                    isBottomNav: false,
                    isFloatingContainer: false,
                    appBarTitle:
                        'Накладная № ${orderDetailsPosition.invoice}/${Utils().monthParse(milliseconds: orderDetailsPosition.addedAt)}',
                    flexibleContainerChild: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichSpanText(
                                  spanText: SnapTextModel(
                                      title: 'Адрес: ',
                                      data: orderDetailsPosition.objectName,
                                      postTitle: '')),
                              RichSpanText(
                                  spanText: SnapTextModel(
                                      title: 'Всего позиций: ',
                                      data: orderPositionsList.length.toString(),
                                      postTitle: '')),
                              RichSpanText(
                                  spanText: SnapTextModel(
                                      title: 'Сумма: ',
                                      data: Utils().numberParse(value: currentTotal),
                                      postTitle: ' UZS')),
                              RichSpanText(
                                  spanText: SnapTextModel(
                                      title: 'Всего принятых позиций: ',
                                      data: orderListForPrint.length.toString(),
                                      postTitle: '')),
                              RichSpanText(
                                  spanText: SnapTextModel(
                                      title: 'Сумма принятых позиций: ',
                                      data: Utils().numberParse(value: actualTotal),
                                      postTitle: ' UZS')),
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ChipButton(
                                    lable: 'В корзину',
                                    avatar: const Icon(Icons.add_shopping_cart, color: Colors.white),
                                    onTap: () async {
                                      await _createCartData(
                                        ref: ref,
                                        projectRootId:
                                        orderDetailsPosition.projectRootId,
                                        orderPositionsList: orderPositionsList,
                                        place: placeData,
                                      ).whenComplete(() {
                                        Navigation()
                                            .navigateToCartScreen(
                                          context,
                                          IntentRootPlaceArgs(
                                            rootUserModel: rootUser,
                                            placeModel: placeData,
                                            fromWhichScreen:
                                            'orderPositionsScreen',
                                          ),
                                        )
                                            .then((value) {
                                          Navigator.pop(context);
                                          //setState(() {});
                                        });
                                      });
                                    }),
                              ),

                              const SizedBox(
                                width: 6.0,
                              ),
                              Consumer(
                                builder: (BuildContext context, WidgetRef ref,
                                    Widget? child) {
                                  OrderFBServices dbs = OrderFBServices();
                                  String customerId =
                                      orderDetailsPosition.userId;
                                  String objectId =
                                      orderDetailsPosition.objectId;
                                  String orderId = orderDetailsPosition.docId!;

                                  List<num> successStatusList = ref
                                      .watch(ordersPositionListProvider)
                                      .map((e) => e.successStatus)
                                      .toList();
                                  bool isAllSuccessStatus =
                                      (!successStatusList.contains(1) &&
                                          !successStatusList.contains(2) &&
                                          !successStatusList.contains(4));
                                  bool isAllSuccessStatus2 =
                                      (!successStatusList.contains(1) &&
                                          !successStatusList.contains(2) &&
                                          successStatusList.contains(4));

                                  if (!successStatusList.contains(0)) {
                                    if (isAllSuccessStatus) {
                                      //заявка полностью закрыта
                                      dbs
                                          .updateOrderStatus2(
                                        customerId: customerId,
                                        objectId: objectId,
                                        orderId: orderId,
                                        orderStatus: 3,
                                      )
                                          .whenComplete(() {
                                        List<num> ordersStatusList = ref
                                            .watch(ordersDetailListProvider)
                                            .map((e) => e.orderStatus)
                                            .toList();

                                        print(
                                            '------------ordersStatusList-----------------');
                                        print(ordersStatusList);
                                      });
                                    } else if (isAllSuccessStatus2) {
                                      //заявка закрыта, но имеются отмененные позиции
                                      dbs
                                          .updateOrderStatus2(
                                        customerId: customerId,
                                        objectId: objectId,
                                        orderId: orderId,
                                        orderStatus: 4,
                                      )
                                          .whenComplete(() {
                                        List<num> ordersStatusList = ref
                                            .watch(ordersDetailListProvider)
                                            .map((e) => e.orderStatus)
                                            .toList();

                                        print(
                                            '------------ordersStatusList--2---------------');
                                        print(ordersStatusList);
                                      });
                                    }
                                  }
                                  return  Expanded(
                                    child: ChipButton(
                                        lable: 'Принять все',
                                        avatar: const Icon(Icons.add_box_outlined, color: Colors.white,),
                                        onTap: () {
                                          _acceptanceStatusDialog(
                                              onTap: () async {
                                                ref.read(progressBoolProvider.notifier).updateProgressBool(true);

                                                await _acceptanceOrdersAllPosition(
                                                    ref: ref,
                                                    customerId: customerId,
                                                    objectId: objectId,
                                                    orderId: orderId,
                                                    orderList:
                                                    orderPositionsList,
                                                    fbs: dbs)
                                                    .then((value) async {
                                                  ref
                                                      .read(progressBoolProvider
                                                      .notifier)
                                                      .updateProgressBool(false);
                                                }).then((value) {
                                                  FocusScope.of(context)
                                                      .requestFocus(FocusNode());
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                });
                                              });
                                        }),
                                  );
                                },
                              ),
                              const SizedBox(
                                width: 6.0,
                              ),
                              Expanded(
                                child: ChipButton(
                                    lable: 'Распечатать',
                                    avatar: const Icon(Icons.print, color: Colors.white,),
                                    onTap: () async {

                                      if(orderListForPrint.isNotEmpty){

                                        final data = await PdfService().createDocument(
                                          orderPositionsList: orderListForPrint,
                                          invoice: invoiceName,
                                          total: actualTotal,
                                          objectName:
                                          orderDetailsPosition.objectName,
                                          createDate: Utils().dateTimeParse(
                                              milliseconds:
                                              orderDetailsPosition.addedAt),
                                          acceptedDate: acceptedDate,
                                        );
                                        PdfService().savePdfFile(
                                            fileName: fileName, byteList: data);
                                      }
                                      else {
                                        Get.snackbar('Нет принятых позиций!', 'Нет принятых позиций!');
                                      }


                                }),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          buildSearch(
                              categoryPressed: () {},
                              onTapJoinPosition: () {},
                              onTapCart: () {}),
                        ],
                      ),
                    ),
                    flexibleSpaceBarTitle: const SizedBox.shrink(),
                    slivers: [
                      _contentListView(
                        context: context,
                        ref: ref,
                        orderPositionsList: orderPositionsList,
                        orderDetailsPosition: orderDetailsPosition,
                      )
                    ],
                    isProgress: ref.watch(progressBoolProvider),
                    isPinned: false,
                    radiusCircular: 0.0,
                    flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
                    expandedHeight: 230.0,
                  );
                },
                error: (_, __) => const Placeholder(),
                loading: () => const ProgressMiniSplash());
      },
    );
  }

  Widget buildSearch({
    required VoidCallback categoryPressed,
    required VoidCallback onTapJoinPosition,
    required VoidCallback onTapCart,
  }) =>
      SearchWidget(
        text: 'query',
        hintText: 'Поиск',
        onChanged: searchBook,
        isAdditionalBtn: false,
      );

  void searchBook(String query) {
    final books = orderPositionsList.where((book) {
      final titleLower = book.productName.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    if (query.isNotEmpty) {
      orderPositionsList = books;
    } else {
      setState(() {
        orderPositionsList = [];
      });
    }
    setState(() {
      this.query = query;
    });
  }

  Future<void> _acceptanceStatusDialog({
    required VoidCallback onTap,
  }) async {
    AppStyles styles = AppStyles.appStyle(context);
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
          title: const Text('Внимание!'),
          content: Text(
            'Все позиции по текущей накладной прнятые без контрольной проверки, возврату или замене не подлежат',
            style: styles.worningTextStyle,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: onTap,
              child: const Text('Принять'),
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

  Future<void> _acceptanceOrdersAllPosition({
    required WidgetRef ref,
    required OrderFBServices fbs,
    required String customerId,
    required String objectId,
    required String orderId,
    required List<OrderModel> orderList,
  }) async {
    //OrderFBServices fbs = OrderFBServices();

    List<OrderModel> orderPositionList =
        orderList.where((element) => element.successStatus == 2).toList();

    if (orderPositionList.isNotEmpty) {
      await fbs
          .acceptanceOrdersAllPosition(
              userId: customerId,
              placeId: objectId,
              orderId: orderId,
              successStatus: 3,
              currentOrderList: orderPositionList)
          .then((String value) async {});
    } else {
      Get.snackbar('', 'Нет позиций для принятия');
    }
  }
}


Future<void> _createCartData({
  required WidgetRef ref,
  required String projectRootId,
  required List<OrderModel> orderPositionsList,
  required PlaceModel place,
}) async {
//фиксируем выбранный объект для сравнения с объектом в корзине при добавлении позиции
  ref.read(currentPlaceProvider.notifier).createPlace(place);
  ref.read(orderListProvider.notifier).clean();
  ref.read(multipleCartListProvider.notifier).clean();

  for (OrderModel element in orderPositionsList) {
    element.successStatus = 0;
    await ref
        .read(multipleCartListProvider.notifier)
        .addCartPosition(projectRootId, element);
  }

  await ref
      .read(multipleCartListProvider.notifier)
      .setCustomer(MultipleCartModel(
        projectRootId: projectRootId,
        projectRootName: '',
        currentCartList: [],
        customerId: place.docId!,
        customerName: place.placeName,
      ));

  List<MultipleCartModel> multipleCartList =
      ref.watch(multipleCartListProvider);

  if (multipleCartList.isNotEmpty) {
    List<String> cartIdList =
        multipleCartList.map((e) => e.projectRootId).toList();

    if (cartIdList.contains(projectRootId)) {
      for (var element in multipleCartList) {
        if (element.projectRootId == projectRootId) {
          ref
              .read(orderListProvider.notifier)
              .updateCurrentCart(element.currentCartList);
        }
      }
    }
  } else {
    return;
  }
}

Widget _contentListView({
  required BuildContext context,
  required WidgetRef ref,
  required List<OrderModel> orderPositionsList,
  required OrderDetailsModel orderDetailsPosition,
}) {
  AppStyles styles = AppStyles.appStyle(context);

  return SliverPadding(
    padding: const EdgeInsets.all(6.0),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: orderPositionsList.length,
        (BuildContext context, int index) {
          num amountSum = orderPositionsList[index].amountSum;

          num lastDiscountPercent =
              orderPositionsList[index].lastDiscountPercent;
          num lastPercent = (amountSum * lastDiscountPercent) / 100;

          num lastAmountSum =
              (orderPositionsList[index].amountSum - lastPercent);

          num price = orderPositionsList[index].productPrice;

          return Stack(children: [
            Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              decoration: styles.positionBoxDecoration,
              child: Column(
                children: [
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderPositionsList[index].productName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Divider(),
                        RichSpanText(
                            spanText: SnapTextModel(
                                title: 'Количество: ',
                                data: Utils().numberParse(
                                    value: orderPositionsList[index]
                                        .productQuantity),
                                postTitle:
                                    ' ${orderPositionsList[index].productMeasure}')),
                        RichSpanText(
                            spanText: SnapTextModel(
                                title: 'Цена: ',
                                data: Utils().numberParse(value: price),
                                postTitle: ' UZS / ${orderPositionsList[index].productMeasure}')),
                        RichSpanText(
                            spanText: SnapTextModel(
                                title: 'Скидка: ',
                                data: orderPositionsList[index]
                                    .discountPercent
                                    .toString(),
                                postTitle: ' %')),
                        RichSpanText(
                            spanText: SnapTextModel(
                                title: 'Экстра скидка: ',
                                data: lastDiscountPercent.toString(),
                                postTitle: ' %')),
                        RichSpanText(
                            spanText: SnapTextModel(
                                title: 'Сумма: ',
                                data: Utils().numberParse(value: lastAmountSum),
                                postTitle: ' UZS')),
                      ],
                    ),
                  ),

                  _orderButton(
                      context: context,
                      ref: ref,
                      orderDetailsPosition: orderDetailsPosition,
                      orderPosition: orderPositionsList[index]),
                ],
              ),
            ),
            if (orderPositionsList[index].successStatus == 4)
              Positioned(
                left: 0.0,
                top: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  decoration: const BoxDecoration(
                      color: Colors.black12,
                      //border: Border.all(width: 3.0, color: Colors.deepOrange),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                ),
              )
          ]);
        },
      ),
    ),
  );
}

Widget _orderButton({
  required BuildContext context,
  required WidgetRef ref,
  required OrderDetailsModel orderDetailsPosition,
  required OrderModel orderPosition,
}) {
  AppStyles styles = AppStyles.appStyle(context);
  orderPosition.objectId = orderDetailsPosition.objectId;
  orderPosition.orderId = orderDetailsPosition.docId;
  orderPosition.customerId = orderDetailsPosition.userId;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    width: double.infinity,
    child: orderPosition.successStatus == 0
        ? Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Ожидание отгрузки...',
              style: styles.worningTextStyle,
            ))
        : orderPosition.successStatus == 2
            ? SingleButton(
                title: 'Принять позицию',
                onPressed: () {
                  Navigation()
                      .navigationToAcceptPositionScreen(context, orderPosition);
                })
            : orderPosition.successStatus == 3
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Позиция принята',
                      style: styles.worningTextStyle,
                    ))
                : orderPosition.successStatus == 4
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          orderPosition.rejectionReason,
                          style: styles.worningTextStyle,
                        ))
                    : null,
  );
}
