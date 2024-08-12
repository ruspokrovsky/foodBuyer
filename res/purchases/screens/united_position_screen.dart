import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/providers.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/purchases/purchase_services/purchase_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/chip_btn.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/search_widget.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class UnitedPositionScreen extends ConsumerStatefulWidget {
  static const String routeName = 'unitedPositionScreen';

  const UnitedPositionScreen({super.key});

  @override
  UnitedPositionScreenState createState() => UnitedPositionScreenState();
}

class UnitedPositionScreenState extends ConsumerState<UnitedPositionScreen> {

  Navigation navigation = Navigation();
  List<PositionModel> unitedPositionList = [];
  String query = '';

  bool isSelected = false;

  Widget _popUpMenuBtn(BuildContext context, WidgetRef ref){


    if((ref.watch(currentUserProvider).userRole == 'admin')){
      return PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          onSelected: (int itemIndex) {
            if (itemIndex == 0) {
              navigation.navigateToPurchaseListScreen(context);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 0,
                child: const Text('Закуп')),
          ]);
    }else {
      return IconButton(
          onPressed: (){},
          icon: const Icon(Icons.add_home_outlined));
    }



  }

  // Future<void> getAllPosition() async {
  //   late HomeFBServices dbs = HomeFBServices();
  //   var streamAllPosition = dbs.getAllPosition();
  //
  //   streamAllPosition.listen(
  //     (data) {
  //       ref.read(allPositionListProvider.notifier)
  //         ..clearAllPosition()
  //         ..buildAllPositionList(
  //           data,
  //         );
  //       setState(() {});
  //     },
  //   );
  // }



  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {

        num total = 0;
        List<num> amountsList = [];

        ref.watch(getPositionsByRootIdProvider(ref.watch(currentUserProvider).rootId!))
            .whenData((value) async{
          ref.read(positionsListProvider.notifier)
            ..clearPositions()
            ..buildPositionList(value,);
        });

        ref.listen(getAllPositionProvider, (previous, next) {
          setState(() {});
        });

        //список объем на закуп формируется из коллекции
        // product по полю united если поле больше нуля значит отоброжаем

        unitedPositionList = ref.watch(positionsListProvider)
            .where((element) => element.united > 0 ).toList();

        //создаем список amounts для вывода total

        if(unitedPositionList.isNotEmpty){
          for (var element in unitedPositionList) {
            num amounts = (element.united * element.productFirsPrice);
            amountsList.add(amounts);
          }

          total = amountsList.reduce((v, e) => v +  e);

        }

        if (query.isNotEmpty) {
          unitedPositionList = unitedPositionList.where((book) {
            final titleLower = book.productName.toLowerCase();
            final searchLower = query.toLowerCase();
            return titleLower.contains(searchLower);
          }).toList();
        }

        return BaseLayout(
            onWillPop: (){return Future.value(true);},
            isAppBar: true,
            isBottomNav: false,
            isFloatingContainer: true,
            appBarTitle: 'Объемы на закуп',
            flexibleContainerChild: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: EdgeInsets.zero,
                //shrinkWrap:true,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichSpanText(spanText: SnapTextModel(title: 'Всего позиций: ', data: unitedPositionList.length.toString(), postTitle: '')),
                          RichSpanText(spanText: SnapTextModel(title: 'На сумму: ', data: Utils().numberParse(value: total), postTitle: ' UZS')),
                        ],
                      ),

                      ChipButton(
                          lable: 'Распечатать',
                          onTap: () async {
                        String fileName = 'Объем на закуп от ${Utils().dateParse(milliseconds: DateTime.now().millisecondsSinceEpoch)}';

                        await Utils().saveExcelUnitedFile(fileName: fileName, data: unitedPositionList)
                            .then((String filePath) async{
                          await OpenFile.open(filePath);
                        });
                      },
                        avatar: const Icon(Icons.print, color: Colors.white,),

                      ),

                      // SingleButton(title: 'Распечатать', onPressed: () async {
                      //   String fileName = 'Объем на закуп от ${Utils().dateParse(milliseconds: DateTime.now().millisecondsSinceEpoch)}';
                      //
                      //   await Utils().saveExcelUnitedFile(fileName: fileName, data: unitedPositionList)
                      //       .then((String filePath) async{
                      //     await OpenFile.open(filePath);
                      //   });
                      // })
                    ],
                  ),

                  const SizedBox(height: 8.0,),

                  buildSearch(categoryPressed: (){}, onTapJoinPosition: (){}, onTapCart: (){}),




                  // SingleButton(title: 'К закупу', onPressed: (){
                  //   navigation.navigateToPurchaseListScreen(context);
                  // }),

                ],
              ),
            ),
            flexibleSpaceBarTitle: const SizedBox.shrink(),
            slivers: [
              _contentListView(context: context, ref: ref, unitedPositionList: unitedPositionList,),
            const SliverToBoxAdapter(child: SizedBox(height: 100.0,),)],
          floatingContainer:  Container(
              margin: const EdgeInsets.only(left: 5.0, bottom: 5.0, right: 5.0),
            width: MediaQuery.of(context).size.width,
            child: SingleButton(title: 'Мониторинг', onPressed: (){
               navigation.navigateToPurchaseListScreen(context);
             }),
          ),
          isProgress: ref.watch(progressBoolProvider),
          isPinned: false,
          radiusCircular: 0.0,
          flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
          expandedHeight: 126.0, );
      },
    );

    //   Consumer(
    //   builder: (BuildContext context, WidgetRef ref, Widget? child) {
    //
    //     String total = '';
    //     List<num> amountsList = [];
    //
    //
    //
    //     ref.watch(getPositionsByRootIdProvider(ref.watch(currentUserProvider).rootId!))
    //         .whenData((value) async{
    //       ref.read(positionsListProvider.notifier)
    //         ..clearPositions()
    //         ..buildPositionList(value,);
    //     });
    //
    //     ref.listen(getAllPositionProvider, (previous, next) {
    //       setState(() {});
    //     });
    //
    //     //список объем на закуп формируется из коллекции
    //     // product по полю united если поле больше нуля значит отоброжаем
    //
    //     List<PositionModel> unitedPositionList = ref.watch(positionsListProvider)
    //         .where((element) => element.united > 0 ).toList();
    //
    //     //создаем список amounts для вывода total
    //
    //     if(unitedPositionList.isNotEmpty){
    //       for (var element in unitedPositionList) {
    //         num amounts = (element.united * element.productFirsPrice);
    //         amountsList.add(amounts);
    //       }
    //
    //       total = amountsList.reduce((v, e) => v +  e).toString();
    //
    //     }
    //     return
    //       Stack(
    //         children: [
    //           Scaffold(
    //               appBar:
    //
    //               PreferredSize(
    //                 preferredSize: const Size.fromHeight(80.0),
    //                 child: AppBar(
    //                   toolbarHeight: 80.0,
    //                   title: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text('Объемы на закуп',style: styles.appBarTitleTextStyle,),
    //                       RichText(
    //                         text: TextSpan(
    //                           text: 'Всего позиций: ',
    //                           style: styles.smalTitleTextStyle,
    //                           children: <TextSpan>[
    //                             TextSpan(text: unitedPositionList.length.toString()),
    //                           ],
    //                         ),
    //                       ),
    //                       RichText(
    //                         text: TextSpan(
    //                           text: 'На сумму: ',
    //                           style: styles.smalTitleTextStyle,
    //                           children: <TextSpan>[
    //                             TextSpan(text: total),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   actions: [
    //                     _popUpMenuBtn(context, ref),
    //                   ],
    //                 ),
    //               ),
    //               body: Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: ListView.builder(
    //                   itemCount: unitedPositionList.length,
    //                   itemBuilder: (BuildContext context, int index) {
    //
    //                     num amountSum = (unitedPositionList[index].productFirsPrice
    //                         * unitedPositionList[index].united);
    //
    //
    //                     return Container(
    //                       margin: const EdgeInsets.only(bottom: 5.0),
    //                       decoration: BoxDecoration(
    //                           border: Border.all(
    //                               width: 2,
    //                               color: Colors.grey),
    //                           borderRadius:
    //                           const BorderRadius.all(Radius.circular(10.0))),
    //                       child: Stack(
    //                         children: [
    //                           ListTile(
    //                             title: Text(unitedPositionList[index].productName, style: DefaultTextStyle.of(context).style,),
    //                             subtitle: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 RichText(
    //                                   text: TextSpan(
    //                                     text: 'Закупить: ',
    //                                     style: DefaultTextStyle.of(context).style,
    //                                     children: <TextSpan>[
    //                                       TextSpan(
    //                                           text: unitedPositionList[index].united.toString()),
    //                                       TextSpan(
    //                                           text:
    //                                           ' /${unitedPositionList[index].productMeasure}'),
    //                                     ],
    //                                   ),
    //                                 ),
    //                                 RichText(
    //                                   text: TextSpan(
    //                                     text: 'Закупочная цена: ~',
    //                                     style: DefaultTextStyle.of(context).style,
    //                                     children: <TextSpan>[
    //                                       TextSpan(
    //                                           text: Utils().numberParse(value: unitedPositionList[index].productFirsPrice)
    //
    //                                       ),
    //                                       TextSpan(
    //                                           text:
    //                                           ' /${unitedPositionList[index].productMeasure}'),
    //                                     ],
    //                                   ),
    //                                 ),
    //                                 RichText(
    //                                   text: TextSpan(
    //                                     text: 'Сумма: ~',
    //                                     style: DefaultTextStyle.of(context).style,
    //                                     children: <TextSpan>[
    //                                       TextSpan(text: Utils().numberParse(value: amountSum)),
    //                                       TextSpan(text: ' /UZS'),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //
    //                             onTap: () async{
    //                               ref.read(progressBoolProvider.notifier).updateProgressBool(true);
    //                               PurchasingModel purchasingModel = PurchasingModel(
    //                                 projectRootId: unitedPositionList[index].projectRootId,
    //                                 buyerId: ref.watch(currentUserProvider).uId,
    //                                 buyerName: ref.watch(currentUserProvider).name,
    //                                 selectedTime: 0,
    //                                 firsPrice: unitedPositionList[index].productFirsPrice,
    //                                 actualPrice: 0,
    //                                 actualQty: 0,
    //                                 productName: unitedPositionList[index].productName,
    //                                 productId: unitedPositionList[index].docId!,
    //                                 productMeasure: unitedPositionList[index].productMeasure,
    //                                 orderQty: unitedPositionList[index].united,
    //                                 purchasingStatus: 1,
    //                                 positionImgUrl: unitedPositionList[index].productImage,);
    //                               await fbs.addPurchase(
    //                                   rootId: unitedPositionList[index].projectRootId,
    //                                   purchasingModel: purchasingModel,)
    //                                   .whenComplete(() async {
    //                                 ref.read(progressBoolProvider.notifier).updateProgressBool(false);
    //                                 print('succss---addPurchaseaddPurchase----');
    //                               });
    //
    //                             },
    //                           ),
    //
    //                           if(isSelected)
    //                             const Positioned(
    //                                 top: 0.0,
    //                                 right: 0.0,
    //                                 bottom: 0.0,
    //                                 child: ProgressMini()),
    //                         ],
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               )
    //           ),
    //           ref.watch(progressBoolProvider) ?
    //           const ProgressDialog()
    //               : const SizedBox.shrink(),
    //         ],
    //       );
    //
    //   },
    // );
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
    final books = unitedPositionList.where((book) {
      final titleLower = book.productName.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    if (query.isNotEmpty) {
      unitedPositionList = books;
    } else {
      setState(() {
        unitedPositionList = [];
        //getAllPosition();
      });
    }
    setState(() {
      this.query = query;
    });
  }

}


