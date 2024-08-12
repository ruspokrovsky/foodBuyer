import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/cart/screens/cart_screen.dart';
import 'package:ya_bazaar/res/home/home_controllers/category_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/sub_category_controller.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/home/home_services/home_services.dart';
import 'package:ya_bazaar/res/home/widgets/hero_container.dart';
import 'package:ya_bazaar/res/models/circle_horizontal_list_model.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/places/place_providers/place_providers.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/chip_btn.dart';
import 'package:ya_bazaar/res/widgets/horizontal_%20rectangle_list.dart';
import 'package:ya_bazaar/res/widgets/horizontal_circle_list.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/search_widget.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const String routeName = "searchScreen";

  final IntentRootPlaceArgs navigateSearchArgs;

  const SearchScreen({super.key, required this.navigateSearchArgs});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
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

  List<PositionModel> currentPositionList = [];

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.read(usersListProvider.notifier).isSelectedUser(ref);



        List<UserModel> subscribeUsersListForView = ref
            .watch(subscribersSortProvider).subscribOwnerList;

        List<dynamic> subscribersIdList = ref.watch(subscribersSortProvider).subscribersIdList;
        List<PositionModel> refPositionList = ref.watch(positionsListProvider);


        if (singleArgumentList.isNotEmpty) {
          String rootIdArgs = singleArgumentList.single;

          if (refPositionList.isNotEmpty) {
            List<String> refRootIdList = refPositionList.map((e) => e.projectRootId).toList();

            if (refRootIdList.contains(rootIdArgs)) {
              currentPositionList = ref.read(positionsListProvider.notifier).positionList(rootIdArgs);
            }

            else {
              ref
                  .watch(joinPositionsProvider(singleArgumentList))
                  .whenData((value) async {
                ref.read(positionsListProvider.notifier)
                  ..clearPositions()
                  ..buildMultiplePositionList(value);
                currentPositionList = ref.watch(positionsListProvider);
              });
            }
          }

          else {
            ref.watch(joinPositionsProvider(singleArgumentList))
                .whenData((value) async {
              ref.read(positionsListProvider.notifier)
                ..clearPositions()
                ..buildMultiplePositionList(value);
              currentPositionList = ref.watch(positionsListProvider);
            });
          }
        }

        if(subscribeUsersListForView.length == 1 && projectRootUser!.uId.isEmpty){
          projectRootUser = subscribeUsersListForView.single;
        }



        return BaseLayout(
          onWillPop: () {return Future.value(true);},
          isAppBar: true,
          titleContainer: buildSearch(categoryPressed: () {
            navigation.navigationToCategorySelector(context).then((value) {});
          },
          onTapCart: () async {},
          onTapJoinPosition: () {}),
          isBottomNav: false,
          isFloatingContainer: false,
          flexibleContainerChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                if (fromWhichScreen == 'placesScreen')
                  RectangleHorizontalList(
                    height: 106.0,
                    rootUsersList: subscribeUsersListForView,
                    isSubContent: false,
                    selectedIndex: rootUserSelectedIndex,
                    onTapElement: (UserModel userByIndex, int index) {

                      setState(() {
                        for (var element in subscribeUsersListForView) {
                          if(element.isSelectedElement!){
                            element.isSelectedElement = false;
                          }
                        }
                        userByIndex.isSelectedElement = true;
                        projectRootUser = userByIndex;
                        singleArgumentList = [userByIndex.uId];
                        rootUserSelectedIndex = index;
                      });
                      print(userByIndex.isSelectedElement);
                    },
                    //onDoubleTapElement: (elementId, elementName) {},
                  )
                else
                Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50.0)),
                        child: CachedNetworkImg(
                            imageUrl: projectRootUser!.subjectImg!,
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.cover),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichSpanText(spanText: SnapTextModel(title: 'Поставщик: ', data: projectRootUser!.subjectName!, postTitle: '')),
                            RichSpanText(spanText: SnapTextModel(title: 'Телефон: ', data: projectRootUser!.userPhone, postTitle: '')),
                            RichSpanText(spanText: SnapTextModel(title: 'Кешбэк: ', data: projectRootUser!.discountPercent!.toString(), postTitle: ' %')),
                            RichSpanText(spanText: SnapTextModel(title: 'Лимит: ', data: Utils().numberParse(value: projectRootUser!.limit), postTitle: ' UZS')),
                            RichSpanText(spanText: SnapTextModel(title: 'Всего позиций: ', data: ref.watch(positionsListProvider).length.toString(), postTitle: '')),
                          ],
                        ),
                      )
                    ],
                  ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    if (ref.watch(subCategoryProvider).subCategoryName.isNotEmpty)
                      Expanded(
                        child: ChipButton(
                            avatar: const Icon(
                              Icons.join_inner,
                              color: Colors.white,
                            ),
                            lable: 'Сбросить',
                            onTap: () {
                              ref.read(subCategoryProvider.notifier).clean();
                              projectRootUser = UserModel.empty();
                              singleArgumentList = [];
                              rootUserSelectedIndex = -1;
                              //переменная fromWhichScreen контролирует что будет отоброжаться RectangleHorizontalList или один rootUser
                              fromWhichScreen = 'placesScreen';
                              setState(() {});
                            }),
                      ),
                      Expanded(
                        child: ChipButton(
                            avatar: const Icon(
                              Icons.category,
                              color: Colors.white,
                            ),
                            lable: 'Категории',
                            onTap: () {
                              navigation
                                  .navigationToCategorySelector(context)
                                  .then((value) {});
                            }),
                      ),
                      //разобраться!!!!!!!!!!!!!!!!!!!!!
                      Expanded(
                        child: ChipButton(
                          avatar: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          ),
                          lable: 'Корзина',
                          onTap: () async {
                            PositionModel posModel = PositionModel.empty();
                            posModel.projectRootId = projectRootUser!.uId;
                            await _createCartData(
                              ref: ref,
                              position: posModel,
                            ).then((v) async {
                              await navigation.navigateToCartScreen(
                                context,
                                IntentRootPlaceArgs(
                                  rootUserModel: projectRootUser!,
                                  placeModel: placeData!,
                                  fromWhichScreen: 'searchScreen',
                                ),
                              )
                                  .then((v) {
                                if (fromWhichScreen == 'cartScreen') {
                                  Navigator.pop(context);
                                }
                              });
                            });
                          }),),

                    ]),
                const SizedBox(height: 6.0,),
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),

                  ),
                  child: Text('Внимание! Цена на позицию определяется по факту её закупки на рынке. Соответственно, цены в текущем заказе могут измениться в зависимости от рыночных условий при закупке.',
        style: styles.worningTextStyle,),

                )
              ],
            ),
          ),
          flexibleSpaceBarTitle: const SizedBox.shrink(),

          slivers: [

            if(projectRootUser!.uId.isNotEmpty)
            allDataView(
              context: context,
              subscribePositionsList: currentPositionList,
              query: query,
              ref: ref,
              projectRootId: currentRootId,
              onTapPosition: (PositionModel position) async {
                UserModel rootUser = ref
                    .read(usersListProvider.notifier)
                    .getUserByRootId(position.projectRootId);


                MultipleCartModel currentCartData = ref
                    .read(multipleCartListProvider.notifier)
                    .currentCartData(position.projectRootId);

                if (!position.isSelected!) {
                  if (currentCartData.currentCartList.isNotEmpty) {
                    if (currentCartData.customerId != ref.watch(currentPlaceProvider).docId) {
                      utils.dialogBuilder(
                          context: context,
                          title: 'Внимание!',
                          content: RichText(
                            text: TextSpan(
                              text: 'В корзине: "',
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: <TextSpan>[
                                TextSpan(
                                    text: rootUser.name,
                                    style: const TextStyle(
                                        color: Colors.deepOrange)),
                                const TextSpan(
                                    text:
                                        '" имеются позиции для адреса доставки "'),
                                TextSpan(
                                    text: currentCartData.customerName,
                                    style: const TextStyle(
                                        color: Colors.deepOrange)),
                                const TextSpan(text: '". Очистить корзину?'),
                              ],
                            ),
                          ),
                          btnPositiveText: 'Очистить корзину',
                          onPositivePressed: () {
                            ref
                                .read(multipleCartListProvider.notifier)
                                .removeCartList(
                                    ref: ref,
                                    projectRootId:
                                        currentCartData.projectRootId)
                                .whenComplete(() {
                              setState(() {});
                            }).whenComplete(() => Navigator.pop(context));
                          },
                          btnNeutralText: 'Корзина',
                          onNeutralPressed: () {
                            // navigation.navigateToCartScreen(context);

                            Navigator.pushReplacement<void, void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => CartScreen(
                                  navigateSearchArgs: IntentRootPlaceArgs(
                                    rootUserModel: rootUser,
                                    placeModel: placeData!,
                                    fromWhichScreen: 'searchScreen',
                                  ),
                                ),
                              ),
                            );
                          },
                          contentPadding: 8.0);
                    }
                    else {
                      await navigation
                          .navigateToAddToCartScreen(
                              context,
                              IntentPlacePositionRootUserArgs(
                                  placeData: placeData!,
                                  positionData: position,
                                  projectRootUser: rootUser))
                          .then((value) {
                        //ref.read(positionsListProvider.notifier).isSelectedChange(position.docId,position.isSelected);
                        setState(() {});
                      });
                    }
                  }
                  else {
                    await navigation
                        .navigateToAddToCartScreen(
                            context,
                            IntentPlacePositionRootUserArgs(
                                placeData: placeData!,
                                positionData: position,
                                projectRootUser: rootUser))
                        .then((value) {
                      //ref.read(positionsListProvider.notifier).isSelectedChange(position.docId,position.isSelected);

                      setState(() {});
                    });
                  }
                }
                else {
                  await _createCartData(
                    ref: ref,
                    position: position,
                  ).whenComplete(() {
                    navigation
                        .navigateToCartScreen(
                      context,
                      IntentRootPlaceArgs(
                        rootUserModel: rootUser,
                        placeModel: placeData!,
                        fromWhichScreen: 'searchScreen',
                      ),
                    ).then((value) {
                      setState(() {});
                    });
                  });
                }
              },
              onLongPressPosition: (PositionModel currentPositionData) {
                // navigation.navigationToCreatePositionScreeen(
                //     context, currentPositionData);
              },
              utils: utils,
            )
            else
              SliverToBoxAdapter(
                child: Center(
                  child: Text('Выберите поставщика', style: styles.worningTextStyle,),
                ),
              ),
          ],
          isPinned: false,
          isProgress: false,
          isFloating: true,
          radiusCircular: 0.0,
          expandedHeight: 280.0,
        );
      },
    );
  }

  Widget buildSearch({
    required VoidCallback categoryPressed,
    required VoidCallback onTapJoinPosition,
    required VoidCallback onTapCart,
  }) =>
      SearchWidget(
        text: query,
        hintText: 'Поиск',
        onChanged: searchBook,
        isAdditionalBtn: false,
        categoryPressed: categoryPressed,
        //onTapBack: () => Navigator.pop(context),
        onTapCart: onTapCart,
        isAvatarGlow: (ref.watch(orderListProvider).isNotEmpty) ? true : false,
        onTapJoinPosition: onTapJoinPosition,
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

Future<void> _createCartData({
  required WidgetRef ref,
  required PositionModel position,
}) async {
  List<MultipleCartModel> multipleCartList =
      ref.watch(multipleCartListProvider);

  if (multipleCartList.isNotEmpty) {
    List<String> cartIdList =
        multipleCartList.map((e) => e.projectRootId).toList();

    if (cartIdList.contains(position.projectRootId)) {
      for (var element in multipleCartList) {
        if (element.projectRootId == position.projectRootId) {
          ref.read(orderListProvider.notifier).updateCurrentCart(element.currentCartList);
        }
      }
    }
  } else {
    return;
  }
}

Widget _horizontalListAndFilter(
    {required BuildContext context,
    required Function onTapElement,
    required Function onDoubleTapElement,
    required List<PositionModel> positionList,
    required VoidCallback onTapFilter}) {
  return Consumer(
    builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final List<CircleHorizontalListModel> circleHorizontalList = [];
      final category = ref.watch(categoryProvider);
      final CategoryController categoryController =
          ref.watch(categoryListProvider.notifier);

      category.when(
          data: (categoryData) {
            categoryController.clearCategoryList();
            categoryController.buildCategory(categoryData);
            ref.watch(categoryListProvider).forEach((element) {
              circleHorizontalList.add(CircleHorizontalListModel(
                  id: element.categoryId!, name: element.categoryName));
            });
            return circleHorizontalList;
          },
          error: (_, __) => const SizedBox(),
          loading: () => const SizedBox());
      return Padding(
        padding: const EdgeInsets.only(top: 46.0),
        child: Flex(
          direction: Axis.vertical,
          children: [
            CircleHorizontalList(
              cHorizontalListModel: circleHorizontalList,
              onTapElement: (elementId, elementName) =>
                  onTapElement(elementId, elementName),
              onDoubleTapElement: (elementId, elementName) =>
                  onDoubleTapElement(elementId, elementName),
            ),
            TwoButtonsBlock(
              positiveText: 'Показать все',
              positiveClick: () {
                ref
                    .read(subCategoryProvider.notifier)
                    .updateSubCategory(SubCategoryModel.empty());
                ref
                    .read(isPositionedProvider.notifier)
                    .updateIsPositioned(false);
              },
              negativeText: 'Фильтр',
              negativeClick: onTapFilter,
            ),
            Text('Всего позиций: ${positionList.length}'),
            const SizedBox(
              height: 5.0,
            ),
          ],
        ),
      );
    },
  );
}

