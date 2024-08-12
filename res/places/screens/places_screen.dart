
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ya_bazaar/assistants/assistant_methods.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_controllers/multiple_cart_list_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/order_controller.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/map/map_providers/map_providers.dart';
import 'package:ya_bazaar/res/models/direction_details_info.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/places/place_controllers/place_controller.dart';
import 'package:ya_bazaar/res/places/place_controllers/places_controller.dart';
import 'package:ya_bazaar/res/places/place_providers/place_providers.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  static const String routeName = "placesScreen";


  final IntentArguments arguments;

  const PlacesScreen({super.key, required this.arguments});

  @override
  ObjectsScreenState createState() => ObjectsScreenState();
}

class ObjectsScreenState extends ConsumerState<PlacesScreen> {

  Navigation navigation = Navigation();
  String? fromWhichScreen;
  String? currentRootId;


@override
  void initState() {
  fromWhichScreen = widget.arguments.fromWhichScreen;
  currentRootId = widget.arguments.currentRootId;

    super.initState();
  }

  // Future<void>  _createContent23232() async {
  //
  //   PlaceFBServices fbs = PlaceFBServices();
  //
  //   await fbs.fetchPlace(userId: ref.read(currentUserProvider).uId)
  //       .then((QuerySnapshot value) async {
  //     ref.read(placesListProvider.notifier)
  //       ..clearPlacesList()
  //       ..buildPlacesList(value,);
  //     setState(() {});
  //   });
  //
  // }




  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {

        UserModel userData = ref.watch(currentUserProvider);

        List<PlaceModel> placeModelList = [];
        final PlacesListController placesListController = ref.read(placesListProvider.notifier);
        final MultipleCartListController multipleCartListController = ref.read(multipleCartListProvider.notifier);

        final OrderController orderListController = ref.read(orderListProvider.notifier);
        final PlaceController currentPlaceController = ref.read(currentPlaceProvider.notifier);



        return ref.watch(getPlaceByUserIdProvider(ref.watch(currentUserProvider).uId))
            .when(
            data: (placesData) {
              placesListController
                ..clearPlacesList()
                ..buildPlacesList(placesData);

              placeModelList = ref.watch(placesListProvider);

              return BaseLayout(
                  onWillPop: (){return Future.value(true);},
                  isAppBar: true,
                  appBarTitle: ref.watch(currentUserProvider).name,
                  avatarUrl: ref.watch(currentUserProvider).profilePhoto,
                  avatarTap: (){
                    navigation.navigationToCreateAccountScreen(context, ref.watch(currentUserProvider));
                  },
                actions: [
                  PopupMenuButton<int>(
                      onSelected: (int itemIndex) {
                        if (itemIndex == 0) {
                          UserModel userData = ref.watch(currentUserProvider);
                          userData.fromWhichScreen = 'placesScreen';
                          Navigation().navigationToQrScanerScreen(context, userData).then((value)
                          => setState(() {}));
                        }
                      },
                      itemBuilder: (BuildContext context) => [

                        const PopupMenuItem(
                            value: 0,
                            child: Text(
                              'Подписаться на поставщика',
                            ))
                      ]),
                ],
                  isBottomNav: false,
                  isFloatingContainer: false,
                  flexibleContainerChild: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      //shrinkWrap:true,
                      children: [
                        RichSpanText(spanText: SnapTextModel(title: 'Всего адресов: ', data: placeModelList.length.toString(), postTitle: '')),
                        SingleButton(title: 'Добавить адрес', onPressed: (){
                          navigation.navigateToCreatePlaceScreen(context, IntentArguments(
                            userModel: ref.watch(currentUserProvider),
                            fromWhichScreen: 'placesScreen',
                          ));
                        })
                      ],
                    ),
                  ),
                  flexibleSpaceBarTitle: const SizedBox.shrink(),
                  slivers: [
                    placeModelList.isNotEmpty
                        ?_contentListView(
                      context: context,
                      placeModelList: placeModelList,
                      onTapMap: (List<dynamic> location){
                        LatLng latLng = LatLng(
                            location[0],
                            location[1]);

                        //ref.read(centerPositionProvider.notifier).state = latLng;
                        //ref.read(addCircleProvider.notifier).circlesSet(context,latLng);

                        AssistantMethods.obtainOriginToDestinationDirectionDetails(
                            latLng, ref.watch(centerPositionProvider)).then((DirectionDetailsInfo? directionDetailsInfo) {


                          print('ePoints------${directionDetailsInfo!.ePoints}');
                          print('distanceText-------${directionDetailsInfo.distanceText}');
                          print('distanceValue-----${directionDetailsInfo.distanceValue}');
                          print('durationText-------${directionDetailsInfo.durationText}');
                          print('durationValue-------${directionDetailsInfo.durationValue}');


                          // Время путешествия Сумма тарифа в минуту
                          double timeTraveledFareAmountPerMinute = (directionDetailsInfo.durationValue! / 60) * 0.1;
                          print('timeTraveledFareAmountPerMinute-----$timeTraveledFareAmountPerMinute');

                          // Сумма пройденного расстояния в километрах
                          double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distanceValue! / 1000) * 12;
                          print('distanceTraveledFareAmountPerKilometer-----$distanceTraveledFareAmountPerKilometer');

                          String totalFareAmount = (timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer).toStringAsFixed(1);
                          print('totalFareAmount-----$totalFareAmount');


                          navigation.navigateToMapScreen(context:context, args: {
                            'objecLatLng':latLng,
                            'distanceText':directionDetailsInfo.distanceText,
                            'durationText':directionDetailsInfo.durationText,
                            'totalKGS':totalFareAmount,
                          });
                        });
                      },
                      onTapCreateOrder: (PlaceModel place) async {

                        //фиксируем выбранный объект для сравнения с объектом в корзине при добавлении позиции
                        ref.read(currentPlaceProvider.notifier).createPlace(place);

                        await multipleCartListController.setCustomer(MultipleCartModel(
                          projectRootId: currentRootId!,
                          projectRootName: '',
                          currentCartList: [],
                          customerId: place.docId!,
                          customerName: place.placeName,))
                            .then((value) {

                          if(fromWhichScreen == 'cartScreen' ){
                            Navigator.pop(context, place);
                          }

                          else {
                            Navigation().navigateToSearchScreen(context,
                                IntentRootPlaceArgs(
                                rootUserModel: UserModel.empty(),
                          placeModel: place,
                          fromWhichScreen: 'placesScreen'));
                          }

                        });

                        // if(fromWhichScreen == 'cartScreen' ){
                        //   //когда у ползователя еще нет адреса доставки, но в корзине есть товар,
                        //   //при намерении заказать отправляем на страницу адресов
                        //   //после выбора адреса доставки обновляем поля objectId и objectName в позициях корзины
                        //   //и возвращаемся в корзину
                        //   await multipleCartListController.setCustomer(MultipleCartModel(
                        //     projectRootId: currentRootId!,
                        //     projectRootName: '',
                        //     currentCartList: [],
                        //     customerId: place.docId!,
                        //     customerName: place.placeName,))
                        //       .then((value) => Navigator.pop(context, place));
                        // }
                        // else{
                        //   Navigation().navigateToSearchScreen(context,
                        //     IntentRootPlaceArgs(
                        //         rootUserModel: UserModel.empty(),
                        //         placeModel: place,
                        //         fromWhichScreen: 'placesScreen'),
                        //   );
                        // }
                      },
                      onTapToOrders: (PlaceModel place){
                        navigation.navigateToOrdersScreen(
                            context, IntentCurrentUserIdObjectIdProjectRootId(
                            currentUserid: ref.watch(currentUserProvider).uId,
                            projectRootId: ref.watch(currentUserProvider).uId,
                            place: place,
                            placeId: place.docId!));
                      },
                      onTapItems: (){},
                      ref: ref,
                      fromWhichScreen: fromWhichScreen!,
                    currentRootId: currentRootId!,)
                  :
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 100.0),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Text('Здесь будет отображаться история событий',textAlign: TextAlign.center, style: styles.worningTextStyle,),
                      ),
                    ),
                  )],
                isProgress: ref.watch(progressBoolProvider),
                isMiniPrgress: false,
                radiusCircular: 0.0,
                flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
                expandedHeight: 80.0,
                isPinned: false,);
            },
            error: (_, __) => const Placeholder(),
            loading: () => const ProgressMiniSplash());


      },
    );

    //   Scaffold(
    //   appBar: AppBar(
    //     title: Row(
    //       children: [
    //         ClipRRect(
    //           borderRadius: const BorderRadius.all(Radius.circular(50.0)),
    //           child: CachedNetworkImg(
    //               imageUrl: ref.watch(currentUserProvider).profilePhoto,
    //               width: 50, height: 50, fit: BoxFit.cover),
    //         ),
    //         const SizedBox(width: 16.0,),
    //         Expanded(child: Text(ref.watch(currentUserProvider).name,
    //           style: styles.appBarTitleTextStyle,)),
    //       ],
    //     ),
    //     actions: [
    //       _popUpMenuBtn(context, navigation, ref),
    //     ],
    //   ),
    //   body: _getObjectsList(),
    //
    // );
  }


  // Widget _getObjectsList() {
  //   return Consumer(
  //     builder: (BuildContext context, WidgetRef ref, Widget? child) {
  //       List<PlaceModel> placeModelList = [];
  //       final PlacesListController placesListController = ref.read(placesListProvider.notifier);
  //
  //       final OrderController orderListController = ref.read(orderListProvider.notifier);
  //       final PlaceController currentPlaceController = ref.read(currentPlaceProvider.notifier);
  //
  //
  //       print('**PlacesScreen/_getObjectsList/currentUserId:${ref.watch(currentUserProvider).uId}');
  //       print('**PlacesScreen/_getObjectsList/currentUserId:${ref.watch(currentUserProvider).uId}');
  //
  //
  //       ref.watch(getPlaceByUserIdProvider(ref.watch(currentUserProvider).uId))
  //           .when(
  //           data: (placesData) {
  //             placesListController
  //               ..clearPlacesList()
  //               ..buildPlacesList(placesData);
  //
  //             placeModelList = ref.watch(placesListProvider);
  //           },
  //           error: (_, __) => const Placeholder(),
  //           loading: () => const ProgressMini());
  //
  //       return ListView.builder(
  //           itemCount: placeModelList.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             return Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Container(
  //                 padding: const EdgeInsets.all(8.0),
  //                 margin: const EdgeInsets.only(bottom: 5.0),
  //                 decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.grey),
  //                     borderRadius:
  //                         const BorderRadius.all(Radius.circular(10.0))),
  //                 child: Column(
  //                   children: [
  //                     SizedBox(
  //                       height: 100.0,
  //                       child: Row(
  //                         children: [
  //                           Flexible(
  //                             child: ClipRRect(
  //                               borderRadius:
  //                                   const BorderRadius.all(Radius.circular(10.0)),
  //                               child: CachedNetworkImg(
  //                                   imageUrl: placeModelList[index].placeImage,
  //                                   width: double.infinity,
  //                                   height: double.infinity,
  //                                   fit: BoxFit.cover),
  //                             ),
  //                           ),
  //                           Flexible(
  //                             child: ClipRRect(
  //                               borderRadius:
  //                                   const BorderRadius.all(Radius.circular(10.0)),
  //                               child: GestureDetector(
  //                                 onTap: () {
  //
  //                                   LatLng latLng = LatLng(
  //                                       placeModelList[index].locationLatLng[0],
  //                                       placeModelList[index].locationLatLng[1]);
  //
  //                                   //ref.read(centerPositionProvider.notifier).state = latLng;
  //                                   //ref.read(addCircleProvider.notifier).circlesSet(context,latLng);
  //
  //                                   AssistantMethods.obtainOriginToDestinationDirectionDetails(
  //                                       latLng, ref.watch(centerPositionProvider)).then((DirectionDetailsInfo? directionDetailsInfo) {
  //
  //
  //                                         print('ePoints------${directionDetailsInfo!.ePoints}');
  //                                         print('distanceText-------${directionDetailsInfo.distanceText}');
  //                                         print('distanceValue-----${directionDetailsInfo.distanceValue}');
  //                                         print('durationText-------${directionDetailsInfo.durationText}');
  //                                         print('durationValue-------${directionDetailsInfo.durationValue}');
  //
  //
  //                                         // Время путешествия Сумма тарифа в минуту
  //                                         double timeTraveledFareAmountPerMinute = (directionDetailsInfo.durationValue! / 60) * 0.1;
  //                                         print('timeTraveledFareAmountPerMinute-----$timeTraveledFareAmountPerMinute');
  //
  //                                         // Сумма пройденного расстояния в километрах
  //                                         double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distanceValue! / 1000) * 12;
  //                                         print('distanceTraveledFareAmountPerKilometer-----$distanceTraveledFareAmountPerKilometer');
  //
  //                                         String totalFareAmount = (timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer).toStringAsFixed(1);
  //                                         print('totalFareAmount-----$totalFareAmount');
  //
  //
  //                                         navigation.navigateToMapScreen(context:context, args: {
  //                                       'objecLatLng':latLng,
  //                                       'distanceText':directionDetailsInfo.distanceText,
  //                                       'durationText':directionDetailsInfo.durationText,
  //                                       'totalKGS':totalFareAmount,
  //
  //                                     });
  //
  //
  //                                   });
  //
  //
  //                                 },
  //                                 child: CachedNetworkImg(
  //                                     imageUrl:
  //                                         placeModelList[index].locationImage,
  //                                     width: double.infinity,
  //                                     height: double.infinity,
  //                                     fit: BoxFit.cover),
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                     ListTile(
  //                       contentPadding: EdgeInsets.zero,
  //                       title: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           RichText(
  //                             text: TextSpan(
  //                               text: 'Адрес: ',
  //                               style: DefaultTextStyle.of(context).style,
  //                               children: <TextSpan>[
  //                                 TextSpan(
  //                                     text: placeModelList[index].placeName,
  //                                     style: const TextStyle(
  //                                         color: Colors.redAccent,
  //                                         fontWeight: FontWeight.bold)),
  //                               ],
  //                             ),
  //                           ),
  //                           RichText(
  //                             text: TextSpan(
  //                               text: 'Создан: ',
  //                               style: DefaultTextStyle.of(context).style,
  //                               children: <TextSpan>[
  //                                 TextSpan(
  //                                     text: Utils().dateParse(
  //                                         milliseconds:
  //                                         placeModelList[index].addedAt),
  //                                     style: const TextStyle(
  //                                         color: Colors.redAccent,
  //                                         fontWeight: FontWeight.bold)),
  //                               ],
  //                             ),
  //                           ),
  //                           RichText(
  //                             text: TextSpan(
  //                               text: 'Статус: ',
  //                               style: DefaultTextStyle.of(context).style,
  //                               children: <TextSpan>[
  //                                 TextSpan(
  //                                     text: placeModelList[index]
  //                                         .successStatus
  //                                         .toString(),
  //                                     style: const TextStyle(
  //                                         color: Colors.redAccent,
  //                                         fontWeight: FontWeight.bold)),
  //                               ],
  //                             ),
  //                           ),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                             children: [
  //                               GestureDetector(
  //                                 onTap: () async {
  //                                   //фиксируем выбранный объект для сравнения с объектом в корзине при добавлении позиции
  //                                   ref.read(currentPlaceProvider.notifier).createPlace(placeModelList[index]);
  //
  //                                   if(fromWhichScreen == 'cartScreen' ){
  //                                     //когда у ползователя еще нет адреса доставки, но в корзине есть товар,
  //                                     //при намерении заказать отправляем на страницу адресов
  //                                     //после выбора адреса доставки обновляем поля objectId и objectName в позициях корзины
  //                                     //и возвращаемся в корзину
  //                                     await multipleCartListController.setCustomer(MultipleCartModel(
  //                                       projectRootId: currentRootId!,
  //                                       projectRootName: '',
  //                                       currentCartList: [],
  //                                       customerId: placeModelList[index].docId!,
  //                                       customerName: placeModelList[index].placeName,))
  //                                         .then((value) => Navigator.pop(context, placeModelList[index]));
  //
  //
  //
  //                                   }
  //                                   else{
  //                                     navigation.navigateToSearchScreen(context,
  //                                       IntentRootPlaceArgs(
  //                                           rootUserModel: UserModel.empty(),
  //                                           placeModel: placeModelList[index],
  //                                           fromWhichScreen: 'placesScreen'),
  //                                     );
  //                                   }
  //
  //                                 } ,
  //                                 child: const Chip(
  //                                   label: Text(
  //                                     'Оформить заказ',
  //                                     style: TextStyle(color: Colors.grey),
  //                                   ),
  //                                   shape: StadiumBorder(
  //                                       side: BorderSide(color: Colors.grey)),
  //                                   backgroundColor: Colors.transparent,
  //                                 ),
  //                               ),
  //
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   navigation.navigateToOrdersScreen(
  //                                       context, IntentCurrentUserIdObjectIdProjectRootId(
  //                                       currentUserid: ref.watch(currentUserProvider).uId,
  //                                       projectRootId: ref.watch(currentUserProvider).uId,
  //                                       placeId: placeModelList[index].docId!));
  //                                 },
  //                                 child: const Chip(
  //                                   label: Text(
  //                                     'Перейти к заказам',
  //                                     style: TextStyle(color: Colors.grey),
  //                                   ),
  //                                   shape: StadiumBorder(
  //                                       side: BorderSide(color: Colors.grey)),
  //                                   backgroundColor: Colors.transparent,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       onTap: () {
  //                         navigation.navigateToOrdersScreen(
  //                             context, IntentCurrentUserIdObjectIdProjectRootId(
  //                             projectRootId: ref.watch(currentUserProvider).uId,
  //                             placeId: placeModelList[index].docId!));
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           });
  //     },
  //   );
  // }
}



