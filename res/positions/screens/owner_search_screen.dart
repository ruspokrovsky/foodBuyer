
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/home/home_services/home_services.dart';
import 'package:ya_bazaar/res/home/widgets/hero_container.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/positions/positions_services/positions_services.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/chip_btn.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/search_widget.dart';
import 'package:ya_bazaar/theme.dart';

class OwnerSearchScreen extends ConsumerStatefulWidget {
  static const String routeName = "ownerSearchScreen";

  final IntentRootPlaceArgs navigateSearchArgs;

  const OwnerSearchScreen({super.key, required this.navigateSearchArgs});

  @override
  OwnerSearchScreenState createState() => OwnerSearchScreenState();
}

class OwnerSearchScreenState extends ConsumerState<OwnerSearchScreen> {
  Utils utils = Utils();
  Navigation navigation = Navigation();
  final GlobalKey _textEditingKey = GlobalKey<FormFieldState>();
  late HomeFBServices dbs = HomeFBServices();
  PlaceModel? placeData;
  UserModel? projectRootUser;
  String? fromWhichScreen;
  String currentRootId = '';
  List<PositionModel> allPositionList = [];

  bool isPositioned = false;
  int queryLength = 0;
  String query = '';
  List<int> queryArray = [];
  int rootUserSelectedIndex = -1;

  bool loading = false;

  // Future<void> _getMultiplePositions() async {
  //   late PositionsFBServices dbs = PositionsFBServices();
  //   await dbs.fetchMultiplePosition(projectRootIdList: [
  //     'r9RxHHyJiVVXoJAb8AFeCK5Qdx32',
  //     'UnmD1QtHj8YN5IrvkZNdy1OXt7x1',
  //     'LHODf8WrD8UJKNQEDEWlvWMXbZL2'
  //   ]).then((List<dynamic> value) {
  //     ref.read(multiplePositionsListProvider.notifier)
  //       ..clearPositions()
  //       ..buildMultiplePositionList(
  //         ref,
  //         value,
  //       );
  //     setState(() {});
  //   });
  // }

  // Future<void> _getPositions(String rootId) async {
  //
  //   ref.watch(joinPositionsProvider(ref.watch(subscribersSortProvider).subscribersIdList))
  //       .whenData((value) async {
  //     ref.read(positionsListProvider.notifier)
  //       ..clearPositions()
  //       ..buildMultiplePositionList(value);
  //     },
  //   );
  // }

  List<dynamic> singleArgumentList = [];
  List<dynamic> argumentList = [];

  @override
  void initState() {
    placeData = widget.navigateSearchArgs.placeModel;
    projectRootUser = widget.navigateSearchArgs.rootUserModel;
    fromWhichScreen = widget.navigateSearchArgs.fromWhichScreen;
    //_getMultiplePositions();
    //_getPositions(projectRootUser!.uId);

    //добавляем параметр в массив т.к. получаем позиции из разных коллекций по списку rootId
    if (projectRootUser!.uId.isNotEmpty) {
      singleArgumentList = [projectRootUser!.uId];
    }

    super.initState();
  }

  bool ddd = false;

  bool isAllPosition = false;
  String hintText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          num totalSum = 0;

          ref.read(usersListProvider.notifier).isSelectedUser(ref);


          ref.watch(getPositionsByRootIdProvider(ref.watch(currentUserProvider).rootId!))
              .whenData((value) async {
            ref.read(positionsListProvider.notifier)
              ..clearPositions()
              ..buildPositionList(value,);
          });



          // if(ref.watch(positionsListProvider).isNotEmpty){
          //   totalSum = ref.read(positionsListProvider.notifier).totalSum();
          //
          // }