Widget _subCategoryList({
  required String categoryId,
  required Function onTap,
  required Function popupItemPressed,
}) {
  return Consumer(
    builder: (BuildContext context, WidgetRef ref, Widget? child) {
      List<SubCategoryModel> subCategoryList = [];
      final subCategory =
          ref.watch(getSubCategoryByCategoryIdProvider(categoryId));
      final SubCategoryListController subCategoryListController =
          ref.read(subCategoryListProvider.notifier);
      return subCategory.when(
          data: (subCategoryData) {
            subCategoryListController.clearSubCategoryList();
            subCategoryListController.buildSubCategoryList(subCategoryData);
            subCategoryList = ref.watch(subCategoryListProvider);
            return Expanded(
              child: ListView.builder(
                  itemCount: subCategoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subCategoryList[index].subCategoryName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(
                            subCategoryList[index].docId!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      trailing: (ref.watch(currentUserProvider).userStatus ==
                              'owner')
                          ? _popUpMenuBtn(
                              context: context,
                              onSelected: (int pressedIndex) =>
                                  popupItemPressed(
                                      pressedIndex,
                                      subCategoryList[index].subCategoryName,
                                      subCategoryList[index].docId),
                            )
                          : null,
                      onTap: () {
                        onTap(subCategoryList[index].docId,
                            subCategoryList[index].subCategoryName);
                      },
                      // onLongPress: () => popupItemPressed(subCategoryList[index].subCategoryName,subCategoryList[index].docId),
                    );
                  }),
            );
          },
          error: (_, __) => const SizedBox(),
          loading: () => const SizedBox());
    },
  );
}

