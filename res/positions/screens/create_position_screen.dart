import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/fb_services/fb_services.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/positions/positions_services/positions_services.dart';
import 'package:ya_bazaar/res/positions/widgets/create_position_form.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/discount_list_view.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/three_buttons_block.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/res/widgets/update_single_images_block.dart';
import 'package:ya_bazaar/theme.dart';
import 'package:excel/excel.dart'as excel_lib;


class CreatePositionScreeen extends ConsumerStatefulWidget {
  static const String routeName = 'createPositionScreeen';
  final PositionModel positionModel;
  const CreatePositionScreeen({super.key, required this.positionModel});

  @override
  CreatePositionScreeenState createState() => CreatePositionScreeenState();
}

class CreatePositionScreeenState extends ConsumerState<CreatePositionScreeen> {
  FbService globaFfbs = FbService();
  PositionsFBServices fbs = PositionsFBServices();
  late PositionModel positionData;
  Utils utils = Utils();
  Navigation navigation = Navigation();

  TextEditingController nameController = TextEditingController ();
  TextEditingController firsPriceController = TextEditingController();
  TextEditingController marginalityController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dropdownMenuController = TextEditingController();

  @override
  void initState() {
    positionData = widget.positionModel;

    if(positionData.docId!.isNotEmpty){
      nameController.text = positionData.productName;
      firsPriceController.text = positionData.productFirsPrice.toString();
      marginalityController.text = positionData.marginality.toString();
      quantityController.text = positionData.productQuantity.toString();
      dropdownMenuController.text = positionData.productMeasure;
      // _getPositionDiscount(DiscountModel(
      //     rootId: positionData.projectRootId,
      //     positionId: positionData.docId!, quantity: 0, percent: 0));
    }

    super.initState();
  }