          List<PositionModel> positionsList = [];
          if (ref.watch(subCategoryProvider).subCategoryName.isNotEmpty) {
            positionsList = ref.watch(positionsListProvider)
                .where((v) => v.subCategoryId == ref.watch(subCategoryProvider).docId!)
                .toList();
          }
          else {
            //positionsList = ref.watch(positionsListProvider);

            if (ref.watch(subCategoryProvider).otherValue == 'отрицательное') {
              positionsList = ref.watch(positionsListProvider)
                  .where((v) => v.productQuantity < 0)
                  .toList();
              hintText = 'Отрицательное количество';
            }
            else if(ref.watch(subCategoryProvider).otherValue == 'нулевое'){
              positionsList = ref.watch(positionsListProvider)
                  .where((v) => v.productQuantity == 0)
                  .toList();
              hintText = 'Нулевое количество';
            }
            else if(ref.watch(subCategoryProvider).otherValue == 'норм'){
              positionsList = ref.watch(positionsListProvider)
                  .where((v) => v.productQuantity > 0)
                  .toList();
              hintText = 'Положительное количество';
            }
            else if(ref.watch(subCategoryProvider).otherValue == 'заявлено'){
              positionsList = ref.watch(positionsListProvider)
                  .where((v) => v.united > 0)
                  .toList();
              hintText = 'Заявленные позиции';
            }else {
              positionsList = ref.watch(positionsListProvider);
            }
          }

          // сортировка по отрицательному числу



          if (query.isNotEmpty) {
            positionsList = positionsList.where((book) {
              final titleLower = book.productName.toLowerCase();
              final searchLower = query.toLowerCase();
              return titleLower.contains(searchLower);
            }).toList();
          }


          if(positionsList.isNotEmpty){
            totalSum = positionsList.map((e) => e.productQuantity * e.productFirsPrice)
                .reduce((value, element) => value + element);

            //totalSum всех позиций
            //ref.read(positionsListProvider.notifier).totalSum();

            num currentQtyPosition = positionsList.length;

            //ref.read(currentTotalAndQtyPrivider.notifier).state = [currentTotal,currentQtyPosition];

          }
          else {
            totalSum = 0;
          }

