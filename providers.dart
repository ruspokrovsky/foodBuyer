import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/home/home_services/home_services.dart';

final booleanProvider = StateProvider<bool>(
  (_) => true,
  name: 'booleanProvider',
);


final getAllPositionByObjectIdProvider = StreamProvider.family<QuerySnapshot, String>(
        (ref, objectId) => HomeFBServices().getAllPositionByObjectId(objectId),
    name: 'getAllPositionByObjectIdProvider');

final getAllPositionProvider = StreamProvider((_) => HomeFBServices().getAllPosition(),
    name: 'getAllPositionProvider');