  // Future<void> _getPositionDiscount(DiscountModel discountModel) async {
  //   //QuerySnapshot snap = await PositionsFBServices().fetchPositionsDiscount(arguments: discountModel);
  //   await PositionsFBServices().fetchPositionsDiscount(arguments: discountModel).then((snap) async {
  //     ref.read(discountListProvider.notifier)..clean()..buildPositionDiscountList(snap);
  //     List<DiscountModel> discountList = ref.watch(discountListProvider);
  //     //String positionId = positionData.docId!;
  //     positionData.discountList = discountList;
  //     //ref.read(positionsListProvider.notifier).addPositionDiscountList(positionId, discountList);
  //   });
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(positionData.docId!.isEmpty? 'Добавить позицию' :'Редактировать',style: styles.appBarTitleTextStyle,),
        actions: [
          PopupMenuButton<int>(
              onSelected: (int itemIndex){

                if(itemIndex == 0){
                  if(positionData.docId!.isNotEmpty){
                    positionData.discountList = ref.watch(discountListProvider);
                    navigation.navigationToCreateDiscountScreen(context, positionData);
                  }
                  else {
                    Get.snackbar('Внимание!','Доступно после добавления позиции');
                  }
                }
                else
                if(itemIndex == 1){

                  navigation.navigationToCategorySelector(context).then((value) {

                      positionData.subCategoryId = ref.watch(subCategoryProvider).docId!;
                      positionData.subCategoryName = ref.watch(subCategoryProvider).subCategoryName;
                      ref.read(subCategoryProvider.notifier).clean();
                      setState(() {});

                  });

                }
                else
                if(itemIndex == 2){

                  //сначала генерируем шаблон для заполнения позициями
                  utils.createSampleExcelFile().then((String filePath) async {
                    await OpenFile.open(filePath);
                  });

                  //затем загружаем заполненный Excel File в БД
                  //   utils.pickAndReadExcelFile().then((String filePath) {
                  //     _readExcelFile(filePath: filePath);
                  //   });
                }
              },

              itemBuilder: (BuildContext context)=>[
                PopupMenuItem(
                    value: 0,
                    child: Text('Установить скидку по количеству',style: styles.smalTitleTextStyle,)),
                PopupMenuItem(
                    value: 1,
                    child: Text('Изменить категорию',style: styles.smalTitleTextStyle,)),
                PopupMenuItem(
                    value: 2,
                    child: Text('Загрузить из EXCEL файла',style: styles.smalTitleTextStyle,))
              ])
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CreatePositionForm(
                    strCategory: 'subCategoryName: ${positionData.subCategoryName}\nsubCategoryId: ${positionData.subCategoryId}\ndocId: ${positionData.docId}',
                    nameController: nameController,
                    firsPriceController: firsPriceController,
                    marginalityController: marginalityController,
                    quantityController: quantityController,
                    dropdownMenuController: dropdownMenuController,
                    carouselSlider: UpdateSingleImagesBlock(
                        pickImageFromCamera: (){
                          utils.pickFromCameraImage().then((img) => {
                            ref.read(pickImageFileProvider.notifier).updateImageFile(File(img.path)),
                          });
                        },
                        selectImageFromGallery: (){
                          utils.pickFromGalleryImage().then((img) => {
                            ref.read(pickImageFileProvider.notifier).updateImageFile(File(img.path)),
                          });
                        },
                        deleteFileImg: (){
                          ref.read(pickImageFileProvider.notifier).clean();
                        },
                        imageFile: ref.watch(pickImageFileProvider),
                        imageNetwork: positionData.productImage),
                        discountLisView: DiscountListView(
                          arguments: DiscountModel(
                          rootId: positionData.projectRootId,
                          positionId: positionData.docId!,
                          quantity: 0,
                          percent: 0),),

                    // _discountListView(
                    //     discountList: positionData.discountList!,
                    //     styles: styles,
                    //     projectRootId: positionData.projectRootId,
                    //     positionId: positionData.docId!),

                    bottomButton: (positionData.docId!.isNotEmpty)
                        ?
                    ThreeButtonsBlock(
                      positiveText: 'Изменить',
                      positiveClick: () async{

                        if(
                        nameController.text.isNotEmpty
                        && firsPriceController.text.isNotEmpty
                        && marginalityController.text.isNotEmpty
                        && quantityController.text.isNotEmpty
                        ){

                          ref.read(progressBoolProvider.notifier).updateProgressBool(true);

                          double marginality = 0.0;
                          double unitPosition = 0.0;

                          if(marginalityController.text.isNotEmpty){
                            marginality = double.parse(marginalityController.text.trim());
                          }

                          await utils.newPriceConverter(
                              productQuantity: positionData.productQuantity,
                              newFirstPrice: double.parse(firsPriceController.text.trim()),
                              productFirsPrice: positionData.productFirsPrice,
                              marginality: marginality).then((value) async{
                            num newQty = double.parse(quantityController.text.trim());
                            List<dynamic> unitedList = positionData.unitedList!;
                            if(unitedList.isNotEmpty){
                              num unitedFromList = positionData.unitedList!.reduce((v, e) => v + e);
                              if(unitedFromList > newQty){
                                positionData.united = (unitedFromList - newQty);
                              }
                              else {
                                positionData.united = 0;
                              }
                            }

                            await fbs.updatePosition2(
                              positionImage: ref.watch(pickImageFileProvider),
                              positionModel: PositionModel(
                                docId: positionData.docId,
                                projectRootId: positionData.projectRootId,
                                productName: nameController.text.trim(),
                                productMeasure: dropdownMenuController.text.trim(),
                                productFirsPrice: value[0],
                                productPrice: value[1],
                                productQuantity: newQty,
                                marginality: marginality,
                                deliverSelectedTime: 0,
                                available: true,
                                subCategoryName: positionData.subCategoryName,
                                subCategoryId: positionData.subCategoryId,
                                deliverId: '',
                                deliverName: '',
                                amount: 0,
                                united: positionData.united,
                                productImage: positionData.productImage,
                                unitedList: unitedList,
                                addedAt: DateTime.now().millisecondsSinceEpoch,


                              ),).then((value){

                              ref.read(progressBoolProvider.notifier).updateProgressBool(false);


                            }).then((value) => Navigator.pop(context));

                          });

                        }

                        else {

                          Get.snackbar('Внимание!', 'Заполните все поля!');
                        }


                      },
                      neutralText: 'Удалить',
                      neutralClick: (){

                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              insetPadding: EdgeInsets.zero,
                              actionsPadding: EdgeInsets.zero,
                              contentPadding: const EdgeInsets.all(8.0),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                              title: Text(positionData.productName, textAlign: TextAlign.center,),
                              content: Text(
                                'Удалить позицию?',
                                style: styles.worningTextStyle,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  onPressed: () {
                                    ref.read(progressBoolProvider.notifier).updateProgressBool(true);
                                    fbs.deletePosition(
                                        projectRootId: positionData.projectRootId,
                                        positionId: positionData.docId,
                                        imageUrl: positionData.productImage)
                                        .whenComplete(() {
                                      ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                    }).whenComplete(() => Navigator.pop(context));
                                  },
                                  child: const Text('Удалить'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text('Отменить'),
                                  onPressed: () {
                                    //setState(() {});
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        ).then((value) => Navigator.pop(context));
                      },
                      negativeText: 'Отменить',
                      negativeClick: ()=> Navigator.pop(context),
                    )
                        :
                    TwoButtonsBlock(

                      positiveText: 'Сохранить',
                      positiveClick: () async{

                        ref.read(progressBoolProvider.notifier).updateProgressBool(true);

                        double marginality = 0.0;

                        if(marginalityController.text.isNotEmpty){
                          marginality = double.parse(marginalityController.text.trim());
                        }


                        await utils.newPriceConverter(
                            productQuantity: 0,
                            newFirstPrice: num.parse(firsPriceController.text.trim()),
                            productFirsPrice: 0,
                            marginality: marginality).then((List<num> value) async{

                          await fbs.addPosition2(
                            projectRootId: ref.watch(currentUserProvider).uId,
                            positionModel: PositionModel(
                              projectRootId: ref.watch(currentUserProvider).uId,
                              productName: nameController.text.trim(),
                              productMeasure: dropdownMenuController.text.trim(),
                              productFirsPrice: value[0],
                              productPrice: value[1],
                              productQuantity: num.parse(quantityController.text.trim()),
                              marginality: marginality,
                              deliverSelectedTime: 0,
                              available: true,
                              subCategoryName: positionData.subCategoryName,
                              subCategoryId: positionData.subCategoryId,
                              deliverId: '',
                              deliverName: '',
                              cartQty: 0,
                              amount: 0,
                              united: 0,
                              productImage: '',
                              unitedList: [],
                              addedAt: DateTime.now().millisecondsSinceEpoch,
                            ),
                            positionImage: ref.watch(pickImageFileProvider),
                          ).then((value) {
                            ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                            Navigator.pop(context);
                          });


                        });
                      },
                      negativeText: 'Отменить',
                      negativeClick: ()=> Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          ref.watch(progressBoolProvider)
              ?
          const ProgressDialog()
              :
          const SizedBox.shrink(),
        ],
      ),
    );
  }

}


void _readExcelFile({required String filePath}) async {
  List<PositionModel> positionsList = [];
  var bytes = File(filePath).readAsBytesSync();
  var excel = excel_lib.Excel.decodeBytes(bytes);


  for (var table in excel.tables.keys) {
    var rows = excel.tables[table]!.rows;

    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        var rowData = rows[i]; // Получаем данные из строки
        // Пример создания объекта PositionModel из данных строки


        var strData = rowData[0]?.value??'';
        var strData2 = rowData[2]?.value??'';
        var strData3 = rowData[3]?.value??'';

        if(strData != ''){
          print(strData);
        }

        if(strData2 != ''){
          print('$strData2   $strData3');
        }




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
            addedAt: 0,);

        positionsList.add(position); // Добавляем созданный объект в список
      }
    }
  }
// print(positionsList.map((e) => e.productName));
}






