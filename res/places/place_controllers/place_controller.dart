import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';

class PlaceController extends StateNotifier<PlaceModel> {
  PlaceController() : super(PlaceModel.empty());

  clearPlace() {
    state = PlaceModel.empty();
  }

  createPlace(PlaceModel placesData) {

    state =  placesData;

  }


}