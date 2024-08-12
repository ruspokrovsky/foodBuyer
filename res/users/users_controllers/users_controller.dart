
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class UsersListController extends StateNotifier<List<UserModel>> {
  UsersListController(super.state);

  clearUsersList() {
    state.clear();
  }

  buildUsersList(data) {
    var usersData = data.docs
        .map((DocumentSnapshot docs) => UserModel.fromSnap(docs).toJson())
        .toList();

    for (var element in usersData) {
      state.add(UserModel(
        uId: element['uId'],
        rootId: element['rootId'],
        name: element['name'],
        email: element['email'],
        userRole: element['userRole'],
        password: element['password'],
        profilePhoto: element['profilePhoto'],
        userPhone: element['userPhone'],
        userStatus: element['userStatus'],
        addedAt: element['addedAt'],
        userRoles: element['userRoles'],
        subjectName: element['subjectName'],
        subjectLatLng: element['subjectLatLng'],
        subjectImg: element['subjectImg'],
        statusList: element['statusList'],
        isSelectedElement: false,
      ));
    }
  }

  UserModel getUserByRootId(String rootId){

    var qstate = state.where((element) => element.uId == rootId).toList();
    UserModel rootUserData = qstate[0];

    return rootUserData;

  }

  isSelectedUser(WidgetRef ref,){

    List<String> projectRootIdList = ref.read(multipleCartListProvider.notifier).projectRootIdList();

    for (var element in state) {

      if(projectRootIdList.contains(element.uId)){

        element.isSelectedElement = true;

      }else {

        element.isSelectedElement = false;
      }

    }

  }


  List<UserModel> unSubscribedUserList(List<dynamic> argumentsIdList,){

    List<UserModel> unSubscribedUsersList = [];

    for (var stateElem in state) {
      if(!argumentsIdList.contains(stateElem.uId)){
        unSubscribedUsersList.add(stateElem);

      }

    }

    return unSubscribedUsersList;
  }


}
