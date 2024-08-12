
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/theme.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  static const String routeName = 'ordersScreen';
  final IntentCurrentUserIdObjectIdProjectRootId arguments;
  const OrdersScreen({super.key, required this.arguments});

  @override
  OrdersScreenState createState() => OrdersScreenState();
}

class OrdersScreenState extends ConsumerState<OrdersScreen> {
  Navigation navigation = Navigation();
  IntentCurrentUserIdObjectIdProjectRootId? objectIdProjectRootId;
  List<OrderDetailsModel> ordesList = [];
  List<OrderDetailsModel> currentOrdesList = [];
  late IntentCurrentUserIdObjectIdProjectRootId ordersArguments;

  late PlaceModel placeData;


  //late StreamSubscription streamSubscription;

  // Переменная для хранения подписки на Stream

  // Future<void> getOrdersByArguments(String currentUserId, String projectRootId, String objectId) async {
  //   OrderFBServices dbs = OrderFBServices();
  //   Stream<QuerySnapshot<Object?>> yourStream = dbs.getOrdersByObjectId3(
  //     arguments: IntentCurrentUserIdObjectIdProjectRootId(
  //       currentUserid: currentUserId,
  //       projectRootId: projectRootId,
  //       placeId: objectId,
  //     ),
  //   );
  //
  //   yourStreamSubscription = yourStream.listen(
  //         (data) {
  //       ref.read(ordersDetailListProvider.notifier)
  //         ..clearOrdersyList()
  //         ..buildOrdersDocNumber(data, ref.watch(subscribersSortProvider).subscribersList);
  //       ordesList = ref.watch(ordersDetailListProvider);
  //       setState(() {});
  //     },
  //   );
  // }




  // Future<void> getOrdersByArguments(String currentUserId, String projectRootId, String objectId) async {
  //   late OrderFBServices dbs = OrderFBServices();
  //   var streamOrders = dbs.getOrdersByObjectId3(
  //   //var streamOrders = dbs.getOrdersByObjectId435(
  //     arguments: IntentCurrentUserIdObjectIdProjectRootId(
  //         currentUserid: currentUserId,
  //         projectRootId: projectRootId,
  //         placeId: objectId),
  //   );
  //   streamSubscription = streamOrders.listen(
  //         (data) {
  //       ref.read(ordersDetailListProvider.notifier)
  //         ..clearOrdersyList()
  //         ..buildOrdersDocNumber(data,ref.watch(subscribersSortProvider).subscribOwnerList);
  //         //..ordersReapWithUser(ref.watch(subscribersSortProvider).subscribOwnerList);
  //       ordesList = ref.watch(ordersDetailListProvider);
  //       setState(() {});
  //     },
  //   );
  // }

  @override
  void initState() {
    objectIdProjectRootId = widget.arguments;

    placeData = objectIdProjectRootId!.place!;


    ordersArguments = IntentCurrentUserIdObjectIdProjectRootId(
        currentUserid: objectIdProjectRootId!.currentUserid!,
        projectRootId: objectIdProjectRootId!.projectRootId,
        placeId: objectIdProjectRootId!.placeId);





    // getOrdersByArguments(
    //     objectIdProjectRootId!.currentUserid!,
    //     objectIdProjectRootId!.projectRootId,
    //     objectIdProjectRootId!.placeId);

    super.initState();
  }

