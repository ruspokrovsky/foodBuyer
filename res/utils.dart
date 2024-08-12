import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ya_bazaar/generated/locale_keys.g.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/local_switch.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class Utils{



  dateParse({required int milliseconds}){
    if(milliseconds == 0){
      return '';
    }else{
      return DateFormat('dd.MM.yy').format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
    }

  }

  timeParse({required int milliseconds}){
    if(milliseconds == 0){
      return '';
    }
    else {
      return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
    }
  }

  dateTimeParse({required int milliseconds}){
    if(milliseconds == 0){
      return '';
    }
    else {
      return DateFormat('dd.MM.yy / HH:mm').format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
    }
  }

  monthParse({required int milliseconds}){
    if(milliseconds == 0){
      return '';
    }
    else {
      return DateFormat('MM').format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
    }
  }

  numberParse({required dynamic value}){
    return NumberFormat.decimalPattern('RU').format(value);
  }

  Future<List<num>> newPriceConverter({
    required num productQuantity,
    required num newFirstPrice,
    required num productFirsPrice,
    required num marginality,
  }) async{
    double newPrice = 0;

    print('>>productQuantity: $productQuantity');
    print('>>newFirstPrice: $newFirstPrice');
    print('>>productFirsPrice: $newFirstPrice');
    print('>>marginality: $marginality');

    if (productQuantity > 0) {

      newFirstPrice = (productFirsPrice + newFirstPrice) / 2;
      double mrg = (newFirstPrice * marginality) / 100;
      newPrice = (newFirstPrice + mrg);


    } else {

      double mrg = (newFirstPrice * marginality) / 100;
      newPrice = (newFirstPrice + mrg);
      //if (productFirsPrice > newFirstPrice) {

      // } else {
      //   double mrg = (newFirstPrice * marginality) / 100;
      //   newPrice = (newFirstPrice + mrg);
      // }
    }

    return [newFirstPrice, newPrice,];
  }


  showBottomSheet(
      {required BuildContext context,
        required String title,
        String? subTitle,
        String? labelText,
        required Function positiveTap}) {
    TextEditingController textEditingController = TextEditingController();
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                  if (subTitle != null)
                    Text(
                      subTitle,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  EditText(
                      labelText: labelText ?? LocaleKeys.add_category.tr(),
                      controller: textEditingController,
                      onChanged: (v){},),
                  TwoButtonsBlock(
                    positiveText: LocaleKeys.save.tr(),
                    positiveClick: () =>
                        positiveTap(textEditingController.text.trim()),
                    negativeText: LocaleKeys.cancel.tr(),
                    negativeClick: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> bottomSheet({
    required BuildContext context,
    required double height,
    required Widget content,
  }){

    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(

              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0))
              ),

              width: MediaQuery.of(context).size.width,
              height: height,
              child: content,
            ),
          );
        });

  }

  Future<void> bottomSheetBuilder({
    required BuildContext context,
    required bool languageStatus,
    required bool themeStatus,
    required bool userStatus,
    required Function onLanguageToggle,
    required Function onStatusToggle,
    required Function onDarkLightToggle,
    required VoidCallback exitTap,
    required VoidCallback onTapSignOut,
    required VoidCallback onTapCodeScaner,
  }) {
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: 240.0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                //color: const Color.fromRGBO(255, 251, 230, 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: LocalSwitch(
                            value: languageStatus,
                            activeText: "UZBEQCHA",
                            inactiveText: "Русский язык",
                            onToggle: (val) {
                              languageStatus = val;
                              onLanguageToggle(val);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: LocalSwitch(
                            value: themeStatus,
                            activeText: "Темная тема",
                            inactiveText: "Светлая тема",
                            onToggle: (value) {
                              themeStatus = value;
                              onDarkLightToggle(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: SingleButton(
                              title: 'Выход из приложения',
                              onPressed: onTapSignOut)
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SingleButton(
                              title: 'QrCodeScaner',
                              onPressed: onTapCodeScaner)
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0,),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     Expanded(
                    //       child: LocalSwitch(
                    //         value: userStatus,
                    //         activeText: "Поставщик",
                    //         inactiveText: "Заказчик",
                    //         onToggle: (v) {
                    //           userStatus = v;
                    //           onStatusToggle(v);
                    //         },
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //     Expanded(
                    //       child: LocalSwitch(
                    //         value: themeStatus,
                    //         activeText: "Темная тема",
                    //         inactiveText: "Светлая тема",
                    //         onToggle: (value) {
                    //           themeStatus = value;
                    //           onDarkLightToggle(value);
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // TextButton(
                    //     onPressed: ()=> exitTap,
                    //     child: Text('Выйти'))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Future<File> pickFromCameraImage() async {
    final pickedImageFromCamera =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImageFromCamera != null) {
      print('Изображение успешно выбрано!');
    }
    return File(pickedImageFromCamera!.path);
  }

  Future pickFromGalleryImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      print('Изображение успешно выбрано!');
      return pickedImage;
    }
  }


  Future <String> pickAndReadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );
    PlatformFile file = result!.files.first;
    return file.path!;
  }


  Future<String> saveExcelFile({required String fileName, required List<PositionModel> data}) async {
    final excel = Excel.createExcel();
    final sheetObject = excel['Sheet1'];
    List<dynamic> headers = ["№","Наименование","Ед/из","Закупочная цена","Маржа","Отпускная цена","В наличии","Обновлено"];
    sheetObject.appendRow(headers.map((value) => TextCellValue(value)).toList());

    for(int i = 0; i < data.length; i++){
      int indexNum = i+1;

      sheetObject.appendRow([
        TextCellValue(indexNum.toString()),
        TextCellValue(data[i].productName),
        TextCellValue(data[i].productMeasure),
        TextCellValue(numberParse(value: data[i].productFirsPrice)),
        TextCellValue(data[i].marginality.toString()),
        TextCellValue(numberParse(value: data[i].productPrice)),
        TextCellValue(numberParse(value: data[i].productQuantity)),
        TextCellValue(dateParse(milliseconds: data[i].addedAt)),
      ]);
    }

    final excelBytes = excel.encode();

    final docsDir = await getApplicationDocumentsDirectory();
    var filePath = "${docsDir.path}/$fileName.xlsx";


    final file = File(filePath);
    await file.writeAsBytes(excelBytes!);

    return filePath;
  }

  Future<String> saveExcelUnitedFile({required String fileName, required List<PositionModel> data}) async {
    final excel = Excel.createExcel();
    final sheetObject = excel['Sheet1'];
    List<dynamic> headers = ["№","Наименование","Ед/из","Закупочная цена","Кол-во","Сумма",];
    sheetObject.appendRow(headers.map((value) => TextCellValue(value)).toList());

    for(int i = 0; i < data.length; i++){
      int indexNum = i+1;

      sheetObject.appendRow([
        TextCellValue(indexNum.toString()),
        TextCellValue(data[i].productName),
        TextCellValue(data[i].productMeasure),
        TextCellValue(numberParse(value: data[i].productFirsPrice)),
        TextCellValue(numberParse(value: data[i].united)),
        TextCellValue(numberParse(value: (data[i].productFirsPrice * data[i].united))),
      ]);
    }

    final excelBytes = excel.encode();

    final docsDir = await getApplicationDocumentsDirectory();
    var filePath = "${docsDir.path}/$fileName.xlsx";


    final file = File(filePath);
    await file.writeAsBytes(excelBytes!);

    return filePath;
  }

  Future<String> saveExcelPurchasingFile({required String fileName, required List<PurchasingModel> data}) async {
    final excel = Excel.createExcel();
    final sheetObject = excel['Sheet1'];
    List<dynamic> headers = [
      "№",
      "Наименование",
      "Ед/из",
      "Закупочная цена",
      "Заявленое кол-во",
      "Сумма",
      "Факт цена",
      "Факт кол-во",
      "Факт сумма",
      "Приход кол-во",
      "Дата принятия",
      "Дата прихода",
      "Закупщик",
    ];
    sheetObject.appendRow(headers.map((value) => TextCellValue(value)).toList());

    for(int i = 0; i < data.length; i++){
      int indexNum = i+1;
      sheetObject.appendRow([
        TextCellValue(indexNum.toString()),
        TextCellValue(data[i].productName),
        TextCellValue(data[i].productMeasure),
        TextCellValue(numberParse(value: data[i].firsPrice)),
        TextCellValue(numberParse(value: data[i].orderQty)),
        TextCellValue(numberParse(value: (data[i].firsPrice * data[i].orderQty))),
        TextCellValue(numberParse(value: data[i].actualPrice)),
        TextCellValue(numberParse(value: data[i].actualQty)),
        TextCellValue(numberParse(value:(data[i].actualPrice * data[i].actualQty))),
        TextCellValue(numberParse(value: data[i].receivedQuantity)),
        TextCellValue(dateParse(milliseconds: data[i].selectedTime)),
        TextCellValue(dateParse(milliseconds: data[i].receivedDate!)),
        TextCellValue(data[i].buyerName),
      ]);
    }

    final excelBytes = excel.encode();

    final docsDir = await getApplicationDocumentsDirectory();
    var filePath = "${docsDir.path}/$fileName.xlsx";


    final file = File(filePath);
    await file.writeAsBytes(excelBytes!);

    return filePath;
  }

  Future<String> createSampleExcelFile() async {
    final excel = Excel.createExcel();
    final sheetObject = excel['Sheet1'];
    List<dynamic> headers = ["Наименование","Ед/из","Закупочная цена","Маржа %","Отпускная цена",];
    sheetObject.appendRow(headers.map((value) => TextCellValue(value)).toList());
    final excelBytes = excel.encode();
    final docsDir = await getApplicationDocumentsDirectory();
    var filePath = "${docsDir.path}/sample.xlsx";
    final file = File(filePath);
    await file.writeAsBytes(excelBytes!);
    return filePath;
  }




  Future<void> dialogBuilder(
      {required BuildContext context,
        String? title,
        required Widget content,
        VoidCallback? onPositivePressed,
        VoidCallback? onNeutralPressed,
        String? btnNeutralText,
        String? btnPositiveText,
        double? contentPadding,
        bool? isActions = true,
      }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          actionsPadding:EdgeInsets.zero,
          contentPadding: EdgeInsets.all(contentPadding!),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: title != null
              ? Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          )
              : const SizedBox.shrink(),
          content: content,
          actions: isActions! ? <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: onPositivePressed,
              child: Text(btnPositiveText!),
            ),
            if (onNeutralPressed != null)
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: onNeutralPressed,
                child: Text(btnNeutralText!),
              ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ]
          :
          [],
        );
      },
    );
  }

}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