Widget _contentListView({
  required BuildContext context,
  required WidgetRef ref,
  required List<PlaceModel> placeModelList,
  required String currentRootId,
  required String fromWhichScreen,
  required Function onTapMap,
  required Function onTapCreateOrder,
  required Function onTapToOrders,
  required VoidCallback onTapItems,
}){
  AppStyles styles = AppStyles.appStyle(context);
  return SliverPadding(
    padding: const EdgeInsets.all(5.0),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: placeModelList.length,
            (BuildContext context, int index) {

          String addressDescription;
          String placeName;
          if(placeModelList[index].placeName.length > 30){
            placeName = placeModelList[index].placeName.substring(0,30);
          }
          else {
            placeName = placeModelList[index].placeName;
          }

          if(placeModelList[index].addressDescription.length > 30){
            addressDescription = placeModelList[index].addressDescription.substring(0,30);
          }
          else {
            addressDescription = placeModelList[index].addressDescription;
          }

          return Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.only(bottom: 5.0),
            decoration: styles.positionBoxDecoration,
            child: Column(
              children: [
                SizedBox(
                  height: 100.0,
                  child: Row(
                    children: [
                      Flexible(
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                          child: CachedNetworkImg(
                              imageUrl: placeModelList[index].placeImage,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover),
                        ),
                      ),
                      Flexible(
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                          child: GestureDetector(
                            onTap: () {

                              LatLng latLng = LatLng(
                                  placeModelList[index].locationLatLng[0],
                                  placeModelList[index].locationLatLng[1]);

                              //ref.read(centerPositionProvider.notifier).state = latLng;
                              //ref.read(addCircleProvider.notifier).circlesSet(context,latLng);

                              AssistantMethods.obtainOriginToDestinationDirectionDetails(
                                  latLng, ref.watch(centerPositionProvider)).then((DirectionDetailsInfo? directionDetailsInfo) {


                                print('ePoints------${directionDetailsInfo!.ePoints}');
                                print('distanceText-------${directionDetailsInfo.distanceText}');
                                print('distanceValue-----${directionDetailsInfo.distanceValue}');
                                print('durationText-------${directionDetailsInfo.durationText}');
                                print('durationValue-------${directionDetailsInfo.durationValue}');


                                // Время путешествия Сумма тарифа в минуту
                                double timeTraveledFareAmountPerMinute = (directionDetailsInfo.durationValue! / 60) * 0.1;
                                print('timeTraveledFareAmountPerMinute-----$timeTraveledFareAmountPerMinute');

                                // Сумма пройденного расстояния в километрах
                                double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distanceValue! / 1000) * 12;
                                print('distanceTraveledFareAmountPerKilometer-----$distanceTraveledFareAmountPerKilometer');

                                String totalFareAmount = (timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer).toStringAsFixed(1);
                                print('totalFareAmount-----$totalFareAmount');

                              ref.read(centerPositionProvider.notifier).state = latLng;


                                // Navigation().navigateToMapScreen(context:context, args: {
                                //   'objecLatLng':latLng,
                                //   'distanceText':'distanceText',
                                //   'durationText':'durationText',
                                //   'totalKGS':'totalKGS',
                                //   'fromWhichScreen':'placesScreen',
                                // });


                              });


                            },
                            child: CachedNetworkImg(
                                imageUrl:
                                placeModelList[index].locationImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichSpanText(spanText: SnapTextModel(title: 'Объект: ', data: placeName, postTitle: '')),
                              RichSpanText(spanText: SnapTextModel(title: 'Адрес: ', data: addressDescription, postTitle: '')),
                              RichSpanText(spanText: SnapTextModel(title: 'Создан: ', data: Utils().dateParse(milliseconds: placeModelList[index].addedAt), postTitle: '')),
                              //RichSpanText(spanText: SnapTextModel(title: 'Статус: ', data: placeModelList[index].successStatus.toString(), postTitle: '')),
                              //RichSpanText(spanText: SnapTextModel(title: 'id: ', data: placeModelList[index].docId.toString(), postTitle: '')),
                            ],
                          ),
                          IconButton(icon: Icon(
                            Icons.edit, color: Theme.of(context).primaryColor,),
                            onPressed: () {
                              Navigation().navigateToCreatePlaceScreen(
                                  context,
                                  IntentArguments(
                                    placeModel: placeModelList[index],
                                    fromWhichScreen: 'placesScreen',
                                  ));
                            },)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SingleButton(title: 'Оформить заказ', onPressed: () => onTapCreateOrder(placeModelList[index])),
                          SingleButton(title: 'Просмотреть заказы', onPressed: () => onTapToOrders(placeModelList[index])),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),
          );
        },

      ),
    ),
  );
}