  @override
  void dispose() {
    //streamSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);


    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {

        return ref.watch(ordersByObjectIdProvider3(ordersArguments))
            .when(data: (data){
          num allTotal = 0;
          num currentTotal = 0;
          ref.read(ordersDetailListProvider.notifier)
            ..clearOrdersyList()
            ..buildOrdersDocNumber(data,ref.watch(subscribersSortProvider).subscribOwnerList);
          //..ordersReapWithUser(ref.watch(subscribersSortProvider).subscribOwnerList);
          ordesList = ref.watch(ordersDetailListProvider);
          currentOrdesList = ref.watch(ordersDetailListProvider);
          //currentOrdesList = ref.watch(ordersDetailListProvider).where((order) => order.orderStatus == 2).toList();

          if(currentOrdesList.isNotEmpty){
            allTotal = ref.read(ordersDetailListProvider.notifier).allTotal();
            currentTotal = currentOrdesList.map((e) => e.totalSum).fold(0,(e,v) => e+v);
          }


          return BaseLayout(
            onWillPop: () {return Future.value(true);},
            isAppBar: true,
            isBottomNav: false,
            isFloatingContainer: false,
            appBarTitle: 'Заказы',
            avatarUrl: ref.watch(currentUserProvider).profilePhoto,
            flexibleContainerChild: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                padding: EdgeInsets.zero,
                //shrinkWrap:true,
                children: [
                  RichSpanText(spanText: SnapTextModel(title: 'Всего позиций: ', data: ordesList.length.toString(), postTitle: '')),
                  RichSpanText(spanText: SnapTextModel(title: 'На сумму: ', data: Utils().numberParse(value: allTotal), postTitle: ' UZS')),
                  RichSpanText(spanText: SnapTextModel(title: 'Доставленно: ', data: currentOrdesList.length.toString(), postTitle: '')),
                  RichSpanText(spanText: SnapTextModel(title: 'На сумму: ', data: Utils().numberParse(value: currentTotal), postTitle: ' UZS')),
                ],
              ),
            ),
            flexibleSpaceBarTitle: const SizedBox.shrink(),
            slivers: [
              _contentListView(context: context,
                ordesList: currentOrdesList,
                placeData: placeData,
              onTap: (OrderDetailsModel orderDetails) async{
                await navigation.navigateToOrderPositionsScreen(context, IntentArguments(placeModel: placeData, orderDetailsModel: orderDetails))
                    .then((value) async{
                  if(value != 'orderPositionsScreen'){
                    setState(() {});
                  }
                });
              },
            )],
            isProgress: false,
            isPinned: false,
            radiusCircular: 0.0,
            flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
            expandedHeight: 56.0,);

        },
            error: (_,__) => const Placeholder(),
            loading: () => const ProgressMiniSplash());
      },
    );


    //   WillPopScope(
    //   onWillPop: () {
    //     //ordesList = [];
    //     //ref.read(ordersDetailListProvider.notifier).clearOrdersyList();
    //
    //     Navigator.pop(context);
    //
    //     return Future.value(false);
    //   },
    //   child: Scaffold(
    //     appBar: PreferredSize(preferredSize: const Size.fromHeight(68.0),
    //         child: AppBar(
    //           toolbarHeight: 68.0,
    //           title: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text('Заказы',style: styles.appBarTitleTextStyle,),
    //               //Text(ordesList.first.objectName, style: styles.smalTitleTextStyle,),
    //               Text('Заказов: ${ordesList.length}',style: styles.smalTitleTextStyle,),
    //             ],
    //           ),)),
    //     body: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: ListView.builder(
    //           itemCount: ordesList.length,
    //           itemBuilder: (BuildContext context, int index){
    //             String orderStatus = '';
    //
    //             print(ordesList[index].orderStatus);
    //
    //             Color indicatorChip  = Colors.green;
    //             if(ordesList[index].orderStatus == 0){
    //               orderStatus = 'Заказ принят на закуп';
    //             }else if(ordesList[index].orderStatus == 1){
    //               orderStatus = 'Заказ отгружается';
    //             }else if(ordesList[index].orderStatus == 2){
    //               orderStatus = 'Заказ зактыт';
    //             }
    //
    //             return Container(
    //               margin: const EdgeInsets.only(bottom: 5.0),
    //               decoration: BoxDecoration(
    //                   border: Border.all(color: Colors.grey),
    //                   borderRadius: const BorderRadius.all(Radius.circular(10.0))
    //               ),
    //               child: ListTile(
    //                 title: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Row(
    //                       children: [
    //                         ClipRRect(
    //                           borderRadius:
    //                           const BorderRadius.all(
    //                               Radius.circular(60.0)),
    //                           child: CachedNetworkImg(
    //                               imageUrl: ordesList[index].userModel!.profilePhoto,
    //                               width: 38,
    //                               height: 38,
    //                               fit: BoxFit.cover),
    //                         ),
    //                         const SizedBox(
    //                           width: 16.0,
    //                         ),
    //                         Expanded(
    //                           child: Text(ordesList[index].userModel!.name,
    //                             style: styles.cartItemTitleStyle,
    //                             softWrap: true,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //
    //                     RichSpanText(spanText: SnapTextModel(title: 'Накладная № ', data: ordesList[index].invoice.toString(), postTitle: '')),
    //                     RichSpanText(spanText: SnapTextModel(title: 'Сумма заказа: ', data: Utils().numberParse(value: ordesList[index].totalSum), postTitle: ' UZS')),
    //                     RichSpanText(spanText: SnapTextModel(title: 'Кешбэк: ', data: ordesList[index].cashback.toString(), postTitle: ' %')),
    //                     RichSpanText(spanText: SnapTextModel(title: 'Всего позиций: ', data: ordesList[index].positionListLength.toString(), postTitle: '')),
    //                     RichSpanText(spanText: SnapTextModel(title: 'Дата заказа: ', data: Utils().dateParse(milliseconds: ordesList[index].addedAt), postTitle: '')),
    //
    //                     Container(
    //                       padding: const EdgeInsets.symmetric(vertical: 3.0),
    //                       width: double.infinity,
    //                       decoration: BoxDecoration(
    //                           border: Border.all(),
    //                           borderRadius: const BorderRadius.all(Radius.circular(50.0))
    //                       ),
    //                       child: Center(
    //                         child: Text(orderStatus, style: TextStyle(color: indicatorChip),),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 onTap: ()=> Navigation().navigateToOrderPositionsScreen(context, ordesList[index],),
    //               ),
    //             );
    //           }),
    //     ),
    //   ),
    // );
  }
}



