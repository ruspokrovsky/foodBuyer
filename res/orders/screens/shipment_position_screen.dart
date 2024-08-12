import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/discount_list_view.dart';
import 'package:ya_bazaar/res/widgets/product_control_form.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class ShipmentPositionScreen extends ConsumerStatefulWidget {
  static const String routeName = 'shipmentPositionScreen';
  final OrderModel orderModel;

  const ShipmentPositionScreen({super.key, required this.orderModel});

  @override
  ShipmentPositionScreenState createState() => ShipmentPositionScreenState();
}

class ShipmentPositionScreenState extends ConsumerState<ShipmentPositionScreen> {

  OrderFBServices fbs = OrderFBServices();
  Utils utils = Utils();
  PositionModel? positionModel;
  late OrderModel orderModel;

  TextEditingController actualPriceController = TextEditingController();
  TextEditingController actualQtyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  num actualPrice = 0.0;
  num positionQty = 0.0;
  num amount = 0.0;
  String imgUrl = '';

  late DiscountModel discountArgs;
  late num actualDiscountPercent = 0;

  //late StreamSubscription subscription;

  late GetPositionArgs getPositionArgs;
  late DiscountModel getDiscountArgs;

  @override
  void initState() {
    orderModel = widget.orderModel;
    getPositionArgs = GetPositionArgs(
      rootId: orderModel.projectRootId,
      positionId: orderModel.productId,);
    getDiscountArgs = DiscountModel(
        rootId: orderModel.projectRootId,
        positionId: orderModel.productId,
        quantity: 0,
        percent: 0);

    if (actualQtyController.text.isEmpty) {
      //amount = (positionModel.productPrice * orderModel.productQuantity);
      positionQty = orderModel.productQuantity;
      actualQtyController.text = positionQty.toString();
    }






    //getPositionsById();
    super.initState();
  }

  // Future<void> getPositionsById() async {
  //   //при отгрузки товара клиенту необходимо получить актуальную на текущий момент цену из склада(AllPosition) т.к.
  //   // цена закупа могла измениться
  //
  //   var streamAllPosition
  //   = fbs.getPositionById(
  //       getPositionArgs: GetPositionArgs(rootId: orderModel.projectRootId, positionId: orderModel.productId,));
  //
  //   subscription = streamAllPosition.listen((snap) async {
  //       positionModel = PositionModel.snapFromDoc(snap);
  //       imgUrl = positionModel.productImage;
  //       // actualPrice = positionModel.productPrice;
  //       // if (actualQtyController.text.isEmpty) {
  //       //   amount = (positionModel.productPrice * orderModel.productQuantity);
  //       //   positionQty = orderModel.productQuantity;
  //       // }
  //       // actualQtyController.text = orderModel.productQuantity.toString();
  //       //await updateAmount();
  //       setState(() {});
  //     },
  //   );
  // }

  void _updateAmount({
    required List<DiscountModel> discountList,
    required num productPrice,
  }) {

    //positionData.discountList = ref.watch(discountListProvider);

    print(discountList);

    num amount1 = (positionQty * productPrice);
    // Переменная для хранения последней примененной скидки
    num? lastAppliedDiscountPersent;
    // Если есть скидки
    if (discountList.isNotEmpty) {
      discountList.sort((a, b) => a.quantity.compareTo(b.quantity));
      for (var discount in discountList) {
        if (positionQty >= discount.quantity) {
          // Сохраняем последнюю примененную скидку
          lastAppliedDiscountPersent = discount.percent;
        }
      }
    }
    // Если была применена хотя бы одна скидка, пересчитываем сумму с учетом последней скидки
    if (lastAppliedDiscountPersent != null) {
      double persentSum2 = (productPrice * lastAppliedDiscountPersent) / 100;
      // Присваеваем цену со скидкой для view
      actualPrice = (productPrice - persentSum2);
      actualDiscountPercent = lastAppliedDiscountPersent;
      double persentSum = (amount1 * lastAppliedDiscountPersent) / 100;
      amount1 -= persentSum;
    }else{
      actualPrice = productPrice;
      actualDiscountPercent = 0;
    }
    // Обновляем сумму после применения всех скидок (или без них)
    amount = amount1;

    ref.read(ordersPositionListProvider.notifier)
        .updateAmount(
        positionId: widget.orderModel.docId!,
        amount: amount,
        discountPercent: actualDiscountPercent);
  }


