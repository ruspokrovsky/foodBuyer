
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class UserController extends StateNotifier<UserModel> {
  UserController():super(UserModel.empty());




  buildUser(DocumentSnapshot userData,) {
    state = UserModel.snapFromDoc(userData);
  }



}