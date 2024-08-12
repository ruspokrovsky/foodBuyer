import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/registration/user_controllers/user_controller.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

final currentUserProvider = StateNotifierProvider<CurrentUserController,UserModel>(
        (_) => CurrentUserController(),
    name: "currentUserProvider");