import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ya_bazaar/res/utils.dart';

class PdfService {
  Utils utils = Utils();

  Future<Uint8List> createDocument({
    required String invoice,
    required num total,
    required String objectName,
    required String createDate,
    required String acceptedDate,
    required List<OrderModel> orderPositionsList,
  }) async {
    List<OrderModel> orderPositionsList2 =
        orderPositionsList.map((OrderModel e) {
      e.discountSum = (e.productPrice * e.productQuantity) - e.amountSum;

      return e;
    }).toList();
    List<num> discountSums = [];
    num totalAfterDiscount = 0;
    if (orderPositionsList.isNotEmpty) {
      discountSums = orderPositionsList
          .map((OrderModel e) => e.productQuantity * e.productPrice)
          .toList();
      totalAfterDiscount = discountSums.reduce((v, e) => v + e);
    }

    var data = await rootBundle.load("assets/fonts/unifont.ttf");
    var myTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(data),
      bold: pw.Font.ttf(data),
      italic: pw.Font.ttf(data),
      boldItalic: pw.Font.ttf(data),
      fontFallback: [pw.Font.ttf(data)],
    );

    var pdf = pw.Document(
      theme: myTheme,
    );



    // var dataRegular = await rootBundle.load("assets/fonts/unifont-regular.ttf");
    // var dataBold = await rootBundle.load("assets/fonts/unifont-bold.ttf");
    // var dataItalic = await rootBundle.load("assets/fonts/unifont-italic.ttf");
    // var dataBoldItalic = await rootBundle.load("assets/fonts/unifont-bolditalic.ttf");
    //
    // var myTheme = pw.ThemeData.withFont(
    //   base: pw.Font.ttf(dataRegular),
    //   bold: pw.Font.ttf(dataBold),
    //   italic: pw.Font.ttf(dataItalic),
    //   boldItalic: pw.Font.ttf(dataBoldItalic),
    //   fontFallback: [pw.Font.ttf(dataRegular)],
    // );
    //
    // var pdf = pw.Document(
    //   theme: myTheme,
    // );







    int batchSize = 35; // Размер порции

    List<List<OrderModel>> batches = [];

    for (int i = 0; i < orderPositionsList2.length; i += batchSize) {
      int end = (i + batchSize < orderPositionsList2.length)
          ? i + batchSize
          : orderPositionsList2.length;
      batches.add(orderPositionsList2.sublist(i, end));
    }

    // // Вывод порций
    // for (int i = 0; i < batches.length; i++) {
    //   print('Batch ${i + 1}: ${batches[i].map((order) => order.productName).toList()}');
    // }

