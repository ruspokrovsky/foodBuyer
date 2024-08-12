import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ya_bazaar/res/map/map_controllers/map_circle_controllers.dart';
//-----------------------------------------------------------------------------------------
final lastCameraTargetProvider = StateNotifierProvider<LastCameraTarget, LatLng>(
        (_) => LastCameraTarget(),
    name: "lastCameraTargetProvider");

class LastCameraTarget extends StateNotifier<LatLng> {
  LastCameraTarget({LatLng? latLng}) : super(latLng ?? const LatLng(42.876161, 74.683561));

  void updateLocation(LatLng latLng) => state = latLng;

  void clean() => state = const LatLng(42.876161, 74.683561);
}

//-----------------------------------------------------------------------------------------

final cameraPositionProvider = StateNotifierProvider(
        (_) => CameraPositionController(),
    name: "cameraPositionProvider");

class CameraPositionController extends StateNotifier<CameraPosition> {

  CameraPositionController() : super(const CameraPosition(target: LatLng(42.876161, 74.683561), zoom: 14.4746));


  cameraPosition(position){
    state = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 14.4746);
  }

}
//-----------------------------------------------------------------------------------------

final mapScreenshotProvider = StateNotifierProvider<LocationScreenshot,File>(
        (_) => LocationScreenshot(),
    name: "mapScreenshotProvider");

class LocationScreenshot extends StateNotifier<File> {
  LocationScreenshot({File? locationScreenshot}) : super(locationScreenshot ?? File(''));

  void updateLocationScreenshot(File locationScreenshot) => state = locationScreenshot;

  void clean() => state = File('');
}
//-----------------------------------------------------------------------------------------


final addCircleProvider = StateNotifierProvider<CreateCircleController, Set<Circle>>(
        (_) => CreateCircleController(),
    name: "addCircleProvider");


final centerPositionProvider = StateProvider<LatLng>(
        (_) => const LatLng(42.876161, 74.683561),
    name: "addCirclePositionProvider");

final strCenterPositionProvider = StateProvider<String>(
        (_) => "search...",
    name: "strCenterPositionProvider");
