
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/position_model.dart';

class SinglePositionController extends StateNotifier<PositionModel> {

  SinglePositionController():super(PositionModel.empty());




  buildSinglePosition(DocumentSnapshot positionData,) {
    state = PositionModel.snapFromDoc(positionData);

  }



}