Widget _contentListView({
  required BuildContext context,
  required WidgetRef ref,
  required List<PositionModel> unitedPositionList,
}){
  AppStyles styles = AppStyles.appStyle(context);
  final PurchaseFBServices fbs = PurchaseFBServices();

  return SliverPadding(
    padding: const EdgeInsets.all(5.0),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          num amountSum = (unitedPositionList[index].productFirsPrice
              * unitedPositionList[index].united);
          return Container(
            margin: const EdgeInsets.only(bottom: 5.0,),
            decoration: styles.positionBoxDecoration,
            child: Stack(
              children: [
                ListTile(
                  title: Text(unitedPositionList[index].productName, style: Theme.of(context).textTheme.bodyLarge,),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Закупить: ',
                              data: Utils().numberParse(value: unitedPositionList[index].united),
                              postTitle: ' /${unitedPositionList[index].productMeasure}')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Закупочная цена: ~ ',
                              data: Utils().numberParse(value: unitedPositionList[index].productFirsPrice),
                              postTitle: ' UZS/ ${unitedPositionList[index].productMeasure}')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Сумма: ~ ',
                              data: Utils().numberParse(value: amountSum),
                              postTitle: ' UZS')),

                    ],
                  ),
                  onLongPress: () async{

                    if(ref.watch(currentUserProvider).userRoles!.contains('buyer')){
                      ref.read(progressBoolProvider.notifier).updateProgressBool(true);

                      PurchasingModel purchasingModel = PurchasingModel(
                        projectRootId: unitedPositionList[index].projectRootId,
                        buyerId: ref.watch(currentUserProvider).uId,
                        buyerName: ref.watch(currentUserProvider).name,
                        selectedTime: 0,
                        firsPrice: unitedPositionList[index].productFirsPrice,
                        actualPrice: 0,
                        actualQty: 0,
                        productName: unitedPositionList[index].productName,
                        productId: unitedPositionList[index].docId!,
                        productMeasure: unitedPositionList[index].productMeasure,
                        orderQty: unitedPositionList[index].united,
                        purchasingStatus: 1,
                        positionImgUrl: unitedPositionList[index].productImage,);
                      await fbs.addPurchase2(
                        rootId: unitedPositionList[index].projectRootId,
                        purchasingModel: purchasingModel,).then((value) {

                        if (value == 'TransactionCompletedSuccessfully') {
                          ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                          Get.snackbar(
                            'Внимание!',
                            'Позиция ${unitedPositionList[index].productName} принята на закуп',
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          // Обработка ошибки, если транзакция не удалась
                          ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                          Get.snackbar(
                            'Ошибка!',
                            'Ошибка при выполнении транзакции: $value',
                            duration: const Duration(seconds: 2),
                          );
                        }
                      });
                    }
                    else {

                      Get.snackbar('Ошибка!', 'Вы не можете принять закуп!');
                    }


                  },
                ),
              ],
            ),
          );
        },
        childCount: unitedPositionList.length,
      ),
    ),
  );
}

// Future<void> _resetSelected(BuildContext context,WidgetRef ref) async{
//
//   for(int i = 0; i < ref.watch(allPositionListProvider).length; i++ ){
//
//     if(ref.watch(allPositionListProvider)[i].isSelected!){
//
//       ref.read(allPositionListProvider.notifier).isSelectedChange(i);
//     }
//
//   }
//
// }

