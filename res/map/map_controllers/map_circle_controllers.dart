
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateCircleController extends StateNotifier<Set<Circle>> {
  CreateCircleController() : super(<Circle>{});

  circlesSet(context,LatLng newObjectLatLng) async {
    print('------newObjectLatLng-------------$newObjectLatLng');
    state = {
      Circle(
        circleId: const CircleId('1'),
        center: newObjectLatLng,
        radius: 180,
        strokeWidth: 1,
        strokeColor: Theme.of(context).primaryColor,
        fillColor: const Color.fromRGBO(114, 0, 202, 0.1),
      ),
      Circle(
        circleId: const CircleId('2'),
        center: newObjectLatLng,
        radius: 20,
        strokeWidth: 1,
        strokeColor: Theme.of(context).primaryColor,
        fillColor: const Color.fromRGBO(114, 0, 202, 0.1),
      )};
  }

  void clean()=> state = {};

}