import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/category_model.dart';

class CategoryController extends StateNotifier<List<CategoryModel>>{
  CategoryController(super.state);


  clearCategoryList(){
    state.clear();
  }

  buildCategory(categoryData){

    var categoryList = categoryData.docs.map((DocumentSnapshot docs) => CategoryModel.fromSnap(docs).toJson()).toList();

    for(var element in categoryList){
      state.add(CategoryModel(categoryName: element['categoryName'], categoryId: element['categoryId']));

    }

  }



}