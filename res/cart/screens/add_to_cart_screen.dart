import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/home/widgets/hero_container.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/places/place_providers/place_providers.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/discount_list_view.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/f_a_button.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class AddToCartScreen extends ConsumerStatefulWidget {
  static const routeName = 'addToCartScreen';
  //final Map argsForCart;
  //final AllPositionModel allPositionModel;

  final IntentPlacePositionRootUserArgs arguments;

  const AddToCartScreen({
    super.key,
    required this.arguments,
    //required this.allPositionModel,

  });

  @override
  AddToCartScreenState createState() => AddToCartScreenState();
}

class AddToCartScreenState extends ConsumerState<AddToCartScreen> {
  Utils utils = Utils();
  late PositionModel positionData;
  late PlaceModel objectData;
  late UserModel projectRootUser;
  late int positionIndex;
  TextEditingController qtyController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  double positionQty = 0.0;
  num amount = 0.0;

  late DiscountModel discountArgs;
  late num actualPrice;
  late num actualDiscountPercent = 0;

  @override
  void initState() {
    positionData = widget.arguments.positionData;
    objectData = widget.arguments.placeData;//positionId
    projectRootUser = widget.arguments.projectRootUser;
    actualPrice = positionData.productPrice;
    // if(positionData.discountList!.isEmpty){
    //   _getPositionDiscount(DiscountModel(rootId: positionData.projectRootId, positionId: positionData.docId!, quantity: 0, percent: 0));
    // }
    super.initState();
  }

  // Future<void> _getPositionDiscount(DiscountModel discountModel) async {
  //   QuerySnapshot snap = await PositionsFBServices().fetchPositionsDiscount(arguments: discountModel);
  //   ref.read(discountListProvider.notifier)..clean()..buildPositionDiscountList(snap);
  //   List<DiscountModel> discountList = ref.watch(discountListProvider);
  //   String positionId = positionData.docId!;
  //   positionData.discountList = discountList;
  //   ref.read(positionsListProvider.notifier).addPositionDiscountList(positionId, discountList);
  //   setState(() {});
  // }


