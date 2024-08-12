import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ya_bazaar/res/models/accountability_model.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/employee_report_model.dart';
import 'package:ya_bazaar/res/models/expenses_model.dart';
import 'package:ya_bazaar/res/models/subscribers_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class UsersFBServices{

  //final firebaseStorage = FirebaseStorage.instans;
  final fireStore = FirebaseFirestore.instance;

  //----------REQUEST----------------------------------------------


  void addCategory({required CategoryModel categoryModel}) async {

    try {

      await fireStore.collection('category').add(categoryModel.toJson());

    } catch (e) {
      print('e----------$e');
    }
  }

  void addSubCategory({required SubCategoryModel subCategoryModel}) async {

    try {

      await fireStore.collection('subCategory').add(subCategoryModel.toJsonForDb());

    } catch (e) {
      print('e----------$e');
    }
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

  Stream<QuerySnapshot> getUsers(){
    return fireStore.collection('aProjectData').snapshots();
    //return fireStore.collection('usersN').snapshots();

  }

  Stream<QuerySnapshot> getRootUsers(String rootId){
    return fireStore.collection('aProjectData').where('rootId', isEqualTo: rootId).snapshots();

  }

  Stream<DocumentSnapshot> getUser(String userId){
    return fireStore.collection('aProjectData').doc(userId).snapshots();

  }


  Future<void> updateUserStatus({required String userId, required String userStatus}) async{


    try {

      DocumentReference docRef = fireStore.collection('aProjectData').doc(userId);

      await fireStore.runTransaction((transaction) async {

        transaction.update(docRef, {'userStatus': userStatus});

      });

      //await fireStore.collection('aProjectData').doc(userId).update({'userStatus': userStatus});

      //await fireStore.collection('usersN').doc(userId).update({'userStatus': userStatus});

    } catch (e) {
      print('e----------$e');
    }

  }

  Future<void> updateRootUserStatus({required String rootUserId, required List<dynamic> userRoles}) async{


    try {

      await fireStore.collection('aProjectData').doc(rootUserId).update({'userRoles': userRoles});

    } catch (e) {
      print('e----------$e');
    }

  }

  Future<void> addSubscribers({
    required SubscribersModel subscribersModel
  }) async {

    final DocumentReference subscribersCustomerRef
    = fireStore.collection("aProjectData").doc(subscribersModel.customerId).collection("subscribers").doc(subscribersModel.projectRootId);
    final DocumentReference subscribersRootRef
    = fireStore.collection("aProjectData").doc(subscribersModel.projectRootId).collection("subscribers").doc(subscribersModel.customerId);

    try{
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.set(subscribersCustomerRef, subscribersModel.toJson());
      });
      await fireStore.runTransaction((Transaction transaction) async {
        transaction.set(subscribersRootRef, subscribersModel.toJson());
      });

    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    }catch(e){
      print('e-addOrder------------$e');

    }
  }


  Future<void> updateUserRootId({required String currentUserId, required String scanData}) async{

    try {
      await fireStore.collection('aProjectData').doc(currentUserId).update({'rootId': scanData,'userStatus': 'owner',});

    } catch (e) {
      print('e--updateUserRootId---$e');
    }
  }

  Future<void> deleteRootUser({required String currentUserId,}) async{

    try {
      await fireStore.collection('aProjectData')
          .doc(currentUserId)
          .update({
        'rootId': currentUserId,
        'userStatus': 'customer',
        'userRoles': [],});

    } catch (e) {
      print('e--updateUserRootId---$e');
    }
  }


  Future<void> unSubscribers({required String currentUserId, required String subscribersUid}) async{

    DocumentReference customerDocRef = fireStore.collection('aProjectData').doc(currentUserId).collection('subscribers').doc(subscribersUid);
    DocumentReference rootDocRef = fireStore.collection('aProjectData').doc(subscribersUid).collection('subscribers').doc(currentUserId);
    try {

      await fireStore.runTransaction((transaction) async {

        transaction.delete(customerDocRef);
        transaction.delete(rootDocRef);

      });


    } catch (e) {
      print('e----------$e');
    }

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



  Future<void> addAccountability({required AccountabilityModel accountabilityModel}) async {
    String userId = accountabilityModel.userId;
    try {

      DocumentReference accountabilityDocRef = fireStore.collection('aProjectData').doc(userId).collection('accountability').doc();

      await fireStore.runTransaction((transaction) async {

        transaction.set(accountabilityDocRef,accountabilityModel.toJsonForDb());

        return accountabilityDocRef.id;

      });

    } catch (e) {
      print('e----------$e');
    }
  }

  Future<void> updateRefund({required AccountabilityModel accountabilityModel}) async{

    print('------------------------------');
    print(accountabilityModel.userId);
    print(accountabilityModel.docId);
    print('------------------------------');

    try {
      DocumentReference accountabilityDocRef
      = fireStore.collection('aProjectData')
          .doc(accountabilityModel.userId)
          .collection('accountability')
          .doc(accountabilityModel.docId);

      await fireStore.runTransaction((transaction) async {

        transaction.update(accountabilityDocRef,
            {'refundAmount':accountabilityModel.refundAmount,
              'accountabilityStatus': accountabilityModel.accountabilityStatus});

      });
    } catch (e) {
      print('e--updateRefund---$e');
    }
  }


  Future<void> updateAccountabilityStatus(
      {required AccountabilityModel accountabilityModel}) async{

    print('------------------------------');
    print(accountabilityModel.userId);
    print(accountabilityModel.docId);
    print(accountabilityModel.accountabilityStatus);
    print('------------------------------');

    try {
      DocumentReference accountabilityDocRef
      = fireStore.collection('aProjectData')
          .doc(accountabilityModel.userId)
          .collection('accountability')
          .doc(accountabilityModel.docId);

      await fireStore.runTransaction((transaction) async {

        transaction.update(accountabilityDocRef, {
          'amountSpent':accountabilityModel.amountSpent,
          'accountabilityStatus':accountabilityModel.accountabilityStatus,
        });

      });
    } catch (e) {
      print('e--updateRefund---$e');
    }
  }

  Stream<QuerySnapshot> getAccountabilityByUserId(String employeeId) {
    return fireStore.collection('aProjectData')
        .doc(employeeId).collection('accountability')
        .orderBy('addedAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getEmployeeReportByUserId(String employeeId) {
    return fireStore.collection('aProjectData')
        .doc(employeeId).collection('employeeReport')
        .orderBy('addedAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getEmployeeReporDetailsByUserId({
    required EmployeeReportModel employeeReportModel}) {

    Stream<QuerySnapshot<Map<String, dynamic>>>? querySnapshot;

    String employeeId = employeeReportModel.userId;
    String docId = employeeReportModel.docId!;

    print('-employeeId----------------------------$employeeId');
    print('-docId----------------------------$docId');

    try{
      querySnapshot =  fireStore.collection('aProjectData')
          .doc(employeeId).collection('employeeReport')
          .doc(docId).collection('expensesList').snapshots();
    }
    catch(e){
      print('getEmployeeReporDetailsByUserId-error:::$e');
    }

    return querySnapshot!;
  }

  Future<void> addEmployeeReport({required EmployeeReportModel employeeReportModel}) async {

    String userId = employeeReportModel.userId;
    String rootId = employeeReportModel.rootId;
    List<dynamic> purchasingIdList = employeeReportModel.purchasingIdList;
    List<ExpensesModel> expensesList = employeeReportModel.expensesList!;


    final CollectionReference purchasingCollRef = fireStore.collection("aProjectData").doc(rootId).collection("purchasing");
    final DocumentReference reportRef = fireStore.collection("aProjectData").doc(userId).collection("employeeReport").doc();
    final CollectionReference expensesRef = reportRef.collection('expensesList');

    try{

      await fireStore.runTransaction((Transaction transaction) async {
        for (ExpensesModel expensesData in expensesList) {
          final DocumentReference expensesDocRef = expensesRef.doc();
          transaction.set(expensesDocRef, expensesData.toJsonForDb());
        }
      });

      await fireStore.runTransaction((Transaction transaction) async {
        transaction.set(reportRef, employeeReportModel.toJsonForDb());
      });

      await fireStore.runTransaction((Transaction transaction) async {
        for (String purchasingId in purchasingIdList) {
          final DocumentReference purchasingDocRef = purchasingCollRef.doc(purchasingId);
          transaction.update(purchasingDocRef, {'purchasingStatus': 22});
        }
      });

    } on FirebaseException catch (e) {
      print('FirebaseException: $e');
    }catch(e){
      print('e-addOrder------------$e');

    }
  }


}