          return BaseLayout(
              onWillPop: (){return Future.value(true);},
              isAppBar: true,
              avatarUrl: projectRootUser!.subjectImg!,
              appBarTitle: projectRootUser!.subjectName!,
              avatarTap: () {
              navigation.navigationToCreateAccountScreen(
                  context, ref.watch(currentUserProvider));
              },
              isBottomNav: false,
              isFloatingContainer: false,
              flexibleContainerChild: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichSpanText(spanText: SnapTextModel(title: 'Всего позиций: ', data: '${positionsList.length}', postTitle: '')),
                            RichSpanText(spanText: SnapTextModel(
                                title: 'На сумму: ',
                                data: '${utils.numberParse(value: totalSum)}',
                                postTitle: ' UZS')),
                            RichSpanText(spanText: SnapTextModel(
                                title: 'Категория: ',
                                data: ref.watch(subCategoryProvider).subCategoryName.isEmpty ? 'Пказаны все': ref.watch(subCategoryProvider).subCategoryName,
                                postTitle: '')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChipButton(
                          avatar: const Icon(Icons.edit, color: Colors.white,),
                            lable: 'Изменить',
                            onTap: (){
                              //navigation.navigationToCreateSubjectScreen(context, ref.watch(currentUserProvider));

                              UserModel currentUserData = ref.watch(currentUserProvider);

                              PlaceModel placeModel = PlaceModel.empty();
                              placeModel.placeName = currentUserData.subjectName!;
                              placeModel.locationLatLng = currentUserData.subjectLatLng!;
                              placeModel.placeImage = currentUserData.subjectImg!;

                              navigation.navigateToCreatePlaceScreen(context, IntentArguments(
                                userModel: ref.watch(currentUserProvider),
                                placeModel: placeModel,
                                fromWhichScreen: 'ownerSearchScreen',
                              ));

                            }),
                        ChipButton(
                            avatar: const Icon(Icons.add, color: Colors.white,),
                            lable: 'Добавить',
                            onTap: (){
                              navigation.navigationToCategorySelector(context).then((value) {
                                PositionModel position = PositionModel.empty();

                                position.subCategoryId = ref.watch(subCategoryProvider).docId!;
                                position.subCategoryName = ref.watch(subCategoryProvider).subCategoryName;
                                ref.read(subCategoryProvider.notifier).clean();
                                navigation.navigationToCreatePositionScreeen(context, position);


                              });
                            }),
                        ChipButton(
                            avatar: const Icon(Icons.print, color: Colors.white,),
                            lable: 'Печать',
                            onTap: () async {
                              String fileName = 'Склад от ${utils.dateParse(milliseconds: DateTime.now().millisecondsSinceEpoch)}';

                              await utils.saveExcelFile(fileName: fileName, data: ref.watch(positionsListProvider))
                                  .then((String filePath) async{
                                await OpenFile.open(filePath);
                              });
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        IconButton(
                            tooltip: 'отрицательное количество',
                            onPressed: () async {

                              //для обновления на складе
                              // PositionsFBServices fbs = PositionsFBServices();
                              // List<PositionModel> position = ref.watch(positionsListProvider);
                              // await fbs.addPosition3(projectRootId: ref.watch(currentUserProvider).uId, positionModelList: position)
                              //     .then((value) => print('addPosition ---------------- success'));

                              //для загрузки на склад
                               //PositionsFBServices fbs = PositionsFBServices();
                               //String rootUserId = ref.watch(currentUserProvider).uId;
                              // List<PositionModel> position = ref.watch(positionsListProvider);
                              // for (var element in dddd) {
                              //
                              //   await fbs.addPosition3(
                              //     projectRootId: rootUserId,
                              //     positionModel: PositionModel(
                              //       projectRootId: rootUserId,
                              //       productName: element['name'],
                              //       productMeasure: 'кг',
                              //       productFirsPrice: 0,
                              //       productPrice: 0,
                              //       productQuantity: 0,
                              //       marginality: 0,
                              //       deliverSelectedTime: 0,
                              //       available: true,
                              //       subCategoryName: '',
                              //       subCategoryId: 'XTcZHqdc0ESDqm85KJS9',
                              //       deliverId: '',
                              //       deliverName: '',
                              //       //cartQty: 0,
                              //       amount: 0,
                              //       united: 0,
                              //       productImage: '',
                              //       unitedList: [],
                              //       addedAt: DateTime.now().millisecondsSinceEpoch,
                              //     ),
                              //   );
                              // }





                          // ref.read(subCategoryProvider.notifier).updateSubCategory(
                          //     SubCategoryModel(
                          //         subCategoryName: '',
                          //         otherValue: 'отрицательное'));
                          // setState(() {});

                        }, icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.grey,)),
                        IconButton(
                            tooltip: 'нулевое количество',
                            onPressed: (){
                          ref.read(subCategoryProvider.notifier).updateSubCategory(
                              SubCategoryModel(
                                  subCategoryName: '',
                                  otherValue: 'нулевое'));
                          setState(() {});


                        }, icon: const Icon(Icons.circle_outlined, color: Colors.grey,)),
                        IconButton(
                            tooltip: 'положительное количество',
                            onPressed: (){
                          ref.read(subCategoryProvider.notifier).updateSubCategory(
                              SubCategoryModel(
                                  subCategoryName: '',
                                  otherValue: 'норм'));
                          setState(() {});
                        }, icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey,)),
                        IconButton(
                            tooltip: 'позиции на закуп',
                            onPressed: (){
                          ref.read(subCategoryProvider.notifier).updateSubCategory(
                              SubCategoryModel(
                                  subCategoryName: '',
                                  otherValue: 'заявлено'));
                          setState(() {});
                        }, icon: const Icon(Icons.add_chart, color: Colors.grey,)),
                        IconButton(
                            tooltip: 'все позиции',
                            onPressed: (){
                          ref.read(subCategoryProvider.notifier).clean();
                        }, icon: const Icon(Icons.join_inner, color: Colors.grey,)),
                        IconButton(
                            tooltip: 'категории',
                            onPressed: () async{

                          await navigation.navigationToCategorySelector(context).then((value) {

                            print('---------value');
                            print(value);
                            print('----------value');});



                        }, icon: const Icon(Icons.category, color: Colors.grey,)),

                        //Text( ref.watch(currentTotalAndQtyPrivider).toString()),
                      ],
                    ),