    for (int i = 0; i < batches.length; i++) {
      pdf.addPage(
        pw.Page(
            margin: const pw.EdgeInsets.all(26.0),
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              // Проверка, помещается ли контент на текущей странице
              final double remainingHeight =
                  (context.page.pageFormat.availableHeight - context.page.size);
              final double remainingHeight2 =
                  context.page.pageFormat.availableHeight;
              final int remainingHeight3 = context.page.contents.length;
              final int remainingHeight4 = context.pageNumber;
              var remainingHeight5 = context.document.pdfPageList;
              print('-----------------remainingHeight--------------------');
              print(remainingHeight);
              print('-----------------remainingHeight2--------------------');
              print(remainingHeight2);
              print('-----------------remainingHeight3--------------------');
              print(remainingHeight3);
              print('-----------------remainingHeight4--------------------');
              print(remainingHeight4);
              print('-----------------remainingHeight5--------------------');
              print(remainingHeight5);

              return pw.Column(
                children: [
                  pw.Column(children: [
                    pw.Row(
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Накладная № $invoice"),
                              pw.Text("Получатель: $objectName"),
                              pw.Text("Дата оформления заказа: $createDate"),
                              pw.Text("Дата принятия заказа: $acceptedDate"),
                              pw.Text(
                                  "Страница: ${i + 1} из ${batches.length}"),
                            ])
                      ],
                    ),
                    pw.SizedBox(height: 16.0),
                    // pw.Container(
                    //   color: const PdfColor.fromInt(0xFFEEEEEE),
                    //   child: pw.Table(
                    //       border: pw.TableBorder.all(
                    //           color: const PdfColor.fromInt(0xFFFFFFFF), width: 0.8),
                    //       children: [
                    //     pw.TableRow(children: [
                    //       pw.Expanded(
                    //           flex: 1,
                    //           child:
                    //               pw.Text("#", textAlign: pw.TextAlign.center)),
                    //       pw.Expanded(
                    //           flex: 3,
                    //           child: pw.Text("Наименование",
                    //               textAlign: pw.TextAlign.center)),
                    //       pw.Expanded(
                    //           flex: 1,
                    //           child: pw.Text("Ед/изм",
                    //               textAlign: pw.TextAlign.center)),
                    //       pw.Expanded(
                    //           flex: 1,
                    //           child: pw.Text("Кол-во",
                    //               textAlign: pw.TextAlign.right)),
                    //       pw.Expanded(
                    //           flex: 2,
                    //           child: pw.Text("Цена/ед",
                    //               textAlign: pw.TextAlign.right)),
                    //       // pw.Expanded(
                    //       //     child: pw.Text("Сумма скидки",
                    //       //         textAlign: pw.TextAlign.center)),
                    //       pw.Expanded(
                    //           flex: 2,
                    //           child: pw.Text("Цена/ед после скидки",
                    //               textAlign: pw.TextAlign.right)),
                    //       // pw.Expanded(
                    //       //     child: pw.Text("Сумма",
                    //       //         textAlign: pw.TextAlign.center)),
                    //       pw.Expanded(
                    //           flex: 2,
                    //           child: pw.Text("Сумма экстра скидки",
                    //               textAlign: pw.TextAlign.right)),
                    //       pw.Expanded(
                    //         flex: 2,
                    //           child: pw.Text("Сумма после экстра скидки",
                    //               textAlign: pw.TextAlign.right)),
                    //     ])
                    //   ]),
                    //
                    //   // pw.Row(
                    //   //   children: [
                    //   //     pw.Container(
                    //   //         width: 16.0,
                    //   //         child: pw.Text("#", textAlign: pw.TextAlign.center)),
                    //   //     pw.Container(
                    //   //         width: 128.0,
                    //   //         child: pw.Text("Наименование",
                    //   //             textAlign: pw.TextAlign.center)),
                    //   //     pw.Container(
                    //   //         width: 38.0,
                    //   //         child: pw.Text("Ед/изм", textAlign: pw.TextAlign.center)),
                    //   //     pw.Container(
                    //   //         width: 48.0,
                    //   //         child: pw.Text("Кол-во", textAlign: pw.TextAlign.center)),
                    //   //     pw.Expanded(
                    //   //         child: pw.Text("Цена/ед",
                    //   //             textAlign: pw.TextAlign.center)),
                    //   //     // pw.Expanded(
                    //   //     //     child: pw.Text("Сумма скидки",
                    //   //     //         textAlign: pw.TextAlign.center)),
                    //   //     pw.Expanded(
                    //   //         child:
                    //   //         pw.Text("Цена/ед после скидки", textAlign: pw.TextAlign.center)),
                    //   //     // pw.Expanded(
                    //   //     //     child: pw.Text("Сумма",
                    //   //     //         textAlign: pw.TextAlign.center)),
                    //   //     pw.Expanded(
                    //   //         child: pw.Text("Сумма экстра скидки",
                    //   //             textAlign: pw.TextAlign.center)),
                    //   //     pw.Expanded(
                    //   //         child: pw.Text("Сумма после экстра скидки",
                    //   //             textAlign: pw.TextAlign.center)),
                    //   //   ],
                    //   // ),
                    // ),
                    // pw.SizedBox(height: 5),
                  ]),

                  //_itemColumn(elements:orderPositionsList2),
                  //generatePdf(orderList: orderPositionsList2),
                  generatePdf2(
                      orderList:
                          batches[i].map((OrderModel order) => order).toList()),

                  if (i == batches.length - 1)
                    pw.Column(children: [
                      pw.SizedBox(height: 25),
                      pw.Container(
                        color: const PdfColor.fromInt(0xFFEEEEEE),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Всего на сумму:"),
                            pw.Text(
                                'До скидки: ${utils.numberParse(value: totalAfterDiscount)}'),
                            pw.Text(
                                'Скидка: ${utils.numberParse(value: totalAfterDiscount - total)}'),
                            pw.Text(
                                'После скидки: ${utils.numberParse(value: total)}'),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Кешбэк:"),
                          pw.Text('0 %'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        color: const PdfColor.fromInt(0xFFEEEEEE),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Итого к оплате:"),
                            pw.Text(utils.numberParse(value: total)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 50),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Сдал: ____________________________"),
                          pw.Text("Принял: __________________________"),
                        ],
                      ),
                    ]),
                ],
              );
            }),
      );
    }

    return pdf.save();
  }

  pw.Widget generatePdf2({
    required List<OrderModel> orderList,
  }) {
    return pw.Column(
      children: [

        pw.Container(
          color: const PdfColor.fromInt(0xFFEEEEEE),
          child: pw.Table(
              border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0xFFFFFFFF), width: 0.8),
              children: [
                pw.TableRow(
                  children: [

                    pw.Expanded(
                        flex: 1,
                        child: pw.Text('№',
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    pw.Expanded(
                        flex: 6,
                        //padding: const pw.EdgeInsets.only(left: 3.0),
                        child: pw.Text('Наименование',
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text('Ед/изм',
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text('Кол-во'.toString(),
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text('Цена/ед',
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    // pw.Expanded(
                    //     child: pw.Text(
                    //         utils.numberParse(value: discountSum),
                    //         textAlign: pw.TextAlign.center)),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text('Цена/ед после скидки',
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    // pw.Expanded(
                    //     child: pw.Text(
                    //         utils.numberParse(value: orderList[i].amountSum),
                    //         textAlign: pw.TextAlign.center)),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text('Сумма экстра скидки',
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text('Цена/ед после экстра скидки',
                            textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                    pw.Expanded(
                        flex: 3,
                        child: pw.Text('Сумма после экстра скидки',
                            textAlign: pw.TextAlign.center,style:  const pw.TextStyle(fontSize: 10.0)))
                  ],
                )
              ]

          ),
        ),

    pw.SizedBox(height: 6.0),


    pw.ListView.builder(
    itemCount: orderList.length,
      itemBuilder: (context, i) {

        num discountSum = (orderList[i].productPrice * orderList[i].discountPercent!) / 100;
        num afterDiscountSum = (orderList[i].productPrice - discountSum);

        num lastDiscountPercent = orderList[i].lastDiscountPercent;
        num lastPercentSum = (orderList[i].amountSum * lastDiscountPercent) / 100;
        num lastAmountSum = (orderList[i].amountSum - lastPercentSum);

        return pw.Table(
            border: pw.TableBorder.all(
                color: const PdfColor.fromInt(0xFFEEEEEE), width: 0.8),
            children: [
              pw.TableRow(
                children: [

                  pw.Expanded(
                      flex: 1,
                      child: pw.Text(orderList[i].index.toString(),
                          textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                  pw.Expanded(
                      flex: 6,
                      //padding: const pw.EdgeInsets.only(left: 3.0),
                      child: pw.Text(orderList[i].productName,
                          textAlign: pw.TextAlign.left,style: const pw.TextStyle(fontSize: 10.0,))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(orderList[i].productMeasure,
                          textAlign: pw.TextAlign.center,style: const pw.TextStyle(fontSize: 10.0,))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(orderList[i].productQuantity.toString(),
                          textAlign: pw.TextAlign.right,style: const pw.TextStyle(fontSize: 10.0,color: PdfColor.fromInt(0xFFFF0000)))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                          utils.numberParse(value: orderList[i].productPrice),
                          textAlign: pw.TextAlign.right,style: const pw.TextStyle(fontSize: 10.0,))),
                  // pw.Expanded(
                  //     child: pw.Text(
                  //         utils.numberParse(value: discountSum),
                  //         textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                          utils.numberParse(
                              value: afterDiscountSum),
                          textAlign: pw.TextAlign.right,style: const pw.TextStyle(fontSize: 10.0,))),
                  // pw.Expanded(
                  //     child: pw.Text(
                  //         utils.numberParse(value: orderList[i].amountSum),
                  //         textAlign: pw.TextAlign.center)),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(utils.numberParse(value: lastPercentSum),
                          textAlign: pw.TextAlign.right,style: const pw.TextStyle(fontSize: 10.0,))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(utils.numberParse(value: (lastAmountSum/orderList[i].productQuantity)),
                          textAlign: pw.TextAlign.right,style: const pw.TextStyle(fontSize: 10.0,color: PdfColor.fromInt(0xFFFF0000)))),
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(utils.numberParse(value: lastAmountSum),
                          textAlign: pw.TextAlign.right,style:  const pw.TextStyle(fontSize: 10.0,color: PdfColor.fromInt(0xFFFF0000))))
                ],
              )
            ]

          // pw.Row(
          //   children: [
          //     pw.Container(
          //         width: 15,
          //         child: pw.Text(orderList[i].index.toString(),
          //             textAlign: pw.TextAlign.left)),
          //     pw.Container(
          //         width: 160,
          //         child: pw.Text(orderList[i].productName,
          //             textAlign: pw.TextAlign.left)),
          //     pw.Expanded(
          //         child: pw.Text(orderList[i].productMeasure,
          //             textAlign: pw.TextAlign.right)),
          //     pw.Expanded(
          //         child: pw.Text(orderList[i].productQuantity.toString(),
          //             textAlign: pw.TextAlign.right)),
          //     pw.Expanded(
          //         child: pw.Text(
          //             utils.numberParse(value: orderList[i].productPrice),
          //             textAlign: pw.TextAlign.right)),
          //     // pw.Expanded(
          //     //     child: pw.Text(
          //     //         utils.numberParse(
          //     //             value: (orderList[i].productPrice * orderList[i].productQuantity)),
          //     //         textAlign: pw.TextAlign.right)),
          //     pw.Expanded(
          //         child: pw.Text(
          //             utils.numberParse(value: discountSum),
          //             textAlign: pw.TextAlign.right)),
          //
          //
          //     pw.Expanded(
          //         child: pw.Text(
          //             utils.numberParse(
          //                 value: (orderList[i].productPrice - discountSum)),
          //             textAlign: pw.TextAlign.right)),
          //
          //
          //
          //     pw.Expanded(
          //         child: pw.Text(
          //             utils.numberParse(value: orderList[i].amountSum),
          //             textAlign: pw.TextAlign.right))
          //   ],
          // ),
        );
      },
    )








      ]
    );
  }

  Future<File> savePdfFile(
      {required String fileName, required Uint8List byteList}) async {
    final docsDir = await getApplicationDocumentsDirectory();
    var filePath = "${docsDir.path}/$fileName.pdf";

    final file = File(filePath);
    await file.writeAsBytes(byteList);
    OpenFile.open(filePath);
    return file;
  }

// pw.Widget _itemColumn({required List<OrderModel> elements}) {
//   int ind = 0;
//   return pw.Container(
//     child: pw.Column(
//       children: [
//         for (int i = 0; i < elements.length; i++)
//           pw.Container(
//             decoration: const pw.BoxDecoration(
//               border: pw.Border(
//                 bottom: pw.BorderSide(
//                   color: PdfColor.fromInt(0xFF000000),
//                   width: 0.5,
//                 ),
//               ),
//             ),
//             child: pw.Row(
//               children: [
//                 pw.Container(
//                     width: 15,
//                     child: pw.Text((i + 1).toString(),
//                         textAlign: pw.TextAlign.left)),
//                 pw.Container(
//                     width: 160,
//                     child: pw.Text(elements[i].productName,
//                         textAlign: pw.TextAlign.left)),
//                 pw.Expanded(
//                     child: pw.Text(elements[i].productMeasure,
//                         textAlign: pw.TextAlign.right)),
//                 pw.Expanded(
//                     child: pw.Text(elements[i].productQuantity.toString(),
//                         textAlign: pw.TextAlign.right)),
//                 pw.Expanded(
//                     child: pw.Text(
//                         utils.numberParse(value: elements[i].productPrice),
//                         textAlign: pw.TextAlign.right)),
//                 pw.Expanded(
//                     child: pw.Text(
//                         utils.numberParse(
//                             value: (elements[i].productPrice *
//                                 elements[i].productQuantity)),
//                         textAlign: pw.TextAlign.right)),
//                 pw.Expanded(
//                     child: pw.Text(
//                         utils.numberParse(
//                             value: (elements[i].productPrice *
//                                 elements[i].productQuantity) -
//                                 elements[i].amountSum),
//                         textAlign: pw.TextAlign.right)),
//                 pw.Expanded(
//                     child: pw.Text(
//                         utils.numberParse(value: elements[i].amountSum),
//                         textAlign: pw.TextAlign.right))
//               ],
//             ),
//           ),
//       ],
//     ),
//   );
// }
//
// pw.Widget generatePdf({
//   required List<OrderModel> orderList,
// }) {
//   return pw.ListView.builder(
//     itemCount: orderList.length,
//     itemBuilder: (context, i) {
//       final double remainingHeight = context.page.pageFormat.availableHeight;
//
//       // Если элемент не помещается на текущей странице, начать новую страницу
//       if (remainingHeight < 20) {
//         return pw.ListView.builder(
//           itemBuilder: (context, newIndex) {
//             return buildOrderItem(context, orderList[newIndex], newIndex);
//           },
//           itemCount: orderList.length,
//         );
//       }
//
//       // Иначе продолжить добавление элементов
//       return buildOrderItem(context, orderList[i], i);
//     },
//   );
// }
//
// pw.Widget buildOrderItem(pw.Context context, OrderModel order, int indexNum) {
//   return pw.Container(
//     decoration: const pw.BoxDecoration(
//       border: pw.Border(
//         bottom: pw.BorderSide(
//           color: PdfColor.fromInt(0xFF000000),
//           width: 0.5,
//         ),
//       ),
//     ),
//     child: pw.Row(
//       children: [
//         pw.Container(
//             width: 15,
//             child: pw.Text(('${indexNum + 1}').toString(),
//                 textAlign: pw.TextAlign.left)),
//         pw.Container(
//             width: 160,
//             child: pw.Text(order.productName,
//                 textAlign: pw.TextAlign.left)),
//         pw.Expanded(
//             child: pw.Text(order.productMeasure,
//                 textAlign: pw.TextAlign.right)),
//         pw.Expanded(
//             child: pw.Text(order.productQuantity.toString(),
//                 textAlign: pw.TextAlign.right)),
//         pw.Expanded(
//             child: pw.Text(
//                 utils.numberParse(value: order.productPrice),
//                 textAlign: pw.TextAlign.right)),
//         pw.Expanded(
//             child: pw.Text(
//                 utils.numberParse(
//                     value: (order.productPrice *
//                         order.productQuantity)),
//                 textAlign: pw.TextAlign.right)),
//         pw.Expanded(
//             child: pw.Text(
//                 utils.numberParse(
//                     value: (order.productPrice *
//                         order.productQuantity) -
//                         order.amountSum),
//                 textAlign: pw.TextAlign.right)),
//         pw.Expanded(
//             child: pw.Text(
//                 utils.numberParse(value: order.amountSum),
//                 textAlign: pw.TextAlign.right))
//       ],
//     ),
//   );
// }
}
