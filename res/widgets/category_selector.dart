import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/generated/locale_keys.g.dart';
import 'package:ya_bazaar/res/home/home_controllers/category_controller.dart';
import 'package:ya_bazaar/res/home/home_controllers/sub_category_controller.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/home/home_services/home_services.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/circle_horizontal_list_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/horizontal_circle_list.dart';
import 'package:ya_bazaar/theme.dart';

class CategorySelector extends ConsumerWidget {
  static const String routeName = 'categorySelector';

  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStyles styles = AppStyles();
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбор категории',
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
      body: Column(children: [
        _horizontalListAndFilter(
          context: context,
          positionList: ref.watch(positionsListProvider),
          onTapElement: (elementId, elementName) {
            ref.read(categoryIdProvider.notifier).updateCategoryId(elementId);

            if (!ref.watch(isPositionedProvider)) {
              ref.read(isPositionedProvider.notifier).updateIsPositioned(true);
            }
          },
          onTapFilter: () {},
          onDoubleTapElement: (elementId, elementName) {},
          popupItemPressed:
              (int index, String categoryId, String caetegoryName) {
            if (index == 0) {
              //category
              Get.snackbar('$index', '$index\n$categoryId\n$caetegoryName');

              Utils().showBottomSheet(
                context: context,
                title: 'Добавить категорию',
                labelText: 'Добавить категорию',
                positiveTap: (value) async {
                  if (value.isNotEmpty) {
                    if (value.isNotEmpty) {
                      CategoryModel categoryModel = CategoryModel(
                        categoryName: value,
                      );
                      await HomeFBServices().addCategory(categoryModel: categoryModel)
                          .then((value) {print('addCategory success');});
                    }
                  }
                },
              );
            } else if (index == 1) {
              //subCategory
              Get.snackbar('$index', '$index\n$categoryId\n$caetegoryName');

              Utils().showBottomSheet(
                context: context,
                title: caetegoryName,
                subTitle: 'Добавить подкатегорию',
                labelText: 'Добавить подкатегорию',
                positiveTap: (value) async {

                  if (value.isNotEmpty) {
                    SubCategoryModel subCategoryModel = SubCategoryModel(
                      categoryId: categoryId,
                      subCategoryName: value,
                    );
                    await HomeFBServices()
                        .addSubCategory(subCategoryModel: subCategoryModel)
                        .then((value) {
                      print('addCategory success');
                      Get.snackbar(caetegoryName, 'addSubCategory success!');
                    });
                  }
                },
              );
            }
          },
        ),
        _subCategoryList(
          categoryId: ref.watch(categoryIdProvider),
          onTap: (String subCategoryId, String subCategoryName) {
            print('$subCategoryId---------$subCategoryName');
            ref.read(subCategoryProvider.notifier).updateSubCategory(
                SubCategoryModel(
                    docId: subCategoryId, subCategoryName: subCategoryName));

            Navigator.pop(context, subCategoryId);
          },
          popupItemPressed: (int pressedIndex, String subCategoryName,
              String subCategoryId) {},
        ),
      ]),
    );
  }
}

Widget _subCategoryList({
  required String categoryId,
  required Function onTap,
  required Function popupItemPressed,
}) {
  AppStyles styles = AppStyles();
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
                          Text(subCategoryList[index].subCategoryName,
                              style: styles.addToCartTitleStyle),
                          // Text(
                          //   subCategoryList[index].docId!,
                          //   style: Theme.of(context).textTheme.bodyMedium,
                          // ),
                        ],
                      ),
                      onTap: () {
                        onTap(subCategoryList[index].docId,
                            subCategoryList[index].subCategoryName);
                      },
                    );
                  }),
            );
          },
          error: (_, __) => const SizedBox(),
          loading: () => const SizedBox());
    },
  );
}

Widget _horizontalListAndFilter(
    {required BuildContext context,
    required Function onTapElement,
    required Function onDoubleTapElement,
    required Function popupItemPressed,
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
        padding: const EdgeInsets.only(top: 0.0),
        child: Flex(
          direction: Axis.vertical,
          children: [
            CircleHorizontalList(
              cHorizontalListModel: circleHorizontalList,
              onTapElement: (elementId, elementName) =>
                  onTapElement(elementId, elementName),
              onDoubleTapElement: (elementId, elementName) =>
                  onDoubleTapElement(elementId, elementName),
              onTapPopUpMenu:
                  (int index, String categoryId, String categoryName) =>
                      popupItemPressed(index, categoryId, categoryName),
            ),
            const SizedBox(
              height: 5.0,
            ),
          ],
        ),
      );
    },
  );
}
