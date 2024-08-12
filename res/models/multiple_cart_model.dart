import 'package:ya_bazaar/res/models/order_model.dart';

class MultipleCartModel{

  String projectRootId;
  String projectRootName;
  String customerId;
  String customerName;
  List<OrderModel> currentCartList;


  MultipleCartModel({
    required this.projectRootId,
    required this.projectRootName,
    required this.currentCartList,
    required this.customerId,
    required this.customerName,
  });

  static empty(){
    return MultipleCartModel(
      projectRootId: '', currentCartList: [], customerId: '', projectRootName: '', customerName: '',
    );
  }
}

