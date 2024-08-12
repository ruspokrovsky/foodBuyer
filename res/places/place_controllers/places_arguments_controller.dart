import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';

class PlacesArgumentsController extends StateNotifier<Map<String, List<String>>> {
  PlacesArgumentsController() : super({});

  clearPlacesList() {
    state.clear();
  }

  buildPlacesArguments(Map<String, List<String>> placesArgs,) {
    state.addAll(placesArgs);
  }

}