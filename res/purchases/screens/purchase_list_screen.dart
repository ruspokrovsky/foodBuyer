import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/purchases/purchase_providers/purchase_providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/chip_btn.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/search_widget.dart';
import 'package:ya_bazaar/theme.dart';

class PurchaseListScreen extends ConsumerStatefulWidget {
  static const String routeName = 'purchaseListScreen';

  const PurchaseListScreen({super.key});

  @override
  PurchaseListScreenState createState() => PurchaseListScreenState();
}

class PurchaseListScreenState extends ConsumerState<PurchaseListScreen> {
  List<PurchasingModel> purchasingList = [];
  List<PurchasingModel> purchasingDataList = [];
  String query = '';

  int tabControllerIndex = 0;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      UserModel currentUser = ref.watch(currentUserProvider);
      double total = 0.0;
      num totalForPurchasing = 0;
      List<num> amountsList = [];
      //List<PurchasingModel> purchasingDataList = [];
      String pageTitle = '';
      int selectedInd = 0;




      var streamPurchases = ref.watch(getAllPurchasesProvider2(currentUser.rootId!));
      return streamPurchases.when(
          data: (data) {
            ref.read(allPurchasesListProvider.notifier)
              ..clearPurchasingList()
              ..buildPurchasing(data,);

            if (ref.watch(allPurchasesListProvider).isNotEmpty) {

              if(ref.watch(currentUserProvider).userRoles!.contains('admin')){

                purchasingList = ref.watch(allPurchasesListProvider);

              }
              else {

                purchasingList = ref.watch(allPurchasesListProvider)
                    .where((element) => element.buyerId == currentUser.uId)
                    .toList();

              }


              if (_selectedIndex == 0) {
                //закуплено
                purchasingDataList = purchasingList
                    .where((element) => element.purchasingStatus == 1)
                    .toList();
                pageTitle = 'Позиции на закуп';
                for (var element in purchasingDataList) {
                  num amounts = (element.firsPrice * element.orderQty);
                  amountsList.add(amounts);
                }
              }
              else if (_selectedIndex == 1) {
                //принято на склад
                purchasingDataList = purchasingList
                    .where((element) => element.purchasingStatus == 2 || element.purchasingStatus == 22)
                    .toList();
                pageTitle = 'Закуплено';
                for (var element in purchasingDataList) {
                  num amounts = (element.actualPrice * element.actualQty);
                  amountsList.add(amounts);
                }
              }
              else if (_selectedIndex == 2) {
                //принято на склад
                purchasingDataList = purchasingList
                    .where((element) => element.purchasingStatus == 3)
                    .toList();
                pageTitle = 'Принято на склад';
                for (var element in purchasingDataList) {
                  num amounts =
                      (element.actualPrice * element.receivedQuantity!);
                  amountsList.add(amounts);
                }
              }
              //создаем список amounts позиций для вывода total

              if (amountsList.isNotEmpty) {
                total = amountsList.reduce((v, e) => v + e).toDouble();
              }
            }

            if (query.isNotEmpty) {
              purchasingDataList = purchasingDataList.where((book) {
                final titleLower = book.productName.toLowerCase();
                final searchLower = query.toLowerCase();
                return titleLower.contains(searchLower);
              }).toList();
            }

            List<PurchasingModel> purchasingForReportList = purchasingDataList
                .where((element) => element.purchasingStatus != 22).toList();
            List<num> totalForPurchasingList = purchasingForReportList.map((e) {
              e.amount = (e.actualPrice * e.actualQty);
              return e.amount!;}).toList();

            if(totalForPurchasingList.isNotEmpty){
              totalForPurchasing = totalForPurchasingList.fold(0,(v, e) => v + e);
            }
            currentUser.currentPurchaseAmount = totalForPurchasing;
            currentUser.purchasingIdList = purchasingDataList.map((e) => e.docId).toList();

            return BaseLayout(
              onWillPop: () {
                ref.read(navigationAwaitProvider.notifier).state ='';
                Navigator.pop(context);
                return Future.value(false);},
              isAppBar: true,
              isBottomNav: true,
              isFloatingContainer: false,
              appBarTitle: pageTitle,
              appBarSubTitle: 'Снабжение',
              avatarUrl: currentUser.profilePhoto,
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
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'Всего позиций: ',
                                    data: purchasingDataList.length.toString(),
                                    postTitle: '')),
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'На сумму: ',
                                    data: Utils().numberParse(value: total),
                                    postTitle: ' UZS')),
                          ],
                        ),

                        ChipButton(
                            lable: 'Распечатать',
                            onTap: () async {
                              String fileName =
                                  'Закуп от ${Utils().dateParse(milliseconds: DateTime.now().millisecondsSinceEpoch)}';

                              await Utils()
                                  .saveExcelPurchasingFile(
                                  fileName: fileName,
                                  data: purchasingDataList)
                                  .then((String filePath) async {
                                await OpenFile.open(filePath);
                              });
                            },
                        avatar: const Icon(Icons.print, color: Colors.white,),),
                        // SingleButton(
                        //   title: 'Распечатать',
                        //   onPressed: () async {
                        //     String fileName =
                        //         'Закуп от ${Utils().dateParse(milliseconds: DateTime.now().millisecondsSinceEpoch)}';
                        //
                        //     await Utils()
                        //         .saveExcelPurchasingFile(
                        //             fileName: fileName,
                        //             data: purchasingDataList)
                        //         .then((String filePath) async {
                        //       await OpenFile.open(filePath);
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    buildSearch(
                        categoryPressed: () {},
                        onTapJoinPosition: () {},
                        onTapCart: () {}),
                  ],
                ),
              ),
              flexibleSpaceBarTitle: const SizedBox.shrink(),
              slivers: [
                _contentListView(
                    context: context,
                    ref: ref,
                    currentUser: currentUser,
                    purchasingDataList: purchasingDataList,)
              ],
              isProgress: ref.watch(progressBoolProvider),
              isPinned: false,
              radiusCircular: 0.0,
              flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
              expandedHeight: 126.0,
              bottomNavigationBarItems: _bottomNavItems(context: context),
              bottomBarSelectedIndex: _selectedIndex,
              bottomBarTap: (int index) {
                //selectedInd = index;
                print(index);

                _onItemTapped(index);
              },
            );
          },
          error: (_, __) => const Placeholder(),
          loading: () => const ProgressMiniSplash());
    });

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
    final books = purchasingDataList.where((book) {
      final titleLower = book.productName.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    if (query.isNotEmpty) {
      purchasingDataList = books;
    } else {
      setState(() {
        purchasingDataList = [];
        //getAllPosition();
      });
    }
    setState(() {
      this.query = query;
    });
  }
}

