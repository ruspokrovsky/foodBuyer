import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ya_bazaar/global/map_key.dart';
import 'package:ya_bazaar/res/map/map_providers/map_providers.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';

class MapScreen extends ConsumerStatefulWidget {
  static const String routeName = "mapScreen";

  final Map<dynamic, dynamic> args;

  const MapScreen({super.key, required this.args});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends ConsumerState<MapScreen> {
  //GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _completer = Completer();

  LocationPermission? _locationPermission;

  LocationData? currentLocation;

  Set<Polyline> polyLineSet = {};
  List<LatLng> pLineCoOrdinatesList = [];

  Uint8List? imageBytes;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }

    setState(() {});
  }

  @override
  void initState() {
    checkIfLocationPermissionAllowed();
    _locateUserPosition2();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    if (Platform.isAndroid) {
      print('--------------------------isAndroid');
      // код, предназначенный для Android
    } else if (Platform.isIOS) {
      print('------------------------------isIOS');
      // код, предназначенный для iOS
    }

    return Scaffold(
      body: Stack(
        children: [
          ref.watch(centerPositionProvider) == const LatLng(42.876161, 74.683561)
              ? const ProgressDialog()
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(target: ref.watch(centerPositionProvider), zoom: 14.5),
                  myLocationEnabled: true,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: true,
                  circles: ref.watch(addCircleProvider),
                  markers: {
                    Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: ref.watch(centerPositionProvider)),
                    // Marker(
                    //     markerId: const MarkerId('currentLocation2'),
                    //     position: widget.args['objecLatLng'])
                  },
                  polylines: {
                    Polyline(
                        polylineId: const PolylineId('qwerty'),
                        points: pLineCoOrdinatesList,
                        color: Colors.deepOrange,
                        width: 3)
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    _completer.complete(controller);

                    //newGoogleMapController = controller;


                    // await _locateUserPosition().then((LatLng latLng) async {
                    //
                    //   ref.read(centerPositionProvider.notifier).state = latLng;
                    //   setState(() {});
                    //
                    // });


                    // _polyLineFromOriginToDestination(
                    //     objecLatLng: widget.args['objecLatLng']);
                  },
                  onCameraMove: (CameraPosition position) {
                    //извлекаем координаты центра карты при скролинге
                    LatLng centerPosition = position.target;
                    //записываем координаты в провайдер
                    ref.read(centerPositionProvider.notifier).state =
                        centerPosition;
                  },
                  onTap: (position) {
                    ref.read(addCircleProvider.notifier).clean();
                    //ref.read(addCircleProvider.notifier).circlesSet(context, LatLng(position.latitude, position.longitude));
                  },
                ),
          _centerCircle(),
          Positioned(
            left: 8.0,
            right: 8.0,
            bottom: 30.0,
            child: TwoButtonsBlock(
              positiveClick: () async {

                if(widget.args['fromWhichScreen'] != 'rootPlacesScreen' && widget.args['fromWhichScreen'] != 'placesScreen'){

                String locationImageName = ref.watch(centerPositionProvider).latitude.toString();

                ref.read(addCircleProvider.notifier).circlesSet(context, ref.watch(centerPositionProvider));

                await _takeSnapShot(context, locationImageName).then((File imgSnap) async {
                if (imgSnap.existsSync()) {
                ref.read(mapScreenshotProvider.notifier).updateLocationScreenshot(imgSnap);
                }
                }).then((value) => Navigator.pop(context));

                }


              },
              negativeClick: () => Navigator.pop(context),
              positiveText: 'Готово',
              negativeText: 'Отменить',
            ),
          ),
          Positioned(
            top: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                RichSpanText(spanText: SnapTextModel(title: 'currentLocation: ', data: ref.watch(centerPositionProvider).toString(), postTitle: '')),
                RichSpanText(spanText: SnapTextModel(title: 'objectLocation: ', data: widget.args['objecLatLng'].toString(), postTitle: '')),
                RichSpanText(spanText: SnapTextModel(title: 'distanceText: ', data: widget.args['distanceText'].toString(), postTitle: '')),
                RichSpanText(spanText: SnapTextModel(title: 'durationText: ', data: widget.args['durationText'].toString(), postTitle: '')),
                RichSpanText(spanText: SnapTextModel(title: 'totalKGS: ', data: widget.args['totalKGS'].toString(), postTitle: '')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Future<LatLng> _locateUserPosition() async {
  //   Position userCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   CameraPosition cameraPosition = CameraPosition(target: LatLng(userCurrentPosition.latitude,userCurrentPosition.longitude), zoom: 14);
  //   newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  //   return LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude);
  // }

  void _locateUserPosition2() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;

      ref.read(centerPositionProvider.notifier).state = LatLng(location.latitude!, location.longitude!);
    });

    GoogleMapController controller = await _completer.future;

    // location.onLocationChanged.listen((newLoc) {
    //   currentLocation = newLoc;
    //   controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    //       target: ref.read(centerPositionProvider), zoom: 14.5)));
    //
    //   setState(() {});ß
    // });
  }


  Future<File> _takeSnapShot(context, locationImageName) async {
    Uint8List? imageBytes;
    File file = File('');
    GoogleMapController controller = await _completer.future;
    return await Future<File>.delayed(const Duration(milliseconds: 1000),
        () async {
      imageBytes = await controller.takeSnapshot();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/$locationImageName.png').create();
      file.writeAsBytesSync(imageBytes!);
      return file;
    });
  }

  Widget _centerCircle() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Icon(
            Icons.circle_outlined,
            color: Theme.of(context).primaryColor,
            size: 16.0,
          ),
        ),
      ),
    );
  }

  //нарисовать ломаную линию от начала до места назначения
  Future<void> _polyLineFromOriginToDestination({required objecLatLng,}) async {
    PolylinePoints polylinePoints = PolylinePoints();
    LatLng originPosition = ref.watch(centerPositionProvider);
    LatLng destinationPosition = objecLatLng;

    pLineCoOrdinatesList.clear();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapKey,
      PointLatLng(originPosition.latitude, originPosition.longitude),
      PointLatLng(destinationPosition.latitude, destinationPosition.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var pointLatLng in result.points) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    setState(() {});
  }
}
