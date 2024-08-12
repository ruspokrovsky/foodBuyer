import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/purchases/purchase_services/purchase_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/product_control_form.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';

class AcceptancePurchasesScreen extends ConsumerStatefulWidget {
  static const String routeName = 'acceptancePurchasesScreen';
  final PurchasingModel purchasingModel;

  const AcceptancePurchasesScreen({super.key, required this.purchasingModel});

  @override
  AcceptancePurchasesScreenState createState() =>
      AcceptancePurchasesScreenState();
}

class AcceptancePurchasesScreenState
    extends ConsumerState<AcceptancePurchasesScreen> {
  final PurchaseFBServices dbs = PurchaseFBServices();
  Utils utils = Utils();
  late PurchasingModel purchasingData;
  final TextEditingController actualPriceController = TextEditingController();
  final TextEditingController actualQtyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late num positionPrc = 0.0;
  late num positionQty = 0.0;
  late num amount = 0.0;

  @override
  void initState() {
    purchasingData = widget.purchasingModel;
    positionQty = purchasingData.actualQty;
    positionPrc = purchasingData.actualPrice;
    actualQtyController.text = Utils().numberParse(value: purchasingData.actualQty);
    actualPriceController.text = purchasingData.actualPrice.toString();
    amount = (purchasingData.actualPrice * purchasingData.actualQty);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Приход на склад'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: ProductControlForm(
                whoScreen: 'acceptPositionScreen1',
                strPositionPrice: '',
                actualQtyController: actualQtyController,
                actualPriceController: actualPriceController,
                descriptionController: descriptionController,
                strAmount: Utils().numberParse(value: amount).toString(),
                strProductName: purchasingData.productName,
                strSelectedQty: Utils().numberParse(value: positionQty),
                productMeasure: purchasingData.productMeasure,
                positionPrice:
                    'Цена: ${Utils().numberParse(value: purchasingData.firsPrice)}',
                onChangedPrice: (value) {
                  if (value.isNotEmpty) {
                    positionPrc = double.parse(value.replaceAll(',', '.'));
                  } else {
                    positionPrc = 0.0;
                  }
                  amount = positionPrc * positionQty;
                  setState(() {});
                },
                onChangedQuantity: (value) {
                  if (value.isNotEmpty) {
                    positionQty = double.parse(value.replaceAll(',', '.'));
                  } else {
                    positionQty = 0.0;
                  }
                  amount = positionQty * positionPrc;
                  setState(() {});
                },
                imageUrl: '',
                strQtyTitle: 'Принять: ',
                positiveText: 'Принять',
                positiveClick: () {},
                negativeText: 'Отменить',
                negativeClick: () {},
                bottom: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    PositionModel? positionModel;
                    ref.watch(getPositionByIdProvider2(widget.purchasingModel))
                        .whenData((snap) async {
                      positionModel = PositionModel.snapFromDoc(snap);
                    });

                    return TwoButtonsBlock(
                        positiveText: 'Принять',
                        positiveClick: () async {
                          if (positionQty != 0.0) {
                            ref.read(progressBoolProvider.notifier)
                                .updateProgressBool(true);

                            await utils.newPriceConverter(
                                    productQuantity: positionModel!.productQuantity,
                                    productFirsPrice: positionModel!.productFirsPrice,
                                    newFirstPrice: purchasingData.actualPrice,
                                    marginality: positionModel!.marginality)
                                .then((value) async {

                                  print('value: $value');

                              num missingQuantity = 0;
                              num united = positionModel!.united;
                              //num orderQty = purchasingData.orderQty;

                              //принятое по факту количество прибавляем к количеству на складе
                              //если количество фактического прихода меньше количества принятого на закуп
                              //вычитаем приход из заявленного = разницу прибавляем к заявкам united
                              //таким образом не достающее количество остается в заявках

                              //if (positionQty < orderQty) {
                                //missingQuantity = (orderQty - positionQty);
                             // }

                              await dbs
                                  .updateProductTransaction2(
                                  positionModel: PositionModel(
                                      projectRootId: positionModel!.projectRootId,
                                      productName: positionModel!.productName,
                                      productMeasure: positionModel!.productMeasure,
                                      productFirsPrice: value[0],
                                      productPrice: value[1],
                                      productQuantity: positionQty,
                                      marginality: 0,
                                      deliverSelectedTime: 0,
                                      available: true,
                                      subCategoryName: '',
                                      subCategoryId: '',
                                      deliverId: purchasingData.buyerId,
                                      deliverName: purchasingData.buyerName,
                                      amount: amount,
                                      united: united,
                                      productImage: '',
                                      addedAt: DateTime.now().millisecondsSinceEpoch),

                                      purchasingModel: PurchasingModel(
                                        docId: purchasingData.docId,
                                        projectRootId: purchasingData.projectRootId,
                                        productId: purchasingData.productId,
                                        buyerId: '',
                                        buyerName: '',
                                        selectedTime: purchasingData.selectedTime,
                                        firsPrice: 0,
                                        actualPrice: 0,
                                        actualQty: 0,
                                        productName: '',
                                        productMeasure: '',
                                        orderQty: 0,
                                        purchasingStatus: 3,
                                        receivedDate: DateTime.now().millisecondsSinceEpoch,
                                        receivedQuantity: positionQty,
                                        positionImgUrl: purchasingData.positionImgUrl,
                                      ))
                                  .then((value) async {
                                ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                Navigator.pop(context);

                                // await dbs.updatePurchaseAfterReceivedWarehouse(purchasingModel: PurchasingModel(
                                //   docId: purchasingData.docId,
                                //   buyerId: '',
                                //   buyerName: '',
                                //   selectedTime: 0,
                                //   firsPrice: 0,
                                //   actualPrice: 0,
                                //   actualQty: 0,
                                //   productName: '',
                                //   productId: '',
                                //   productMeasure: '',
                                //   orderQty: 0,
                                //   purchasingStatus: 3,
                                //   receivedDate: 0,
                                //   receivedQuantity: positionQty,
                                //
                                //
                                // )).then((value) {
                                //   ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                //   Navigator.pop(context);
                                // });
                              });
                            });
                          } else {
                            Get.snackbar('Внимание!', 'Добавте количество');
                          }
                        },
                        negativeText: 'Отменить',
                        negativeClick: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pop(context);});
                  },
                ),
              ),
            ),
          ),
        ),
        ref.watch(progressBoolProvider)
            ? const ProgressDialog()
            : const SizedBox.shrink(),
      ],
    );
  }
}

// String _imageUrl(WidgetRef ref, String productId) {
//   return ref
//       .watch(allPositionListProvider)
//       .where((element) => element.docId == productId)
//       .single
//       .productImage;
// }

Future<List> _newPriceConverter({
  required num productQuantity,
  required num newFirstPrice,
  required num productFirsPrice,
  required num marginality,
}) async {
  double newPrice = 0;

  print('productFirsPrice::$productFirsPrice');
  print('newFirstPrice::$newFirstPrice');
  print('productQuantity::$productQuantity');
  print('marginality::$marginality');

  if (productQuantity == 0) {
    double mrg = (newFirstPrice * marginality) / 100;
    newPrice = (newFirstPrice + mrg);
  } else {
    if (productFirsPrice > newFirstPrice) {
      newFirstPrice = (productFirsPrice + newFirstPrice) / 2;
      double mrg = (newFirstPrice * marginality) / 100;
      newPrice = (newFirstPrice + mrg);
    } else {
      double mrg = (newFirstPrice * marginality) / 100;
      newPrice = (newFirstPrice + mrg);
    }
  }
  return [
    newFirstPrice,
    newPrice,
  ];
}
