import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/predicted_places.dart';
import 'package:ya_bazaar/res/places/place_controllers/place_controller.dart';
import 'package:ya_bazaar/res/places/place_controllers/places_arguments_controller.dart';
import 'package:ya_bazaar/res/places/place_controllers/places_controller.dart';
import 'package:ya_bazaar/res/places/place_services/place_fb_services.dart';

final getPlaceByUserIdProvider = StreamProvider.family<QuerySnapshot,String>(
        (ref,userId) => PlaceFBServices().getPlaceByUserId2(userId),
    name: 'getPlaceByUserIdProvider');

final getPlaceArgumentsProvider = StreamProvider.family<Map<String, List<String>>,PlaceParametersForRoot>(
        (ref,arguments) => PlaceFBServices().getPlaceArguments(args: arguments),
    name: 'getPlaceArgumentsProvider');

final placesArgumentsProvider = StateNotifierProvider<PlacesArgumentsController,Map<String, List<String>>>(
        (_) => PlacesArgumentsController(),
    name: "placesArgumentsProvider");

final getPlacesForRootProvider = StreamProvider.family<List<DocumentSnapshot>,Map<String, List<String>>>(
        (ref,arguments) => PlaceFBServices().fetchMultiplePlaceForRootStream(collectionData: arguments),
    name: 'getPlacesForRootProvider');

final getOrdersForPlacesProvider = StreamProvider.family<List<DocumentSnapshot>, Tuple2>(
        (ref, arguments) => PlaceFBServices().fetchMultipleOrdersForRootStream(arguments: arguments),
    name: 'getOrdersForPlacesProvider');

final getOrdersForPlacesProvider2 = StreamProvider.family<List<DocumentSnapshot>, Tuple2>(
        (ref, arguments) => PlaceFBServices().fetchDataForRootStream(arguments: arguments),
    name: 'getOrdersForPlacesProvider2');







final getAllPlacesProvider = StreamProvider<QuerySnapshot>(
        (_) => PlaceFBServices().getAllPlaces(),
    name: 'getAllPlacesProvider');

final placesListProvider = StateNotifierProvider<PlacesListController,List<PlaceModel>>(
        (_) => PlacesListController(),
    name: "placesListProvider");

final currentPlaceProvider = StateNotifierProvider<PlaceController,PlaceModel>(
        (_) => PlaceController(),
    name: "currentPlaceProvider");

final placesPredictedListProvider = StateProvider<List<PredictedPlaces>>(
        (_) => [],
    name: "placesPredictedListProvider");

final placesPredictedControllerProvider = StateProvider<TextEditingController>(
        (_) => TextEditingController(),
    name: "placesPredictedControllerProvider");

final joinPlacesProvider = FutureProvider.family<List<dynamic>, List<dynamic>>(
        (_, args) => PlaceFBServices().fetchMultiplePlaces(customersIdList: args),
    name: 'joinPlacesProvider');


final joinPlacesProvider2 = FutureProvider.family<Map<dynamic,dynamic>, PlaceParametersForRoot>(
        (_, argsMap) => PlaceFBServices().fetchMultiplePlacesqw(args: argsMap),
    name: 'joinPlacesProvider2');

final joinPlacesProvider342 = FutureProvider.family<List<DocumentSnapshot>, Map<String, List<String>>>(
        (_, argsMap) => PlaceFBServices().fetchMultiplePlace(collectionData: argsMap),
    name: 'joinPlacesProvider342');


final combinedDataProvider = Provider.family<CombinedData, Tuple2>(
        (ref, args) {
  return fetchDataForRootStream(arguments: args);
});





