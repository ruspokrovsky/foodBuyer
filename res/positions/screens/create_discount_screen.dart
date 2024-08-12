import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/positions/positions_controllers/discount_controller.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/positions/positions_services/positions_services.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class CreateDiscountScreen extends ConsumerStatefulWidget {
  static const routeName = 'createDiscountScreen';

  final PositionModel positionModel;

  const CreateDiscountScreen({super.key, required this.positionModel});

  @override
  CreateDiscountScreenState createState() => CreateDiscountScreenState();
}

class CreateDiscountScreenState extends ConsumerState<CreateDiscountScreen> {
  late PositionModel positionData;

  TextEditingController quantityController = TextEditingController();
  TextEditingController percentController = TextEditingController();

  late List<DiscountModel> controllDiscountList = [];

  int currentDiscountIndex = 0;

  @override
  void initState() {
    positionData = widget.positionModel;
    controllDiscountList = List<DiscountModel>.from(positionData.discountList!);
    super.initState();
  }

  @override
  void dispose() {
    controllDiscountList.clear();
    quantityController.dispose();
    percentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Нименование: ',
                      style: styles.worningTextStyle,
                      children: <TextSpan>[
                        TextSpan(
                            text: positionData.productName,
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Закупочная цена: ',
                      style: styles.worningTextStyle,
                      children: <TextSpan>[
                        TextSpan(
                            text: positionData.productFirsPrice.toString(),
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Марженальность: ',
                      style: styles.worningTextStyle,
                      children: <TextSpan>[
                        TextSpan(
                            text: positionData.marginality.toString(),
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Отпускная цена: ',
                      style: styles.worningTextStyle,
                      children: <TextSpan>[
                        TextSpan(
                            text: positionData.productPrice.toString(),
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' /'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: EditText(
                          controller: quantityController,
                          textInputType: TextInputType.datetime,
                          labelText: 'Количество',
                          onChanged: (v) {},
                        ),
                      ),
                      const SizedBox(
                        width: 6.0,
                      ),
                      Expanded(
                        child: EditText(
                          controller: percentController,
                          textInputType: TextInputType.datetime,
                          labelText: '%',
                          onChanged: (v) {},
                        ),
                      ),
                      const SizedBox(
                        width: 6.0,
                      ),
                      IconButton(
                          onPressed: () {
                            if(quantityController.text.isNotEmpty && percentController.text.isNotEmpty){
                              currentDiscountIndex ++;
                              print('currentDiscountIndex:$currentDiscountIndex');
                              DiscountModel discount = DiscountModel(
                                  docId: '$currentDiscountIndex',
                                  positionId: positionData.docId!,
                                  quantity: num.parse(quantityController.text.trim()),
                                  percent: num.parse(percentController.text.trim()));
                              if(!controllDiscountList.contains(discount)){
                                controllDiscountList.add(discount);
                              }
                              setState(() {});
                            }
                            else { Get.snackbar('Внимание!','Добавьте значения');}

                          },
                          icon: const Icon(Icons.add)),

                    ],),

                  const SizedBox(
                    height: 16.0,
                  ),

                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: controllDiscountList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Количество: ',
                                    style: styles.worningTextStyle,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: controllDiscountList[index].quantity.toString(),
                                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),

                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16.0,),
                                RichText(
                                  text: TextSpan(
                                    text: '% : ',
                                    style: styles.worningTextStyle,
                                    children: <TextSpan>[

                                      TextSpan(
                                          text: controllDiscountList[index].percent.toString(),
                                          style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            IconButton(
                                onPressed: (){
                                  controllDiscountList.removeAt(index);
                                  setState(() {});

                                }, icon: const Icon(Icons.remove))
                          ],
                        );
                      }),

                  TwoButtonsBlock(
                      positiveText: 'Сохранить',
                      positiveClick: () async {

                        ref.read(progressBoolProvider.notifier).updateProgressBool(true);

                        await _addDiscount(
                            context: context,
                            ref: ref,
                            positionData: positionData,
                            discountList: positionData.discountList!,
                            controllDiscountList: controllDiscountList).then((String value) {

                          ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                          Navigator.pop(context);
                        });

                      },
                      negativeText: 'Отменить',
                      negativeClick: (){
                        Navigator.pop(context);
                      }),
                ],
              ),
            ),
          ),
        ),
        if(ref.watch(progressBoolProvider))
          const ProgressDialog()
      ],
    );
  }
}

Future<String> _addDiscount({
  required BuildContext context,
  required WidgetRef ref,
  required PositionModel positionData,
  required List<DiscountModel> discountList,
  required List<DiscountModel> controllDiscountList,
}) async {

  PositionsFBServices pfbs = PositionsFBServices();
  List<DiscountModel> currentDiscountList = List<DiscountModel>.from(discountList);
  List<dynamic> currentDiscountIdList = currentDiscountList.map((e) => e.docId).toList();
  List<dynamic> controllIdList = controllDiscountList.map((e) => e.docId).toList();
  bool isChangedList = listEquals(controllDiscountList, ref.watch(discountListProvider));

  if(isChangedList){
    Navigator.pop(context);
  }
  else {
    if(currentDiscountList.isNotEmpty){
      for (DiscountModel currentDiscount in currentDiscountList) {
        if(!controllIdList.contains(currentDiscount.docId)){
          //удаляем позиции которых нету в controllIdList
          await pfbs.deletePositionDiscount(
            projectRootId: positionData.projectRootId,
            positionId: positionData.docId!,
            discountId: currentDiscount.docId!,).whenComplete(() {});

        }
      }
      for (DiscountModel controllDiscount in controllDiscountList) {
        if(!currentDiscountIdList.contains(controllDiscount.docId)){
          //добавляем позиции которых нету в currentDiscountIdList
          await pfbs.addPositionDiscount2(
            projectRootId: positionData.projectRootId,
            positionId: positionData.docId!,
            discount: controllDiscount,);

        }
      }
    }
    else {
      await pfbs.addPositionDiscount(
          projectRootId: positionData.projectRootId,
          positionId: positionData.docId!,
          discountList: controllDiscountList);
    }
  }

  return 'createPositionDiscount success';
}