Widget allDataView({
  required BuildContext context,
  required String query,
  required WidgetRef ref,
  required String projectRootId,
  required Function onTapPosition,
  required Function onLongPressPosition,
  required Utils utils,
  required List<PositionModel> subscribePositionsList,
}) {
  AppStyles styles = AppStyles.appStyle(context);
  List<PositionModel> positionsList = [];
  var size = MediaQuery.of(context).size;
  final double itemHeight = size.height / 2.8;
  final double itemWidth = size.width / 2;


  if (projectRootId.isNotEmpty) {
    positionsList = subscribePositionsList
        .where((v) => v.projectRootId == projectRootId)
        .toList();
  } else {
    positionsList = subscribePositionsList;
  }

  // if (ref.watch(subCategoryProvider).subCategoryName.isNotEmpty) {
  //   positionsList = subscribePositionsList
  //       .where((v) => v.subCategoryId == ref.watch(subCategoryProvider).docId!)
  //       .toList();
  // } else {
  //   positionsList = subscribePositionsList;
  // }

  if (ref.watch(subCategoryProvider).subCategoryName.isNotEmpty) {
    positionsList = ref.watch(positionsListProvider)
        .where((v) => v.subCategoryId == ref.watch(subCategoryProvider).docId!)
        .toList();
  } else {
    positionsList = ref.watch(positionsListProvider);

  }

  if (query.isNotEmpty) {
    positionsList = positionsList.where((book) {
      final titleLower = book.productName.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();
  }



  ref.read(positionsListProvider.notifier).isSelectedAllChange();
  ref.read(multipleCartListProvider.notifier).buildSelectedMultiPosition(ref);



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
        delegate: SliverChildBuilderDelegate(childCount: positionsList.length,
            (BuildContext context, int index) {
          num positionAmount = 0;
          // ref.watch(orderListProvider).forEach((element) {
          //
          //   if(positionsList[index].docId == element.productId){
          //
          //     positionAmount = element.amountSum;
          //   }
          // });

          positionAmount = ref
              .read(multipleCartListProvider.notifier)
              .buildTotalChip(ref, positionsList[index].projectRootId,
                  positionsList[index].docId!);

          return GestureDetector(
            onTap: () => onTapPosition(positionsList[index]),
            onLongPress: () => onLongPressPosition(positionsList[index]),
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: positionsList[index].isSelected!
                  ? BoxDecoration(
                      border: Border.all(width: 4, color: Colors.deepOrange),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)))
                  : styles.positionBoxDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: HeroContainer(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 12.0,
                      boxFit: BoxFit.cover,
                      heroTag: positionsList[index].docId!,
                      imgPatch: positionsList[index].productImage,
                    ),
                  ),
                  Text(
                    positionsList[index].productName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichSpanText(spanText: SnapTextModel(title: 'UZS: ', data: Utils().numberParse(value: positionsList[index].productPrice), postTitle: ' ${positionsList[index].productMeasure}')),
                      RichSpanText(spanText: SnapTextModel(title: 'Наличие: ', data: positionsList[index].productQuantity > 0 ? 'В наличии':'На заказ', postTitle: '')),
                      RichSpanText(spanText: SnapTextModel(title: 'Обновлено: ', data: Utils().dateParse(milliseconds: positionsList[index].addedAt), postTitle: '')),

                      if (positionsList[index].isSelected!)
                        Center(
                          child: Chip(
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.deepOrange,
                            side: BorderSide.none,
                            label: Text(
                              '= ${utils.numberParse(value: positionAmount)} UZS',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            //avatar: Icon(Icons.shopping_cart_outlined),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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

_createContent(WidgetRef ref, String projectRootUser) {
  if (projectRootUser.isNotEmpty) {
    ref.read(positionsListProvider.notifier).changePositionsListByProjectRootId(
        ref.watch(notSubscribPositionsListProvider), projectRootUser);
  } else {
    ref
        .read(positionsListProvider.notifier)
        .changePositionsAllList(ref.watch(notSubscribPositionsListProvider));
  }
}