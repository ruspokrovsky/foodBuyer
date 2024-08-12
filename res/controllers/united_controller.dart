import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/united_model.dart';

class UnitedController extends StateNotifier<List<UnitedModel>> {
  UnitedController() : super([]);

  clearUnitedList() {
    state.clear();
  }

  buildUnitedList(DatabaseEvent eventData,String rootId) {

    Map<Object?, Object?> unitedEvent = eventData.snapshot.value as Map;

    unitedEvent.forEach((position, qtyList) {
      String positionId = position.toString();
      List<num> unitedQtyL = List<num>.from(qtyList as List<dynamic>);
        state.add(UnitedModel(
          rootId: rootId,
          positionId: positionId,
          unitQtyList: unitedQtyL,
        ));
    });
  }


}