List<SnapTextModel> richTextList = [];

Widget _contentListView({
  required BuildContext context,
  required WidgetRef ref,
  required UserModel currentUser,
  required List<PurchasingModel> purchasingDataList,
}) {
  Utils utils = Utils();
  AppStyles styles = AppStyles.appStyle(context);
  Navigation navigation = Navigation();

  return SliverPadding(
    padding: const EdgeInsets.all(5.0),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          String buyerName = purchasingDataList[index].buyerName;
          String productName = purchasingDataList[index].productName;
          String productMeasure = purchasingDataList[index].productMeasure;
          num orderQty = purchasingDataList[index].orderQty;
          num receivedQuantity = purchasingDataList[index].receivedQuantity!;
          num actualQty = purchasingDataList[index].actualQty;
          num firsPrice = purchasingDataList[index].firsPrice;
          num actualPrice = purchasingDataList[index].actualPrice;
          int purchasingStatus = purchasingDataList[index].purchasingStatus;
          int selectedTime = purchasingDataList[index].selectedTime;
          int receivedDate = purchasingDataList[index].receivedDate!;
          String purchasePrice = '';
          String qtyTitle = '';
          String quantity = '';
          String amountTitle = '';
          String amount = '';
          String dateTime = '';
          String strPurchasingStatus = '';
          String purchasePriceTitle = '';


          if (purchasingStatus == 1) {
            strPurchasingStatus = 'Позиция принята на закуп';
            qtyTitle = 'Закупить: ';
            quantity = utils.numberParse(value: orderQty).toString();
            purchasePriceTitle = 'Закупочная цена: ~ ';
            amountTitle = 'Сумма: ~ ';
            purchasePrice = utils.numberParse(value: firsPrice);
            amount = utils.numberParse(value: (firsPrice * orderQty));
            dateTime = utils.dateTimeParse(milliseconds: selectedTime);
          } else if (purchasingStatus == 2) {
            strPurchasingStatus = 'Позиция закуплена (НЕТ ОТЧЕТА)';
            qtyTitle = 'Закуплено: ';
            quantity = utils.numberParse(value: actualQty).toString();
            purchasePriceTitle = 'Закупочная цена: ';
            amountTitle = 'Сумма: ';
            purchasePrice = utils.numberParse(value: actualPrice);
            amount = utils.numberParse(value: (actualQty * actualPrice));
            dateTime = utils.dateTimeParse(milliseconds: selectedTime);
          } else if (purchasingStatus == 22) {
            strPurchasingStatus = 'Позиция закуплена (ЕСТЬ ОТЧЕТ)';
            qtyTitle = 'Закуплено: ';
            quantity = utils.numberParse(value: actualQty).toString();
            purchasePriceTitle = 'Закупочная цена: ';
            amountTitle = 'Сумма: ';
            purchasePrice = utils.numberParse(value: actualPrice);
            amount = utils.numberParse(value: (actualQty * actualPrice));
            dateTime = utils.dateTimeParse(milliseconds: selectedTime);
          } else if (purchasingStatus == 3) {
            strPurchasingStatus = 'Позиция принята на склад';
            qtyTitle = 'Принято: ';
            quantity = utils.numberParse(value: receivedQuantity).toString();
            purchasePriceTitle = 'Закупочная цена: ';
            amountTitle = 'Сумма: ';
            purchasePrice = utils.numberParse(value: actualPrice);
            amount = utils.numberParse(value: (receivedQuantity * actualPrice));
            dateTime = utils.dateTimeParse(milliseconds: receivedDate);
          }

          return Container(
            margin: const EdgeInsets.only(
              bottom: 5.0,
            ),
            decoration: styles.positionBoxDecoration,
            child: ListTile(
                titleTextStyle: Theme.of(context).textTheme.bodyMedium,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Divider(),
                    if (purchasingStatus < 2)
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Закупить: ',
                              data: utils.numberParse(value: orderQty),
                              postTitle: ' /$productMeasure')),
                    if (purchasingStatus > 1)
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: qtyTitle,
                              data: quantity,
                              postTitle: ' / $productMeasure')),
                    RichSpanText(
                        spanText: SnapTextModel(
                            title: purchasePriceTitle,
                            data: purchasePrice,
                            postTitle: ' /UZS')),
                    RichSpanText(
                        spanText: SnapTextModel(
                            title: amountTitle,
                            data: amount,
                            postTitle: ' /UZS')),
                    RichSpanText(
                        spanText: SnapTextModel(
                            title: 'Позиция принята: ',
                            data: dateTime,
                            postTitle: '')),
                    RichSpanText(
                        spanText: SnapTextModel(
                            title: 'Закупщик: ',
                            data: buyerName,
                            postTitle: '')),
                    RichSpanText(
                        spanText: SnapTextModel(
                            title: 'Статус: ',
                            data: strPurchasingStatus,
                            postTitle: '')),
                  ],
                ),
                onTap: () async {
                  if (purchasingStatus < 2) {

                    if(currentUser.userRoles!.contains('buyer')){
                      navigation.navigateToActualPurchaseScreen(
                          context, purchasingDataList[index]);
                    }
                    else {
                      Get.snackbar('У Вас нет доступа','У Вас нет доступа');
                    }

                  }
                  else if (purchasingStatus == 2) {

                    if(currentUser.userRoles!.contains('buyer')){
                      navigation.navigationToCreateExpensesScreen(context, currentUser);
                    }
                    else {
                      Get.snackbar('У Вас нет доступа','У Вас нет доступа');
                    }
                  }
                  else if (purchasingStatus == 22){
                    if(currentUser.userRoles!.contains('warehouseManager')){
                      navigation.navigationToAcceptancePurchasesScreen(context, purchasingDataList[index]);
                    }
                    else {
                      Get.snackbar('У Вас нет доступа','У Вас нет доступа');
                    }
                  }
                }),
          );
        },
        childCount: purchasingDataList.length,
      ),
    ),
  );
}

List<BottomNavigationBarItem> _bottomNavItems({
  required BuildContext context,
}) {
  return <BottomNavigationBarItem>[
    BottomNavigationBarItem(
        activeIcon: Icon(
          Icons.timer_sharp,
          color: Theme.of(context).primaryColor,
        ),
        icon: const Icon(
          Icons.timer_sharp,
          color: Colors.grey,
        ),
        label: 'Принято'),
    BottomNavigationBarItem(
        activeIcon: Icon(
          Icons.done,
          color: Theme.of(context).primaryColor,
        ),
        icon: const Icon(
          Icons.done,
          color: Colors.grey,
        ),
        label: 'Закуплено'),
    BottomNavigationBarItem(
        activeIcon: Icon(
          Icons.done_all,
          color: Theme.of(context).primaryColor,
        ),
        icon: const Icon(
          Icons.done_all,
          color: Colors.grey,
        ),
        label: 'Приход'),
  ];
}
