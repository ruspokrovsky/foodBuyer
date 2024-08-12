import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/product_control_form.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/three_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class AcceptPositionScreen extends ConsumerStatefulWidget {
  static const String routeName = 'acceptPositionScreen';
  final OrderModel orderModel;

  const AcceptPositionScreen({super.key, required this.orderModel});

  @override
  PurchaseState createState() => PurchaseState();
}

class PurchaseState extends ConsumerState<AcceptPositionScreen> {

  OrderFBServices fbs = OrderFBServices();

  late OrderModel orderPositionData;

  TextEditingController actualPriceController = TextEditingController();
  TextEditingController actualQtyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  double positionPrc = 0.0;
  double positionQty = 0.0;
  double factOrderedQty = 0.0;
  double amount = 0.0;
  int successStatus = 3;
  String rejectionReason = '';

  @override
  void initState() {

    orderPositionData = widget.orderModel;
    factOrderedQty = orderPositionData.productQuantity.toDouble();
    actualQtyController.text = orderPositionData.productQuantity.toString();
    amount = orderPositionData.amountSum.toDouble();
    positionPrc = orderPositionData.productPrice.toDouble();
    positionQty = orderPositionData.productQuantity.toDouble();

    if (actualQtyController.text.isEmpty) {
      amount = orderPositionData.amountSum.toDouble();
      positionQty = orderPositionData.productQuantity.toDouble();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Прием позиции',style: styles.appBarTitleTextStyle,),
      ),
      body: WillPopScope(
        onWillPop: () {

          Navigator.pop(context,'acceptPositionScreen');
          return Future.value(false);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                String imgUrl = '';
                List <num> ordersStatusList = [];
                List<OrderDetailsModel> orderDetailsList = ref.watch(ordersDetailListProvider).where((element) => element.projectRootId == orderPositionData.projectRootId).toList();



                List<num> successStatusList = ref.watch(ordersPositionListProvider).map((e) => e.successStatus).toList();

                bool isAllSuccessStatus = (!successStatusList.contains(1) && !successStatusList.contains(2) && !successStatusList.contains(4));
                bool isAllSuccessStatus2 = (!successStatusList.contains(1) && !successStatusList.contains(2) && successStatusList.contains(4));

                if(!successStatusList.contains(0)){
                  if(isAllSuccessStatus){
                    //заявка полностью закрыта
                    _updateOrderStatus(customerId: orderPositionData.customerId!, objectId: orderPositionData.objectId!, orderId: orderPositionData.orderId!, orderStatus: 3, orderList: ref.watch(ordersPositionListProvider), ordersStatusList:ordersStatusList);
                  }
                  else if(isAllSuccessStatus2){
                    //заявка закрыта, но имеются отмененные позиции
                    _updateOrderStatus(customerId: orderPositionData.customerId!, objectId: orderPositionData.objectId!, orderId: orderPositionData.orderId!, orderStatus: 4, orderList: ref.watch(ordersPositionListProvider), ordersStatusList:ordersStatusList);
                  }
                }
                print('ordersStatusList: $ordersStatusList');
                return Column(
                  children: [
                    ProductControlForm(
                      whoScreen: 'acceptPositionScreen',
                      strPositionPrice: 'Цена: ${positionPrc.toString()}',
                      actualQtyController: actualQtyController,
                      actualPriceController: actualPriceController,
                      descriptionController: descriptionController,
                      strAmount: Utils().numberParse(value: amount).toString(),
                      strQtyTitle: 'Количество: $positionQty',
                      strProductName: orderPositionData.productName,
                      strSelectedQty: '',
                      productMeasure: ' /${orderPositionData.productMeasure}',
                      positionPrice: '',
                      onChangedPrice: (value) {},
                      onChangedQuantity: (value) {
                        if (value.isNotEmpty) {
                          positionQty = double.parse(value.replaceAll(',', '.'));
                        } else {
                          positionQty = 0.0;
                        }
                        amount = (positionQty * orderPositionData.productPrice);
                        ref.read(ordersPositionListProvider.notifier)
                            .updateAmount(positionId: widget.orderModel.docId!, amount: amount);
                        setState(() {});
                      },
                      imageUrl: imgUrl,
                      bottom: Column(
                        children: [
                          const SizedBox(height: 20.0,),

                          ThreeButtonsBlock(
                              positiveText: 'Принять',
                              positiveClick: () async {
                                if (positionQty != 0.0) {

                                  await fbs.acceptanceOrdersPosition(
                                    customerId: orderPositionData.customerId!,
                                    rootId: orderPositionData.projectRootId,
                                    objectId: orderPositionData.objectId!,
                                    orderId: orderPositionData.orderId!,
                                    positionId: orderPositionData.docId!,
                                    productId: orderPositionData.productId,
                                    amountSum: amount,
                                    productQuantity: positionQty,
                                    factOrderedQty: factOrderedQty,
                                    currentOrderList: ref.watch(ordersPositionListProvider),
                                    successStatus: successStatus,
                                  ).then((value) {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    Navigator.pop(context,);
                                  });
                                } else {
                                  Get.snackbar('Внимание!', 'Добавте количество');
                                }
                              },
                              neutralText: 'Отменить позицию',
                              neutralClick: () async {
                                await _reasonDialog(
                                    onTap: (String reason) async {
                                      if(reason.isNotEmpty){
                                        setState(() {
                                          successStatus = 4;
                                          rejectionReason = reason;

                                        });
                                        await fbs.updateOrdersPositionStatus(
                                          customerId: orderPositionData.customerId!,
                                          objectId: orderPositionData.objectId!,
                                          orderId: orderPositionData.orderId!,
                                          positionId: orderPositionData.docId!,
                                          successStatus: successStatus,
                                          rejectionReason: rejectionReason,
                                        ).then((value) {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          Navigator.pop(context,);
                                        });
                                      }
                                    }).whenComplete(() => Navigator.pop(context,));

                              },
                              negativeText: 'Назад',
                              negativeClick: (){
                                FocusScope.of(context).requestFocus(FocusNode());
                                Navigator.pop(context);
                              }),
                        ],
                      ),

                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void>_updateOrderStatus({
    required int orderStatus,
    required String customerId,
    required String objectId,
    required String orderId,
    required List<OrderModel> orderList,
    required List<num> ordersStatusList,
  }) async {
    num totalSum = 0;
    List<OrderModel> sortList = orderList.where((element) => element.successStatus != 4).toList();
    List<num> amountList = sortList.map((e) => e.amountSum).toList();
    if(amountList.isNotEmpty){
      totalSum = amountList.reduce((val, elem) => val + elem);
    }




    await fbs.updateOrderStatus(customerId: customerId, objectId: objectId, orderId: orderId, orderStatus: orderStatus, totalSum: totalSum, placeStatus: 2);
  }


  Future<void> _reasonDialog({required Function onTap}) async{

    String reason = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          actionsPadding:EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(8.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Column(
            children: [
              RichSpanText(spanText: SnapTextModel(title: 'Вы отменяете позицию: ', data: '', postTitle: '')),
              RichSpanText(spanText: SnapTextModel(title: '', data: orderPositionData.productName, postTitle: '')),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(3.0),
            child: DropdownMenu<String>(
              //width:MediaQuery.of(context).size.width - 16,
              label: const Text('Укажите причину отмены'),
              onSelected: (String? value) {
                setState(() {
                  reason = value!;
                });
              },
              dropdownMenuEntries: [
                'Не соответствует заявленному',
                'Не своевременная доставка',
                'Просрочено',
                'Не учтено описание',
              ].map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(
                    value: value, label: value);
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () => onTap(reason),
              child: const Text('Применить'),
            ),

            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Отменить'),
              onPressed: (){
                setState(() {
                  successStatus = 3;
                  rejectionReason = '';
                });
                Navigator.pop(context);
              },),
          ],
        );
      },
    );
  }



}




