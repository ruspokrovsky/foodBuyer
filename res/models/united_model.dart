import 'package:cloud_firestore/cloud_firestore.dart';

class UnitedModel {
  String? docId;
  String rootId;
  String positionId;
  List<num> unitQtyList;

  UnitedModel({this.docId, required this.rootId, required this.positionId, required this.unitQtyList,});


  Map<String, dynamic> toJson() => {
        "docId": docId,
        "rootId": rootId,
        "positionId": positionId,
        "unitQtyList": unitQtyList,
      };

  Map<String, dynamic> toJsonForDb() => {
    "rootId": rootId,
    "positionId": positionId,
    "unitQtyList": unitQtyList,
  };

  static UnitedModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;
    return UnitedModel(
      docId: docId,
      rootId: snapshot['rootId'] ?? '',
      positionId: snapshot['positionId'] ?? '',
      unitQtyList: snapshot['unitQtyList'] ?? [],
    );
  }

  static UnitedModel empty() {
    return UnitedModel(rootId: '', positionId: '', unitQtyList: [],);
  }


}