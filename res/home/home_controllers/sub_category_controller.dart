import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/category_model.dart';

class SubCategoryListController extends StateNotifier<List<SubCategoryModel>> {
  SubCategoryListController() : super([]);

  clearSubCategoryList() {
    state.clear();
  }

  buildSubCategoryList(subCategoryData) {
    var data = subCategoryData.docs.map((DocumentSnapshot doc) => SubCategoryModel.fromSnap(doc).toJson()).toList();
    for (var element in data) {

      state.add(SubCategoryModel(
          docId: element['docId'],
          categoryId: element['categoryId'],
          subCategoryName: element['subCategoryName'],
          )
      );
    }
  }
}