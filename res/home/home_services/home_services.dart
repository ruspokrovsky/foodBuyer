import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/category_model.dart';

class HomeFBServices{

  //final firebaseStorage = FirebaseStorage.instans;
  final fireStore = FirebaseFirestore.instance;

  //----------REQUEST----------------------------------------------


  Future<void> addCategory({required CategoryModel categoryModel}) async {

    try {

      await fireStore.collection('category').add(categoryModel.toJson());

    } catch (e) {
      print('e----------$e');
    }
  }

  Future<void>  addSubCategory({required SubCategoryModel subCategoryModel}) async {

    try {

      await fireStore.collection('subCategory').add(subCategoryModel.toJsonForDb());

    } catch (e) {
      print('e----------$e');
    }
  }


  void testingGet() async {

    var ddd = fireStore.collection("newTestOrders").doc("objectId").collection('order#1');
    var ddd1 = ddd.doc('aXLrDdCxDMwZMVEZZiZQ').collection('orderList').snapshots();
    var ddd2 = ddd.doc('aXLrDdCxDMwZMVEZZiZQ').snapshots();





    ddd2.forEach((element) {
      print(element.data());
    });

    ddd1.forEach((element) {
      print(element.docs.map((e) => e['productName']));
    });


    }




  void testingAdd() async {

    List testPositionList = [
      {'productName': "productName", 'measure': "we"},
      {'productName': "productName1", 'measure': "we1"},
      {'productName': "productName2", 'measure': "we2"}];

    try {
      // Cоздаем корневую ссылку
       var orderDetails = fireStore.collection("newTestOrders").doc("objectId");

       var orderListDetails = orderDetails.collection("order#1").doc();

       await orderListDetails.set({
         'invoice': "666",
         'total': "777",
         'date': "31.05.22",
       });

       var orderList = orderListDetails.collection("orderList");


       for (var element in testPositionList) {

         print(element["productName"]);

         await orderList.add({
           'productName': element["productName"],
           'measure': element["measure"],
         });

       }

    } catch (e) {
      print('e----------$e');
    }
  }

  void testingUpdate(List<AllPositionModel> allPositionList) async {
    try {

      for (var element in allPositionList) {

        //fireStore.collection('product').doc(element.docId).update({'productImage':''});
      }

    } catch (e) {
      print('e----------$e');
    }
  }

//----------RESPONSE----------------------------------------------

  Stream<QuerySnapshot> getCategory(){
    return fireStore.collection('category').snapshots();
  }

  Stream<QuerySnapshot> getSubCategory(String categoryId){
    return fireStore.collection('subCategory')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots();
  }


  Stream<QuerySnapshot> getAllPosition() {
    return fireStore.collection('product').snapshots();
  }


  Stream<QuerySnapshot> getAllPositionByObjectId(String objectId) {
    return fireStore.collection('product').snapshots();
  }

}