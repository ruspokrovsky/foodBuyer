
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class CurrentUserController extends StateNotifier<UserModel> {
  CurrentUserController():super(UserModel.empty());




  buildCurrentUser(DocumentSnapshot userData,) {
    state = UserModel.snapFromDoc(userData);
  }

  whichUser({required String whichUser}){
    state.uId = whichUser;
  }

}