  @override
  void dispose() {
    //subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {

        return ref.watch(getPositionByIdProvider3(getPositionArgs)).when(
            data: (data){

              positionModel = PositionModel.snapFromDoc(data);

              ref.watch(getPositionsDiscountProvider(getDiscountArgs)).whenData((value) {
                ref.read(discountListProvider.notifier)
                  ..clean()
                  ..buildPositionDiscountList(value);

                _updateAmount(
                  discountList: ref.watch(discountListProvider),
                  productPrice: positionModel!.productPrice, );
              });

              List<num> successStatusList = ref.watch(ordersPositionListProvider).map((e) => e.successStatus).toList();
              bool isAllSuccessStatus = (!successStatusList.contains(0) && !successStatusList.contains(1));

              if(isAllSuccessStatus){
                //заявка полностью закрыта
                _updateOrderStatus(customerId: orderModel.customerId!, objectId: orderModel.objectId!, orderId: orderModel.orderId!, orderStatus: 2);
              }

              return BaseLayout(
                onWillPop: (){
                  Navigator.pop(context, 'shipmentPositionScreen');
                  return Future.value(false);
                },
                isAppBar: true,
                appBarTitle: 'Отгрузка позиции',
                isBottomNav: false,
                isFloatingContainer: false,
                flexibleContainerChild: DiscountListView(
                  arguments: DiscountModel(
                      rootId: orderModel.projectRootId,
                      positionId: orderModel.productId,
                      quantity: 0,
                      percent: 0),),
                flexibleSpaceBarTitle: const SizedBox.shrink(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ProductControlForm(
                              whoScreen: 'acceptPositionScreen',
                              strPositionPrice:
                              'Цена: ${utils.numberParse(value: positionModel!.productPrice)} UZS\nс скидкой: ${utils.numberParse(value: actualPrice)}',
                              actualQtyController: actualQtyController,
                              actualPriceController: TextEditingController(),
                              descriptionController: descriptionController,
                              strAmount: utils.numberParse(value: amount),
                              strQtyTitle: 'Количество: $positionQty\n на складе: ${positionModel!.productQuantity}',
                              strProductName: widget.orderModel.productName,
                              strSelectedQty: '',
                              productMeasure: ' /${widget.orderModel.productMeasure}',
                              positionPrice: '',
                              onChangedPrice: (value) {},
                              onChangedQuantity: (value) {
                                if (value.isNotEmpty) {
                                  positionQty = double.parse(value.replaceAll(',', '.'));
                                } else {
                                  positionQty = 0.0;
                                }
                                //updateAmount();
                                //amount = (positionQty * positionModel.productPrice);
                                //ref.read(ordersPositionListProvider.notifier).updateAmount(widget.orderModel.docId!, amount);
                                setState(() {});
                              },
                              imageUrl: imgUrl,
                              bottom: TwoButtonsBlock(
                                  positiveText: 'Отгрузить',
                                  positiveClick: () async {
                                    if (positionQty != 0.0) {

                                      if(positionModel!.productQuantity < positionQty){
                                        Get.snackbar('Не достаточное количество на складе!','Не достаточное количество на складе!');
                                      }
                                      else {
                                        ref.read(progressBoolProvider.notifier).updateProgressBool(true);
                                        await fbs.updateShipmentOrders(
                                            rootId: orderModel.projectRootId,
                                            customerId: orderModel.customerId!,
                                            objectId: orderModel.objectId!,
                                            orderId: orderModel.orderId!,
                                            positionId: orderModel.docId!,
                                            productId: orderModel.productId,
                                            firsPrice: positionModel!.productFirsPrice,
                                            actualPrice: positionModel!.productPrice,
                                            amountSum: amount,
                                            productQuantity: positionQty,
                                            successStatus: 2,
                                            currentOrderList: ref.watch(ordersPositionListProvider),
                                            actualDiscountPercent: actualDiscountPercent)
                                            .whenComplete(() {
                                          ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          Navigator.pop(context,'shipmentPositionScreen');
                                        });
                                      }
                                    }
                                    else {
                                      Get.snackbar('Внимание!', 'Добавте количество');
                                    }
                                  },
                                  negativeText: 'Отменить',
                                  negativeClick: (){
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    Navigator.pop(context);
                                  }),

                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
                isProgress: ref.watch(progressBoolProvider),
                expandedHeight: 0.0,
                flexContainerColor: Colors.transparent,
                isPinned: false,

              );
            },
            error: (_,__) => const Placeholder(),
            loading: () => const ProgressMiniSplash());

      },
      // child: Stack(
      //   children: [
      //     Scaffold(
      //       appBar: AppBar(
      //         title: Text('Отгрузка позиции',
      //           style: styles.appBarTitleTextStyle,),
      //       ),
      //       body: WillPopScope(
      //         onWillPop: () {
      //           Navigator.pop(context, 'shipmentPositionScreen');
      //           return Future.value(false);
      //         },
      //         child: Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: SingleChildScrollView(
      //             child: Column(
      //               children: [
      //                 ProductControlForm(
      //                   whoScreen: 'acceptPositionScreen',
      //                   strPositionPrice: 'Цена: ${utils.numberParse(value: actualPrice)}',
      //                   actualQtyController: actualQtyController,
      //                   actualPriceController: TextEditingController(),
      //                   descriptionController: descriptionController,
      //                   strAmount: utils.numberParse(value: amount),
      //                   strQtyTitle: 'Количество: $positionQty',
      //                   strProductName: widget.orderModel.productName,
      //                   strSelectedQty: '',
      //                   productMeasure: ' /${widget.orderModel.productMeasure}',
      //                   positionPrice: '',
      //                   onChangedPrice: (value) {},
      //                   onChangedQuantity: (value) {
      //
      //                     if (value.isNotEmpty) {
      //                       positionQty = double.parse(value);
      //                     } else {
      //                       positionQty = 0.0;
      //                     }
      //                     amount = (positionQty * positionModel.productPrice);
      //                     ref.read(ordersPositionListProvider.notifier).updateAmount(widget.orderModel.docId!, amount);
      //                     setState(() {});
      //                   },
      //                   imageUrl: imgUrl,
      //                   bottom: TwoButtonsBlock(
      //                       positiveText: 'Отгрузить',
      //                       positiveClick: () async {
      //                         if (positionQty != 0.0) {
      //                           ref.read(progressBoolProvider.notifier).updateProgressBool(true);
      //                           await fbs.updateShipmentOrders(
      //                               rootId: orderModel.projectRootId,
      //                               customerId: orderModel.customerId!,
      //                               objectId: orderModel.objectId!,
      //                               orderId: orderModel.orderId!,
      //                               positionId: orderModel.docId!,
      //                               actualPrice: actualPrice,
      //                               amountSum: amount,
      //                               productQuantity: positionQty,
      //                               successStatus: 1,
      //                               currentOrderList: ref.watch(ordersPositionListProvider))
      //                               .whenComplete(() {
      //                             ref.read(progressBoolProvider.notifier).updateProgressBool(false);
      //                             FocusScope.of(context).requestFocus(FocusNode());
      //                             Navigator.pop(context,'shipmentPositionScreen');
      //                           });
      //
      //                         } else {
      //                           Get.snackbar('Внимание!', 'Добавте количество');
      //                         }
      //                       },
      //                       negativeText: 'Отменить',
      //                       negativeClick: (){
      //                         FocusScope.of(context).requestFocus(FocusNode());
      //                         Navigator.pop(context);
      //                       }),
      //
      //                 ),
      //                 const SizedBox(
      //                   height: 20.0,
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //     ref.watch(progressBoolProvider)
      //     ?
      //         const ProgressDialog()
      //         :
      //         const SizedBox.shrink(),
      //   ],
      // ),
    );
  }

  Future<void>_updateOrderStatus({
    required int orderStatus,
    required String customerId,
    required String objectId,
    required String orderId,
  }) async {
    await fbs.updateOrderStatus2(customerId: customerId, objectId: objectId, orderId: orderId, orderStatus: orderStatus,);
  }
}


