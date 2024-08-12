import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class IntentRootPlaceArgs{

  UserModel rootUserModel;
  PlaceModel placeModel;
  String? fromWhichScreen;


  IntentRootPlaceArgs({
    required this.rootUserModel,
    required this.placeModel,
    this.fromWhichScreen,
  });

  static empty(){
    return IntentRootPlaceArgs(
        rootUserModel: UserModel.empty(), placeModel: PlaceModel.empty());
  }
}

class IntentCurrentUserIdObjectIdProjectRootId{

  String? currentUserid;
  String projectRootId;
  PlaceModel? place;
  String placeId;


  IntentCurrentUserIdObjectIdProjectRootId({
    required this.projectRootId,
    this.place,
    required this.placeId,
    this.currentUserid,
  });
}

class IntentPlacePositionRootUserArgs{

  PlaceModel placeData;
  PositionModel positionData;
  UserModel projectRootUser;

  IntentPlacePositionRootUserArgs({
    required this.placeData,
    required this.positionData,
    required this.projectRootUser,
  });
}

class IntentCurrentUserIdFromWhichPage{

  String currentUserId;
  String fromWhichScreen;

  IntentCurrentUserIdFromWhichPage({
    required this.currentUserId,
    required this.fromWhichScreen,
  });
}

class IntentArguments{

  String? currentRootId;
  String? currentUserId;
  String? customerId;
  String? fromWhichScreen;
  Map<String, List<String>>? placeArguments;
  PlaceModel? placeModel;
  OrderDetailsModel? orderDetailsModel;
  UserModel? userModel;

  IntentArguments({
    this.currentRootId,
    this.currentUserId,
    this.customerId,
    this.fromWhichScreen,
    this.placeArguments,
    this.placeModel,
    this.orderDetailsModel,
    this.userModel,
  });

  static empty(){
    return IntentArguments(currentRootId: '', fromWhichScreen: '', placeModel: PlaceModel.empty());
  }
}

class PlaceParametersForRoot{

  String currentRootId;
  List<dynamic> customersIdList;

  PlaceParametersForRoot({
    required this.currentRootId,
    required this.customersIdList,
  });

  static empty(){
    return PlaceParametersForRoot(currentRootId: '', customersIdList: []);
  }
}


class ViewPositionParamModel{

List<dynamic> notSubscribersIdList;
List<UserModel> notSubscribersList;
List<PositionModel> viewPositionList;

ViewPositionParamModel({
  required this.notSubscribersIdList,
  required this.notSubscribersList,
  required this.viewPositionList,
});

}

class GetPositionArgs{

  String rootId;
  String positionId;

  GetPositionArgs({
    required this.rootId,
    required this.positionId,
  });

}

class SnapTextModel{

  String title;
  String data;
  String postTitle;

  SnapTextModel({
    required this.title,
    required this.data,
    required this.postTitle,
  });

}