Widget _contentListView({
  required BuildContext context,
  required List<OrderDetailsModel> ordesList,
  required PlaceModel placeData,
  required Function onTap,
}){

  AppStyles styles = AppStyles.appStyle(context);

  return SliverPadding(
    padding: const EdgeInsets.all(6.0),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: ordesList.length,
            (BuildContext context, int index) {

          String orderStatus = '';
          String invoiceName = '${ordesList[index].invoice}/${Utils().monthParse(milliseconds: ordesList[index].addedAt)}';

          Color indicatorChip = Theme.of(context).primaryColor;
          if (ordesList[index].orderStatus == 0) {
            orderStatus = 'Заказ успешно отправлен';
          } else if (ordesList[index].orderStatus == 1) {
            orderStatus = 'Заказ в обработке';
          } else if (ordesList[index].orderStatus == 2) {
            orderStatus = 'Заказ принят на доставку';
          } else if (ordesList[index].orderStatus == 3) {
            orderStatus = 'Заказ доставлен';
          } else if (ordesList[index].orderStatus == 4) {
            orderStatus = 'Имеются отмененные позиции';
          } else if (ordesList[index].orderStatus == 5) {
            orderStatus = 'Заказ зактыт';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 6.0),
            decoration: styles.positionBoxDecoration,
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                        const BorderRadius.all(
                            Radius.circular(60.0)),
                        child: CachedNetworkImg(
                            imageUrl: ordesList[index].userModel!.subjectImg!,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      Expanded(
                        child: Text(ordesList[index].userModel!.name,
                          style: styles.cartItemTitleStyle,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  RichSpanText(spanText: SnapTextModel(title: 'Накладная № ', data: invoiceName, postTitle: '')),
                  RichSpanText(spanText: SnapTextModel(title: 'Всего позиций: ', data: '${ordesList[index].positionListLength}', postTitle: '')),
                  RichSpanText(spanText: SnapTextModel(title: 'Сумма заказа: ', data: Utils().numberParse(value: ordesList[index].totalSum), postTitle: ' UZS')),
                  RichSpanText(spanText: SnapTextModel(title: 'Оплаченно: ', data: Utils().numberParse(value: ordesList[index].debtRepayment), postTitle: ' UZS')),
                  RichSpanText(spanText: SnapTextModel(title: 'Кешбэк: ', data: ordesList[index].cashback.toString(), postTitle: ' %')),
                  RichSpanText(spanText: SnapTextModel(title: 'Дата заказа: ', data: Utils().dateParse(milliseconds: ordesList[index].addedAt), postTitle: '')),
                  //RichSpanText(spanText: SnapTextModel(title: 'Статус: ', data: ordesList[index].orderStatus.toString(), postTitle: '')),
                  const SizedBox(height: 8.0,),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(50.0))),
                    child: Center(
                      child: Text(
                        orderStatus,
                        style: TextStyle(color: indicatorChip),
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => onTap(ordesList[index]),
            ),
          );
        },
      ),
    ),
  );
}