  void updateAmount() {

    positionData.discountList = ref.watch(discountListProvider);

      double amount1 = (positionQty * positionData.productPrice);
      // Переменная для хранения последней примененной скидки
      num? lastAppliedDiscountPersent;
      // Если есть скидки
      if (positionData.discountList != null && positionData.discountList!.isNotEmpty) {
        positionData.discountList!.sort((a, b) => a.quantity.compareTo(b.quantity));
        for (var discount in positionData.discountList!) {
          if (positionQty >= discount.quantity) {
            // Сохраняем последнюю примененную скидку
            lastAppliedDiscountPersent = discount.percent;
          }
        }
      }
      print('lastAppliedDiscountPersent:$lastAppliedDiscountPersent');
      // Если была применена хотя бы одна скидка, пересчитываем сумму с учетом последней скидки
      if (lastAppliedDiscountPersent != null) {
        print('lastAppliedDiscountPersent:$lastAppliedDiscountPersent');
        double persentSum2 = (positionData.productPrice * lastAppliedDiscountPersent) / 100;
        // Присваеваем цену со скидкой для view
        actualPrice = (positionData.productPrice - persentSum2);
        actualDiscountPercent = lastAppliedDiscountPersent;
        double persentSum = (amount1 * lastAppliedDiscountPersent) / 100;
        amount1 -= persentSum;
      }else{
        actualPrice = positionData.productPrice;
        actualDiscountPercent = 0;
      }
      // Обновляем сумму после применения всех скидок (или без них)
      amount = amount1;
  }



  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);


    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, 'willPopAddToCartScreen');

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                child: CachedNetworkImg(
                    imageUrl: projectRootUser.profilePhoto,
                    width: 50, height: 50, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16.0,),
              Column(
                children: [
                  Text(projectRootUser.name,
                    style: styles.appBarTitleTextStyle,),
                  Text('Поставщик',
                    style: styles.smalTitleTextStyle,),
                ],
              ),

            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                child: HeroContainer(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4,
                  borderRadius: 0.0,
                  boxFit: BoxFit.contain,
                  imgPatch: positionData.productImage,
                  heroTag: positionData.productName,
                ),
                onTap: () => Navigation().navigationToFullPhotoScreen(context,positionData.productImage),
              ),
              const SizedBox(
                height: 10.0,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      positionData.productName,
                      textAlign: TextAlign.center,
                      style: styles.addToCartTitleStyle,
                    ),

                    Text(
                      '${utils.numberParse(value: positionData.productPrice)} UZS/${positionData.productMeasure}',
                      textAlign: TextAlign.center,
                      style: styles.addToCartTitleStyle,
                    ),
                    //_discountListView(discountList: positionData.discountList!, styles: styles),

                    const SizedBox(height: 8.0,),

                    DiscountListView(
                      arguments: DiscountModel(
                          rootId: positionData.projectRootId,
                          positionId: positionData.docId!,
                          quantity: 0,
                          percent: 0),),

                    // _discountListView2(
                    //     discountList: positionData.discountList!,
                    //     styles: styles,
                    //     projectRootId: positionData.projectRootId,
                    //     positionId: positionData.docId!),
                    const SizedBox(
                      height: 25.0,
                    ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(utils.numberParse(value: actualPrice),style: styles.addToCartPriceStyle,),
                            Text('Цена/${positionData.productMeasure}'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(actualDiscountPercent.toString(),style: styles.addToCartPriceStyle,),
                            const Text('Скидка/%'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(utils.numberParse(value: amount),style: styles.addToCartPriceStyle,),
                            const Text('Сумма/UZS'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FAButton(
                          heroTag: 'minus',
                          onPressed: () {
                            if (positionQty > 0) {
                              setState(() {
                                positionQty--;
                                qtyController.text = positionQty.toString();
                                updateAmount();
                              });

                            }
                          },
                          fabChild: Icon(
                            Icons.remove,
                            color: Theme.of(context).primaryColorDark,
                            size: 56.0,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: EditText(
                            labelText: 'Количество',
                            controller: qtyController,
                            textInputType: TextInputType.number,
                            textAlign: TextAlign.center,
                            textStyle: styles.addToCartEditTextStyle,
                            onTapEditText: () {},
                            onChanged: (value) {
                              if (value.isNotEmpty&&value !='.') {
                                positionQty = double.parse(value.replaceAll(',', '.'));
                              } else {
                                positionQty = 0.0;
                              }
                              setState(() {
                                updateAmount();
                              });
                            },
                          ),
                        ),
                        FAButton(
                          heroTag: 'plus',
                          onPressed: () {

                            setState(() {
                              positionQty++;
                              qtyController.text = positionQty.toString();
                              updateAmount();
                            });
                          },

                          fabChild: Icon(
                            Icons.add,
                            color: Theme.of(context).primaryColorDark,
                            size: 56.0,
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    EditText(
                      controller: descriptionController,
                      maxLines: 2,
                      labelText: 'Примечание',
                      borderRadius: 10.0,
                      onChanged: (value) {},
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    TwoButtonsBlock(
                        negativeClick: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.pop(context);
                        },
                        positiveText: 'Добавить в корзину',
                        positiveClick: () {

                          if(positionQty != 0.0){

                            List<DiscountModel> discountLis = List<DiscountModel>.from(ref.watch(discountListProvider));

                            OrderModel orderModel = OrderModel(
                              projectRootId: positionData.projectRootId,
                              objectId: ref.watch(currentPlaceProvider).docId,
                              objectName: ref.watch(currentPlaceProvider).placeName,
                              productId: positionData.docId.toString(),
                              productName: positionData.productName,
                              productMeasure: positionData.productMeasure,
                              category: positionData.subCategoryName,
                              productPrice: positionData.productPrice,
                              productQuantity: positionQty,
                              amountSum: amount,
                              acceptedDate: 0,
                              returnQty: 0,
                              requestNote: descriptionController.text.trim(),
                              successStatus: 0,
                              united: positionData.united,
                              productImage: positionData.productImage,
                              discountPercent: actualDiscountPercent,
                              lastDiscountPercent: 0,
                              rejectionReason: '',
                              discountList: discountLis,
                              discountPrice: actualPrice,
                              firstPrice: positionData.productFirsPrice,
                            );

                            ref.read(multipleCartListProvider.notifier).addCartPosition(positionData.projectRootId, orderModel);

                            MultipleCartModel currentCartData = ref
                                .read(multipleCartListProvider.notifier)
                                .currentCartData(positionData.projectRootId);

                            if(currentCartData.customerId.isEmpty){
                              ref.read(multipleCartListProvider.notifier).setCustomer(MultipleCartModel(
                                projectRootId: positionData.projectRootId,
                                projectRootName: '',
                                currentCartList: [],
                                customerId: ref.watch(currentPlaceProvider).docId!,
                                customerName: ref.watch(currentPlaceProvider).placeName,));
                            }


                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.pop(context,'successSelected');

                          } else {
                            Get.snackbar('Внимание!','Добавте количество');
                          }
                        },
                        negativeText: 'Назад',
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget _discountListView2({
//   required List<DiscountModel> discountList,
//   required AppStyles styles,
//   required String projectRootId,
//   required String positionId,
// }){
//   DiscountModel arguments = DiscountModel(
//       rootId: projectRootId,
//       positionId: positionId, quantity: 0, percent: 0);
//   return Consumer(
//     builder: (BuildContext context, WidgetRef ref, Widget? child) {
//       List<DiscountModel> discountList = [];
//       var discoundData = ref.watch(getPositionsDiscountProvider(arguments));
//       DiscountController discountController = ref.read(discountListProvider.notifier);
//       return discoundData.when(data: (QuerySnapshot snap){
//         discountController..clean()..buildPositionDiscountList(snap);
//         discountList = ref.watch(discountListProvider);
//         return Container(
//           color: const Color.fromRGBO(255, 251, 230, 1),
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: ListView.builder(
//             itemCount: discountList.length,
//             shrinkWrap: true,
//             itemBuilder: (context, index) {
//               return Table(
//                 //border: TableBorder.all(),
//                 children: [
//                   TableRow(
//                     children: [
//                       TableCell(
//                         child: RichText(
//                           text: TextSpan(
//                             text: 'Количество: ',
//                             style: styles.worningTextStyle,
//                             children: <TextSpan>[
//                               TextSpan(
//                                   text: discountList[index].quantity.toString(),
//                                   style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
//
//                             ],
//                           ),
//                         ),),
//                       TableCell(
//                         child: RichText(
//                           text: TextSpan(
//                             text: 'Скидка: ',
//                             style: styles.worningTextStyle,
//                             children: <TextSpan>[
//
//                               TextSpan(
//                                   text: discountList[index].percent.toString(),
//                                   style: const TextStyle(
//                                       color: Colors.redAccent,
//                                       fontWeight: FontWeight.bold)),
//
//                               TextSpan(
//                                 text: ' %',
//                                 style: styles.worningTextStyle,),
//                             ],
//                           ),
//                         ),),
//                     ],
//                   ),
//                   // Добавьте другие строки или ячейки по мере необходимости
//                 ],
//               );
//             },
//           ),
//         );
//       },
//           error: (_,__) => const Placeholder(),
//           loading: ()=> const ProgressMini());
//     },
//   );
// }



// Widget _discountListView({required List<DiscountModel> discountList, required AppStyles styles }){
//   return Container(
//     color: const Color.fromRGBO(255, 251, 230, 1),
//     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//     child: ListView.builder(
//       itemCount: discountList.length,
//       shrinkWrap: true,
//       itemBuilder: (context, index) {
//         return Table(
//           //border: TableBorder.all(),
//           children: [
//             TableRow(
//               children: [
//                 TableCell(
//                   child: RichText(
//                     text: TextSpan(
//                       text: 'Количество: ',
//                       style: styles.worningTextStyle,
//                       children: <TextSpan>[
//                         TextSpan(
//                             text: discountList[index].quantity.toString(),
//                             style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
//
//                       ],
//                     ),
//                   ),),
//                 TableCell(
//                   child: RichText(
//                     text: TextSpan(
//                       text: 'Скидка: ',
//                       style: styles.worningTextStyle,
//                       children: <TextSpan>[
//
//                         TextSpan(
//                             text: discountList[index].percent.toString(),
//                             style: const TextStyle(
//                                 color: Colors.redAccent,
//                                 fontWeight: FontWeight.bold)),
//
//                         TextSpan(
//                           text: ' %',
//                           style: styles.worningTextStyle,),
//                       ],
//                     ),
//                   ),),
//               ],
//             ),
//             // Добавьте другие строки или ячейки по мере необходимости
//           ],
//         );
//       },
//     ),
//   );
// }