// Widget _contentListView({
//   required List<PlaceModel> placeModelList,
//   required VoidCallback onTapMap,
//   required Function onTapAddDiscount,
//   required Function onTapToOrders,
//   required VoidCallback onTapItems,
// }){
//
//   return ListView.builder(
//       itemCount: placeModelList.length,
//       itemBuilder: (BuildContext context, int index) {
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             padding: const EdgeInsets.all(8.0),
//             margin: const EdgeInsets.only(bottom: 5.0),
//             decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius:
//                 const BorderRadius.all(Radius.circular(10.0))),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 100.0,
//                   child: Row(
//                     children: [
//                       Flexible(
//                         child: ClipRRect(
//                           borderRadius:
//                           const BorderRadius.all(Radius.circular(10.0)),
//                           child: CachedNetworkImg(
//                               imageUrl: placeModelList[index].placeImage,
//                               width: double.infinity,
//                               height: double.infinity,
//                               fit: BoxFit.cover),
//                         ),
//                       ),
//                       Flexible(
//                         child: ClipRRect(
//                           borderRadius:
//                           const BorderRadius.all(Radius.circular(10.0)),
//                           child: GestureDetector(
//                             onTap: onTapMap,
//
//                             child: CachedNetworkImg(
//                                 imageUrl:
//                                 placeModelList[index].locationImage,
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 fit: BoxFit.cover),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       RichText(
//                         text: TextSpan(
//                           text: 'Заказчик: ',
//                           style: DefaultTextStyle.of(context).style,
//                           children: <TextSpan>[
//                             TextSpan(
//                                 text: '',
//                                 style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ),
//                       RichText(
//                         text: TextSpan(
//                           text: 'Статус: ',
//                           style: DefaultTextStyle.of(context).style,
//                           children: <TextSpan>[
//                             TextSpan(
//                                 text: placeModelList[index]
//                                     .successStatus
//                                     .toString(),
//                                 style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ),
//                       RichText(
//                         text: TextSpan(
//                           text: 'Скидка: ',
//                           style: DefaultTextStyle.of(context).style,
//                           children: <TextSpan>[
//                             TextSpan(
//                                 text: placeModelList[index].placeDiscount.toString(),
//                                 style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ),
//                       RichText(
//                         text: TextSpan(
//                           text: 'Создан: ',
//                           style: DefaultTextStyle.of(context).style,
//                           children: <TextSpan>[
//                             TextSpan(
//                                 text: Utils().dateParse(
//                                     milliseconds:
//                                     placeModelList[index].addedAt),
//                                 style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           GestureDetector(
//                             onTap:() => onTapAddDiscount(placeModelList[index]),
//                             child: const Chip(
//                               label: Text(
//                                 'Установить скидку',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                               shape: StadiumBorder(
//                                   side: BorderSide(color: Colors.grey)),
//                               backgroundColor: Colors.transparent,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap:() => onTapToOrders(placeModelList[index]),
//                             child: const Chip(
//                               label: Text(
//                                 'Просмотреть заказы',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                               shape: StadiumBorder(
//                                   side: BorderSide(color: Colors.grey)),
//                               backgroundColor: Colors.transparent,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//
//
//
//                   onTap: onTapItems,
//
//                   //     () {
//                   //   navigation.navigateToOrdersScreen(
//                   //       context, IntentCurrentUserIdObjectIdProjectRootId(
//                   //       projectRootId: ref.watch(currentUserProvider).uId,
//                   //       placeId: placeModelList[index].docId!));
//                   // },
//                 ),
//               ],
//             ),
//           ),
//         );
//       });
// }



Widget _popUpMenuBtn(BuildContext context, navigation, WidgetRef ref){

  return IconButton(
      onPressed: (){

        navigation.navigateToCreatePlaceScreen(context,
            IntentCurrentUserIdFromWhichPage(
                currentUserId: ref.watch(currentUserProvider).uId,
                fromWhichScreen: 'placesScreen'));

      },
      icon: const Icon(Icons.add_home_outlined));
}








