import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';
import 'package:ya_bazaar/res/pdf_service.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/purchases/purchase_services/purchase_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/chip_btn.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/search_widget.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class RootOrderPositionsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'rootOrderPositionsScreen';

  final OrderDetailsModel orderDetailsPosition;

  const RootOrderPositionsScreen({
    super.key,
    required this.orderDetailsPosition,
  });

  @override
  RootOrderPositionsScreenState createState() =>
      RootOrderPositionsScreenState();
}

class RootOrderPositionsScreenState
    extends ConsumerState<RootOrderPositionsScreen> {
  //OrderFBServices dbs = OrderFBServices();
  TextEditingController debtRepaymentController = TextEditingController();

  late OrderDetailsModel orderDetailsPosition;

  List<OrderModel> orderPositionsList = [];
  String query = '';

  late num total = 0;
  late num firstTotal = 0;
  late num incomeTotal = 0;

  @override
  void initState() {
    orderDetailsPosition = widget.orderDetailsPosition;
    total = orderDetailsPosition.totalSum;
    super.initState();
  }

  bool isCanPop = false;

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        List<OrderModel> orderListForPrint = [];
        //orderDetailsPosition.projectRootId = ref.watch(currentUserProvider).rootId!;

        ref
            .watch(orderPositionsForRootProvider(orderDetailsPosition))
            .whenData((positionData) {
          ref.read(ordersPositionListProvider.notifier)
            ..clearOrderPositionsList()
            ..buildOrderPositionsListForRoot(positionData,);
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
        });

        //подсчитываем total из контроллера для динамического изменения
        // if (ref.watch(ordersPositionListProvider).isNotEmpty) {
        //   total = ref
        //       .watch(ordersPositionListProvider)
        //       .map((e) => e.amountSum)
        //       .reduce((value, element) => value + element)
        //       .toDouble();
        //
        //   total2 = ref
        //       .watch(ordersPositionListProvider)
        //       .map((e) => e.firstPrice! * e.productQuantity)
        //       .reduce((v, e) => v + e)
        //       .toDouble();
        //
        //   incomeTotal = (total - total2);
        // }
        String fileName = orderDetailsPosition.objectName;
        String invoiceName =
            '${orderDetailsPosition.invoice}/${Utils().monthParse(milliseconds: orderDetailsPosition.invoice)}';

        String acceptedDate = 'Черновик';
        if (orderDetailsPosition.orderStatus == 2) {
          acceptedDate = Utils()
              .dateTimeParse(milliseconds: orderDetailsPosition.requestDate);
        }

        if (ref.watch(ordersPositionListProvider).isNotEmpty) {
          orderListForPrint = ref
              .watch(ordersPositionListProvider)
              .where((element) => element.successStatus != 4)
              .toList();
          if (orderListForPrint.isNotEmpty) {
            total = orderListForPrint.map((e) {
              num lastPercentSum = (e.amountSum * e.lastDiscountPercent) / 100;
              return (e.amountSum - lastPercentSum);
            }).reduce((value, element) => value + element);

            List<num> firstAmountsList = orderListForPrint
                .map((e) => e.firstPrice! * e.productQuantity)
                .toList();

            firstTotal = firstAmountsList.reduce((v, e) => v + e);
            incomeTotal = (total - firstTotal);
            // нумеруем позиции для накладной
            for (int i = 0; i < orderListForPrint.length; i++) {
              orderListForPrint[i].index = i + 1;
            }
          }
        }

        return BaseLayout(
          onWillPop: () async {
            if (orderDetailsPosition.totalSum != total) {
              await _updateOrderTotalSum2(
                      customerId: orderDetailsPosition.userId,
                      objectId: orderDetailsPosition.objectId,
                      orderId: orderDetailsPosition.docId!,
                      totalSum: total).then((value) => Navigator.pop(context));
            } else {
              Navigator.pop(context);
            }
            return Future.value(false);
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
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Заказчик: ',
                        data: orderDetailsPosition.objectName,
                        postTitle: '')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Всего позиций: ',
                        data: orderListForPrint.length.toString(),
                        postTitle: '')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Сумма закупа: ',
                        data: Utils().numberParse(value: firstTotal),
                        postTitle: ' UZS')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Сумма отпуска: ',
                        data: Utils().numberParse(value: total),
                        postTitle: ' UZS')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Оплачено: ',
                        data: Utils().numberParse(value: orderDetailsPosition.debtRepayment),
                        postTitle: ' UZS')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Задолжность: ',
                        data: Utils().numberParse(value: (total - orderDetailsPosition.debtRepayment)),
                        postTitle: ' UZS')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Прибыль: ',
                        data: Utils().numberParse(value: incomeTotal),
                        postTitle: ' UZS (${Utils()
                            .numberParse(value: (incomeTotal / total) * 100)} %)')),

                const SizedBox(height: 16.0,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(orderDetailsPosition.orderStatus > 2 && orderDetailsPosition.orderStatus < 5)
                    Expanded(child: EditText(
                      labelText: 'Сумма оплаты',
                      controller: debtRepaymentController,
                      suffixIconBtn:  IconButton(
                        onPressed: () async {
                          String debtRepaymentStr = debtRepaymentController.text.trim();
                          num currentDebtRepayment = num.parse(debtRepaymentStr);
                          num newDebtRepayment = (orderDetailsPosition.debtRepayment + currentDebtRepayment);

                          print('total: $total');
                          print('newDebtRepayment: $newDebtRepayment');

                          if(newDebtRepayment <= total){
                            if(debtRepaymentStr.isNotEmpty){
                              await _debtRepayment(
                                customerId: orderDetailsPosition.userId,
                                objectId: orderDetailsPosition.objectId,
                                orderId: orderDetailsPosition.docId!,
                                debtRepaymentSum: newDebtRepayment,
                              ).then((value) {
                                debtRepaymentController.text = '';
                                FocusScope.of(context).requestFocus(FocusNode());
                                Navigator.pop(context);
                              });
                            }
                          }
                          else {
                            Get.snackbar('Сумма превышена!', 'Сумма превышена!');
                          }

                        },
                        icon: const Icon(Icons.monetization_on,color: Colors.grey,),
                      ),
                    textInputType: TextInputType.number,
                    onChanged: (v){},)),
                    Expanded(
                      child: ChipButton(
                          lable: 'Распечатать',
                          avatar: const Icon(
                            Icons.print,
                            color: Colors.white,
                          ),
                          onTap: () async {
                            final data = await PdfService().createDocument(
                              orderPositionsList: orderListForPrint,
                              invoice: invoiceName,
                              total: total,
                              objectName: orderDetailsPosition.objectName,
                              createDate: Utils().dateTimeParse(
                                  milliseconds: orderDetailsPosition.addedAt),
                              acceptedDate: acceptedDate,
                            );
                            PdfService()
                                .savePdfFile(fileName: fileName, byteList: data);
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
          slivers: [_contentListView(orderPositionsList: orderPositionsList)],
          isProgress: ref.watch(progressBoolProvider),
          isPinned: false,
          radiusCircular: 0.0,
          flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
          expandedHeight: 278.0,
        );
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

  Widget _contentListView({required List<OrderModel> orderPositionsList}) {
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

            num quantity = orderPositionsList[index].productQuantity;
            num price = orderPositionsList[index].productPrice;
            num firstPrice = orderPositionsList[index].firstPrice!;
            num firstpriceAmount = (firstPrice * quantity);
            num income = (amountSum - firstpriceAmount);

            return Stack(children: [
              Container(
                margin: const EdgeInsets.only(bottom: 6.0),
                decoration: styles.positionBoxDecoration!,
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
                                  title: 'Отпускная цена: ',
                                  data: Utils().numberParse(value: price),
                                  postTitle: ' UZS')),
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
                                  title: 'Сумма с скидкой: ',
                                  data: Utils().numberParse(value: amountSum),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Сумма с экстра скидкой: ',
                                  data:
                                      Utils().numberParse(value: lastAmountSum),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Закупочная цена: ',
                                  data: Utils().numberParse(
                                      value:
                                          orderPositionsList[index].firstPrice),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Сумма по закуп цене: ',
                                  data: Utils()
                                      .numberParse(value: firstpriceAmount),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Прибыль: ',
                                  data: Utils().numberParse(value: income),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Процент: ',
                                  data: Utils().numberParse(
                                      value: (income / amountSum) * 100),
                                  postTitle: ' %')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Статус: ',
                                  data: orderPositionsList[index]
                                      .successStatus
                                      .toString(),
                                  postTitle: ' %')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Возврат: ',
                                  data: orderPositionsList[index]
                                      .returnQty
                                      .toString(),
                                  postTitle:
                                      ' ${orderPositionsList[index].productMeasure}')),
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
              if (orderPositionsList[index].successStatus != 4)
                Positioned(
                    right: 8.0,
                    bottom: 60.0,
                    child: SingleButton(
                        title: 'экстра %',
                        onPressed: () {
                          if (orderPositionsList[index].successStatus >= 2) {

                            if(ref.watch(currentUserProvider).userRoles!.contains('admin')){
                              _exDiscountDialog(
                                productName:
                                orderPositionsList[index].productName,
                                onTap: (String percentValue) async {
                                  ref
                                      .read(progressBoolProvider.notifier)
                                      .updateProgressBool(true);

                                  OrderFBServices fbs = OrderFBServices();

                                  String customerId =
                                  orderPositionsList[index].customerId!;
                                  String objectId =
                                  orderPositionsList[index].objectId!;
                                  String orderId =
                                  orderPositionsList[index].orderId!;
                                  String positionId =
                                  orderPositionsList[index].docId!;

                                  num lPercent = num.parse(percentValue);
                                  num percentSum = (amountSum * lPercent) / 100;
                                  num lastAmount = (amountSum - percentSum);

                                  await fbs
                                      .addLastDiscountPercent(
                                      customerId: customerId,
                                      objectId: objectId,
                                      orderId: orderId,
                                      positionId: positionId,
                                      lastDiscountPercent: lPercent,
                                      amountSum: lastAmount)
                                      .then((value) async {
                                    // await _updateOrderTotalSum(
                                    //     fbs: fbs,
                                    //     customerId: customerId,
                                    //     objectId: objectId,
                                    //     orderId: orderId,
                                    //     orderList: orderPositionsList);
                                  }).then((value) {
                                    ref
                                        .read(progressBoolProvider.notifier)
                                        .updateProgressBool(false);
                                  }).then((value) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    Navigator.pop(
                                      context,
                                    );
                                  });

                                },
                              );
                            }
                            else {
                              Get.snackbar('Ошибка!','Вы не можете принять доставку!');
                            }

                          }
                          else {
                            Get.snackbar('', 'Позициция не отгружена');
                          }
                        }))
              else
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    decoration: const BoxDecoration(
                        //border: Border.all(width: 2.0, color: Colors.deepOrange),
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                )
            ]);
          },
        ),
      ),
    );
  }

  Future<void> _exDiscountDialog({
    required String productName,
    required Function onTap,
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
          title: Column(
            children: [
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Установить скидку: ', data: '', postTitle: '')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: '', data: productName, postTitle: '')),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(3.0),
            child: EditText(
              controller: TextEditingController(),
              textInputType: TextInputType.number,
              labelText: '%',
              onChanged: (v) {
                setState(() {
                  percentValue = v;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () => onTap(percentValue),
              child: const Text('Применить'),
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

  Future<void> _updateOrderTotalSum2({
    required String customerId,
    required String objectId,
    required String orderId,
    required num totalSum,
  }) async {
    OrderFBServices fbs = OrderFBServices();
    await fbs.updateOrderTotalSum(
        customerId: customerId,
        objectId: objectId,
        orderId: orderId,
        totalSum: totalSum);
  }

  Future<void> _debtRepayment({
    required String customerId,
    required String objectId,
    required String orderId,
    required num debtRepaymentSum,
  }) async {
    OrderFBServices fbs = OrderFBServices();
    await fbs.debtRepayment(
        customerId: customerId,
        objectId: objectId,
        orderId: orderId,
        debtRepaymentSum: debtRepaymentSum,
        orderStatus: (total == debtRepaymentSum) ? 5 :  null);
  }

Widget _orderButton({
  required BuildContext context,
  required WidgetRef ref,
  required OrderDetailsModel orderDetailsPosition,
  required OrderModel orderPosition,
}) {
  orderPosition.objectId = orderDetailsPosition.objectId;
  orderPosition.orderId = orderDetailsPosition.docId;
  orderPosition.customerId = orderDetailsPosition.userId;
  AppStyles styles = AppStyles.appStyle(context);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    width: double.infinity,
    child: orderPosition.returnQty > 0
        ? SingleButton(
            title: 'Вернуть на склад: ${orderPosition.returnQty} / ${orderPosition.productMeasure}',
            onPressed: () async{


              if(ref.watch(currentUserProvider).userRoles!.contains('warehouseManager')){
                await PurchaseFBServices().returnQtyProduct(
                  projectRootId: orderPosition.projectRootId,
                  productId: orderPosition.productId,
                  returnQty: orderPosition.returnQty,
                  customerId: orderPosition.customerId!,
                  objectId: orderPosition.objectId!,
                  orderId: orderPosition.orderId!,
                  positionId: orderPosition.docId!,
                );
              }
              else {
                Get.snackbar('У Вас нет доступа!', 'У Вас нет доступа!');
              }


            })
        : orderDetailsPosition.orderStatus == 0
            ? Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ожидание доставщика',
                  style: styles.worningTextStyle,
                ))
            : (orderDetailsPosition.orderStatus == 1 &&
                    orderPosition.successStatus == 0)
                ? SingleButton(
                    title: 'Отгрузить позицию',
                    onPressed: () {

                      if(ref.watch(currentUserProvider).userRoles!.contains('warehouseManager')){
                        Navigation().navigationToShipmentPositionScreen(
                            context, orderPosition);
                      }
                      else {
                        Get.snackbar('Ошибка!','Вы не можете отгрузить позицию!');
                      }

                    })
                : orderPosition.successStatus == 2
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Позиция отгружена',
                          style: styles.worningTextStyle,
                        ))
                    : orderPosition.successStatus == 3
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Позиция принята клиентом',
                              style: styles.worningTextStyle,
                            ))
                        : orderPosition.successStatus == 4
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  orderPosition.rejectionReason,//причина отказа
                                  style: styles.worningTextStyle,
                                ))
                            : const SizedBox.shrink(),
  );
}

  Future<num> _createTotalSum({
    required List<OrderModel> orderList,
  }) async {
    num totalSum = 0;
    List<OrderModel> sortList =
    orderList.where((element) => element.successStatus != 4).toList();
    List<num> amountList = sortList.map((e) => e.amountSum).toList();
    if (amountList.isNotEmpty) {
      totalSum = amountList.reduce((val, elem) => val + elem);
    }
    return totalSum;
  }
}

Future<void> _updateOrderTotalSum({
  required OrderFBServices fbs,
  required String customerId,
  required String objectId,
  required String orderId,
  required List<OrderModel> orderList,
}) async {
  num totalSum = 0;
  List<OrderModel> sortList =
  orderList.where((element) => element.successStatus != 4).toList();
  List<num> amountList = sortList.map((e) => e.amountSum).toList();
  if (amountList.isNotEmpty) {
    totalSum = amountList.reduce((val, elem) => val + elem);
  }

  await fbs.updateOrderTotalSum(
      customerId: customerId,
      objectId: objectId,
      orderId: orderId,
      totalSum: totalSum);
}