                    buildSearch(categoryPressed: (){}, onTapJoinPosition: (){}, onTapCart: (){}),

                  ],
                ),
              ),
              flexibleSpaceBarTitle: const SizedBox.shrink(),
              slivers: [_allDataView(
                context: context,
                positionsList: positionsList,
                query: query,
                ref: ref,
                //projectRootId: currentRootId,
                onTapSettings: (PositionModel position) {
                  navigation.navigationToCreatePositionScreeen(
                      context, position);
                },
                utils: utils,
              )],
              isProgress: false,
            isPinned: false,
            radiusCircular: 0.0,
            isFloating: true,
            flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
            expandedHeight: 228.0,);
        },
      ),
    );
  }

  Widget buildSearch({
    required VoidCallback categoryPressed,
    required VoidCallback onTapJoinPosition,
    required VoidCallback onTapCart,
  }) =>
      SearchWidget(
        text: 'query',
        hintText: 'Поиск...',
        onChanged: searchBook,
        isAdditionalBtn: false,
      );

  void searchBook(String query) {
    if (ref.watch(categoryIdProvider).isNotEmpty) {}

    final books = allPositionList.where((book) {
      final titleLower = book.productName.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    if (query.isNotEmpty) {
      allPositionList = books;
    } else {
      setState(() {
        allPositionList = [];
        //getAllPosition();
      });
    }
    setState(() {
      this.query = query;
    });
  }
}


Widget _allDataView({
  required BuildContext context,
  required String query,
  required WidgetRef ref,
  //required String projectRootId,
  required Function onTapSettings,
  required Utils utils,
  required List<PositionModel> positionsList,
}) {
  AppStyles styles = AppStyles.appStyle(context);

  var size = MediaQuery.of(context).size;
  final double itemHeight = size.height / 2.8;
  final double itemWidth = size.width / 2;



  if (positionsList.isEmpty) {
    return const SliverFillRemaining(
        child: ProgressMini(
      radius: 50.0,
    ));
  } else {
    return SliverPadding(
      padding: const EdgeInsets.all(5.0),
      sliver: SliverGrid(
        //physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            childAspectRatio: (itemWidth / itemHeight)),
        delegate: SliverChildBuilderDelegate(
            childCount: positionsList.length,
            (BuildContext context, int index) {
          //num positionAmount = 0;

          num positionAmount = (positionsList[index].productFirsPrice * positionsList[index].productQuantity);


          String ndsStatus = 'Без НДС';

          if(positionsList[index].ndsStatus != null) {
            ndsStatus = positionsList[index].ndsStatus! ? 'НДС' : 'Без НДС';
          }

          return Container(
            padding: const EdgeInsets.all(5.0),
            decoration: styles.positionBoxDecoration!,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: HeroContainer(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 12.0,
                        boxFit: BoxFit.cover,
                        heroTag: positionsList[index].productName,
                        imgPatch: positionsList[index].productImage,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(positionsList[index].productName, style: Theme.of(context).textTheme.bodyMedium,),
                        const Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Наличие: ',
                                    data: utils.numberParse(value: positionsList[index].productQuantity),
                                    postTitle: ' ${positionsList[index].productMeasure}')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Сумма: ',
                                    data: utils.numberParse(value: positionAmount),
                                    postTitle: ' UZS')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Закуп: ',
                                    data: utils.numberParse(value: positionsList[index].productFirsPrice),
                                    postTitle: ' UZS')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Маржа: ',
                                    data: '${positionsList[index].marginality}',
                                    postTitle: ' %')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'НДС: ',
                                    data: ndsStatus,
                                    postTitle: '')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Отпуск: ',
                                    data: utils.numberParse(value: positionsList[index].productPrice),
                                    postTitle: ' UZS')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Закупить: ',
                                    data: utils.numberParse(value: positionsList[index].united),
                                    postTitle: ' ${positionsList[index].productMeasure}')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Всего заявок: ',
                                    data: '${positionsList[index].unitedList!.length}',
                                    postTitle: '')),
                            RichSpanTextMini(
                                spanText: SnapTextModel(
                                    title: 'Обновлено: ',
                                    data: '${utils.dateParse(milliseconds: positionsList[index].addedAt)}',
                                    postTitle: '')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                    child: CircleAvatar(
                      backgroundColor: styles.chip2BackgroundColor,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white,),
                                        onPressed: () => onTapSettings(positionsList[index]),),
                    ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

Widget _popUpMenuBtn({
  required BuildContext context,
  required Function onSelected,
}) {
  return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      onSelected: (int itemIndex) => onSelected(itemIndex),
      itemBuilder: (BuildContext context) => [
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 0,
                child: const Text('Добавить позицию')),
          ]);
}




