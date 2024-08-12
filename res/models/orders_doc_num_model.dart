import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersDocNumberModel {
  String? docId;

  OrdersDocNumberModel({this.docId,});


  Map<String, dynamic> toJson() => {
        "docId": docId,
      };

  static OrdersDocNumberModel fromSnap(DocumentSnapshot snap) {

    var snapshot = snap.data() as Map;
    var docId = snap.id;

    print('snapshot');
    print(snapshot);

    return OrdersDocNumberModel(
      docId: docId,
    );
  }


}