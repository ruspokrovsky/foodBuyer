
import 'package:firebase_database/firebase_database.dart';

class RealTimeServices {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  //метод для хеширования данных
  void enablePersistence() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }



  void writeArrayData() {
    List<String> myArray = ['apple', 'banana', 'orange', 'grape'];

    databaseReference.child('myArray').set(myArray).then((_) {
      print('Массив данных успешно записан в базу данных');
    }).catchError((error) {
      print('Ошибка при записи массива данных: $error');
    });
  }


  Stream<DatabaseEvent> getUnitedData({required String rootId,}){

    return databaseReference.child('unitedData').child(rootId).once().asStream();

  }



  Future<TransactionResult?> updateValueTransaction({
    required String rootId,
    required String positionId,
    required List<num> unitedQtyList,
}) async {
    DatabaseReference positionUnitedRef
    = databaseReference.child('unitedData').child(rootId).child(positionId);

    return await positionUnitedRef.runTransaction((transaction) {

        positionUnitedRef.set(unitedQtyList);
        return Transaction.success(transaction);

    }).then((result) {
      return result;
    }).catchError((error) {
       print('Ошибка при выполнении транзакции: $error');
       throw error;
    });
  }


  Future<TransactionResult?> updateValueTransaction2({
    required String rootId,
    required String positionId,
    required List<num> unitedQtyList,
  }) async {
    DatabaseReference positionUnitedRef
    = databaseReference.child('unitedData').child(rootId).child(positionId);

    try{
      positionUnitedRef.set(unitedQtyList);
    }
    catch(e){
      print(e);
    }
  }
}
