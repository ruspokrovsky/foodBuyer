import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/purchases/purchase_services/purchase_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/product_control_form.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';

class ActualPurchaseScreen extends ConsumerStatefulWidget {
  static const String routeName = 'actualPurchaseScreen';
  final PurchasingModel purchasingModel;

  const ActualPurchaseScreen({super.key, required this.purchasingModel});

  @override
  PurchaseState createState() => PurchaseState();
}

class PurchaseState extends ConsumerState<ActualPurchaseScreen> {
  final PurchaseFBServices _dbs = PurchaseFBServices();

  Utils utils = Utils();

  TextEditingController actualPriceController = TextEditingController();
  TextEditingController actualQtyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  num positionPrc = 0.0;
  num positionQty = 0.0;
  num orderQty = 0.0;
  num amount = 0.0;
  bool ndsStatus = false;

  @override
  void initState() {
    positionQty = widget.purchasingModel.orderQty;
    positionPrc = widget.purchasingModel.firsPrice;
    actualQtyController.text = utils.numberParse(value: widget.purchasingModel.orderQty);
    actualPriceController.text = widget.purchasingModel.firsPrice.toString();
    amount = (widget.purchasingModel.orderQty * widget.purchasingModel.firsPrice);

    orderQty = widget.purchasingModel.orderQty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Закуп'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: ProductControlForm(
                whoScreen: 'actualPurchaseScreen',
                strPositionPrice: '',
                actualQtyController: actualQtyController,
                actualPriceController: actualPriceController,
                descriptionController: descriptionController,
                strAmount: utils.numberParse(value: amount).toString(),
                strProductName: widget.purchasingModel.productName,
                strSelectedQty: positionQty.toString(),
                productMeasure: widget.purchasingModel.productMeasure,
                positionPrice:
                    'Цена: ${utils.numberParse(value: widget.purchasingModel.firsPrice)}',
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
                //imageUrl: '',
                imageUrl: widget.purchasingModel.positionImgUrl,
                strQtyTitle: '',
                positiveText: '',
                positiveClick: () {},
                negativeText: '',
                negativeClick: () {},
                isNdsStatus: ndsStatus,
                toggleNdsStatus: (bool v){
                 setState(() {
                   ndsStatus = v;
                 });
                },
                bottom: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    PositionModel? positionModel;
                    ref.watch(getPositionByIdProvider2(widget.purchasingModel))
                        .whenData((snap) async {
                      positionModel = PositionModel.snapFromDoc(snap);
                    });

                    return TwoButtonsBlock(
                        positiveText: 'Купить',
                        positiveClick: () async {
                          if (positionQty != 0.0) {
                            ref.read(progressBoolProvider.notifier).updateProgressBool(true);

                            await utils.newPriceConverter(
                            productQuantity: positionModel!.productQuantity,
                            productFirsPrice: positionModel!.productFirsPrice,
                            newFirstPrice: positionPrc,
                            marginality: positionModel!.marginality)
                                .then((List<dynamic> oldNewPrice) async {
                              await _dbs.updatePurchase(
                                  oldNewPrise: oldNewPrice,
                                  purchasingModel: PurchasingModel(
                                  docId: widget.purchasingModel.docId,
                                  projectRootId: widget.purchasingModel.projectRootId,
                                  productId: widget.purchasingModel.productId,
                                  buyerId: widget.purchasingModel.buyerId,
                                  buyerName: widget.purchasingModel.buyerName,
                                  selectedTime: widget.purchasingModel.selectedTime,
                                  firsPrice: widget.purchasingModel.firsPrice,
                                  actualPrice: positionPrc,
                                  actualQty: positionQty,
                                  productName: widget.purchasingModel.productName,
                                  productMeasure: widget.purchasingModel.productMeasure,
                                  orderQty: orderQty,
                                  purchasingStatus: 2,
                                  positionImgUrl: widget.purchasingModel.positionImgUrl,
                                  ndsStatus: ndsStatus,
                                ),
                                positionModel: positionModel!,
                              ).whenComplete(() {
                                FocusScope.of(context).requestFocus(FocusNode());
                                ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                Navigator.pop(context, 'successSelected');
                              });
                            });
                          } else {
                            Get.snackbar('Внимание!', 'Добавте количество');
                          }
                        },
                        negativeText: 'Отменить',
                        negativeClick: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.pop(context);
                        });
                  },
                ),
              ),

              // Consumer(
              //   builder: (BuildContext context, WidgetRef ref, Widget? child) {
              //
              //     String imgUrl = ref.watch(allPositionListProvider).where((element)
              //     => element.docId == widget.purchasingModel.productId).single.productImage;
              //
              //     return ProductControlForm(
              //       whoScreen: 'actualPurchaseScreen',
              //       strPositionPrice: '',
              //       actualQtyController: actualQtyController,
              //       actualPriceController: actualPriceController,
              //       descriptionController: descriptionController,
              //       strAmount: amount.toString(),
              //       strProductName: widget.purchasingModel.productName,
              //       strSelectedQty: widget.purchasingModel.orderQty.toString(),
              //       productMeasure: widget.purchasingModel.productMeasure,
              //       positionPrice: 'Цена: ${widget.purchasingModel.firsPrice}',
              //       onChangedPrice: (value){
              //
              //         if (value.isNotEmpty) {
              //           positionPrc = double.parse(value);
              //         } else {
              //           positionPrc = 0.0;
              //         }
              //         amount = positionPrc * positionQty;
              //         setState(() {});
              //       },
              //       onChangedQuantity: (value){
              //
              //         if (value.isNotEmpty) {
              //           positionQty = double.parse(value);
              //         } else {
              //           positionQty = 0.0;
              //         }
              //         amount = positionQty * positionPrc;
              //         setState(() {});
              //
              //       },
              //       imageUrl: imgUrl,
              //       strQtyTitle: 'Купить: ',
              //       positiveText: 'Купить',
              //       positiveClick: (){
              //         if(positionQty != 0.0){
              //
              //           FocusScope.of(context).requestFocus(FocusNode());
              //           Navigator.pop(context,'successSelected');
              //
              //
              //           _dbs.updatePurchase(purchasingModel: PurchasingModel(
              //               buyerId: ref.watch(currentUserProvider).uId,
              //               buyerName: ref.watch(currentUserProvider).name,
              //               selectedTime: 0,
              //               firsPrice: widget.purchasingModel.firsPrice,
              //               actualPrice: double.parse(actualPriceController.text.trim()),
              //               actualQty: double.parse(actualQtyController.text.trim()),
              //               productName: widget.purchasingModel.productName,
              //               productId: widget.purchasingModel.productId,
              //               productMeasure: widget.purchasingModel.productMeasure,
              //               orderQty: widget.purchasingModel.orderQty,
              //               purchasingStatus: 1,
              //
              //
              //
              //
              //           )
              //           );
              //
              //
              //         } else {
              //           Get.snackbar('Внимание!','Добавте количество');
              //         }
              //       },
              //       negativeText: 'Отменить',
              //       negativeClick: (){
              //         FocusScope.of(context).requestFocus(FocusNode());
              //         Navigator.pop(context);
              //       },
              //
              //     );
              //   },
              // ),
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

String _imageUrl(WidgetRef ref, String productId) {
  return ref.watch(positionsListProvider).where((element) => element.docId == productId).single.productImage;
}

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
