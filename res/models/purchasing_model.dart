import 'package:cloud_firestore/cloud_firestore.dart';

class PurchasingModel {
  String? docId;
  String projectRootId;
  String buyerId;
  String buyerName;
  int selectedTime;
  num firsPrice;
  num actualPrice;
  num actualQty;
  String productName;
  String productId;
  String productMeasure;
  num orderQty;
  int purchasingStatus;

  num? receivedQuantity;
  int? receivedDate;

  String positionImgUrl;
  num? amount;
  bool? ndsStatus;


  PurchasingModel({
      this.docId,
      required this.projectRootId,
      required this.buyerId,
      required this.buyerName,
      required this.selectedTime,
      required this.firsPrice,
      required this.actualPrice,
      required this.actualQty,
      required this.productName,
      required this.productId,
      required this.productMeasure,
      required this.orderQty,
      required this.purchasingStatus,
      this.receivedQuantity,
      this.receivedDate,
      required this.positionImgUrl,
      this.amount,
      this.ndsStatus,

  });



  Map<String, dynamic> toJsonForDb() => {
    'projectRootId': projectRootId,
    'buyerId': buyerId,
    'buyerName': buyerName,
    'selectedTime': selectedTime,
    'firsPrice': firsPrice,
    'actualPrice': actualPrice,
    'actualQty': actualQty,
    'productName': productName,
    'productId': productId,
    'productMeasure': productMeasure,
    'orderQty': orderQty,
    'purchasingStatus': purchasingStatus,
    'receivedQuantity': receivedQuantity,
    'receivedDate': receivedDate,
    'positionImgUrl': positionImgUrl,
    'ndsStatus': ndsStatus,


  };

  Map<String, dynamic> toJson() => {
    'docId': docId,
    'projectRootId': projectRootId,
    'buyerId': buyerId,
    'buyerName': buyerName,
    'selectedTime': selectedTime,
    'firsPrice': firsPrice,
    'actualPrice': actualPrice,
    'actualQty': actualQty,
    'productName': productName,
    'productId': productId,
    'productMeasure': productMeasure,
    'orderQty': orderQty,
    'purchasingStatus': purchasingStatus,
    'receivedQuantity': receivedQuantity,
    'receivedDate': receivedDate,
    'positionImgUrl': positionImgUrl,
    'ndsStatus': ndsStatus,

      };

  static PurchasingModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;

    return PurchasingModel(
        docId: docId,
        projectRootId: snapshot['projectRootId'] ?? 'projectRootId',
        buyerId: snapshot['buyerId'] ?? 'buyerId',
        buyerName: snapshot['buyerName'] ?? 'buyerName',
        selectedTime: snapshot['selectedTime'] ?? 0,
        firsPrice: snapshot['firsPrice'] ?? 0,
        actualPrice: snapshot['actualPrice'] ?? 0,
        actualQty: snapshot['actualQty'] ?? 0,
        productName: snapshot['productName'] ?? 'productName',
        productId: snapshot['productId'] ?? 'productId',
        productMeasure: snapshot['productMeasure'] ?? 'productMeasure',
        orderQty: snapshot['orderQty'] ?? 0,
        purchasingStatus: snapshot['purchasingStatus'] ?? 0,
        receivedQuantity: snapshot['receivedQuantity'] ?? 0,
        receivedDate: snapshot['receivedDate'] ?? 0,
        positionImgUrl: snapshot['positionImgUrl'] ?? '',
        ndsStatus: snapshot['ndsStatus'] ?? false,


    );
  }

  static empty(){
    return PurchasingModel(
        projectRootId: '',
        buyerId: '',
        buyerName: '',
        selectedTime: 0,
        firsPrice: 0,
        actualPrice: 0,
        actualQty: 0,
        productName: '',
        productId: '',
        productMeasure: '',
        orderQty: 0,
        purchasingStatus: 0,
        positionImgUrl: '');
  }

}
