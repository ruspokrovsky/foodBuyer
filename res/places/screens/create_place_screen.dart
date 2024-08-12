import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ya_bazaar/assistants/request_assistant.dart';
import 'package:ya_bazaar/global/map_key.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/registration_services/registration_services.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/map/map_providers/map_providers.dart';
import 'package:ya_bazaar/res/models/directions.dart';
import 'package:ya_bazaar/res/models/multiple_cart_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/predicted_places.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/places/place_providers/place_providers.dart';
import 'package:ya_bazaar/res/places/place_services/place_fb_services.dart';
import 'package:ya_bazaar/res/places/widgets/create_place_form.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/maps_search_widget.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/three_buttons_block.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/res/widgets/update_single_images_block.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/theme.dart';

class CreatePlaceScreen extends ConsumerStatefulWidget {
  static const String routeName = 'createPlaceScreen';

  final IntentArguments arguments;

  const CreatePlaceScreen({
    super.key,
    required this.arguments,
  });

  @override
  CreatePlaceScreenState createState() => CreatePlaceScreenState();
}

class CreatePlaceScreenState extends ConsumerState<CreatePlaceScreen> {
  late PlaceFBServices dbs = PlaceFBServices();

  //FocusNode focusNode = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController addressDescriptionController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String query = '';
  String? currentUserId;
  String? currentRootId;
  String? fromWhichScreen;
  PlaceModel? currentPlaceData;
  String? imageNetwork;
  UserModel? currentUserData;

  List<PredictedPlaces> placesPredictedList = [];

  @override
  void initState() {
    currentUserData = widget.arguments.userModel;
    currentPlaceData = widget.arguments.placeModel;
    currentRootId = widget.arguments.currentRootId;
    fromWhichScreen = widget.arguments.fromWhichScreen;

    if(currentUserData != null){
      currentUserId = currentUserData!.uId;
    }

    if (currentPlaceData != null) {
      nameController.text = currentPlaceData!.placeName;
      addressController.text = currentPlaceData!.addressDescription;
      addressDescriptionController.text = currentPlaceData!.addressDescription;
      descriptionController.text = currentPlaceData!.description;
      imageNetwork = currentPlaceData!.placeImage;
    }


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  child: CachedNetworkImg(
                      imageUrl: ref.watch(currentUserProvider).profilePhoto,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Expanded(
                    child: Text(
                  ref.watch(currentUserProvider).name,
                  style: styles.appBarTitleTextStyle,
                )),
              ],
            ),
          ),
          body: WillPopScope(
            onWillPop: () {
              // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              //     HomeScreen(currentUserId: widget.currentUserId),), (Route<dynamic> route) => false);
              return Future.value(true);
            },
            child: SingleChildScrollView(
              //controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      ref.watch(strCenterPositionProvider),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    buildSearch(categoryPressed: () {}, onTapCart: () {}),
                    CreatePlaceForm(
                      carouselSlider: UpdateSingleImagesBlock(
                          pickImageFromCamera: () {
                            Utils().pickFromCameraImage().then((img) => {
                                  ref
                                      .read(pickImageFileProvider.notifier)
                                      .updateImageFile(File(img.path)),
                                });
                          },
                          selectImageFromGallery: () {
                            Utils().pickFromGalleryImage().then((img) => {
                                  ref
                                      .read(pickImageFileProvider.notifier)
                                      .updateImageFile(File(img.path)),
                                });
                          },
                          deleteFileImg: () {
                            ref.read(pickImageFileProvider.notifier).clean();
                          },
                          imageFile: ref.watch(pickImageFileProvider),
                          imageNetwork: imageNetwork ?? ''),
                      nameController: nameController,
                      descriptionController: descriptionController,
                      addressController: addressDescriptionController,
                      locationImage: ref.watch(mapScreenshotProvider),
                      networkLocationImg: '',
                      onTapGoogleMapsItem: () => Navigation()
                          .navigateToMapScreen(context: context, args: {}),
                      borderRadius: 0.0,
                      //onChanged: findPlaceAutoCompleteSearch,

                      //     (v){
                      //
                      //   if(v.isEmpty){
                      //     ref.read(placesPredictedListProvider.notifier).state = [];
                      //     //isAutofocus = false;
                      //   }
                      //
                      //   findPlaceAutoCompleteSearch(v);
                      //   //isAutofocus = true;
                      //
                      //   // _scrollController.animateTo(
                      //   //   _scrollController.position.maxScrollExtent,
                      //   //   duration: const Duration(milliseconds: 500),
                      //   //   curve: Curves.ease,
                      //   // );
                      // },

                      placesPredictedList: ref.watch(placesPredictedListProvider),
                      onTapAddressItem: (geoPointId) {
                        _getPlaceDirectionDetails(geoPointId, context);
                      },
                      bottomButton: (currentPlaceData != null)
                          ? ThreeButtonsBlock(
                        positiveText: 'Изменить',
                        positiveClick: () async {
                          ref.read(progressBoolProvider.notifier)
                              .updateProgressBool(true);

                          if(fromWhichScreen == 'ownerSearchScreen'){
                            currentUserData!.subjectName = nameController.text.trim();
                            currentUserData!.subjectLatLng = [
                              ref.watch(centerPositionProvider).latitude,
                              ref.watch(centerPositionProvider).longitude
                            ];
                            await Registration().updateSubject(userModel: currentUserData!, imageFile: ref.watch(pickImageFileProvider),)
                                .whenComplete(() {
                              ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                            }).whenComplete(() => Navigator.pop(context));

                          }
                          else {
                            await dbs.updatePlace(
                              placeModel: PlaceModel(
                                docId: currentPlaceData!.docId,
                                userId: currentPlaceData!.userId,
                                placeName: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                locationLatLng: [
                                  ref.watch(centerPositionProvider).latitude,
                                  ref.watch(centerPositionProvider).longitude
                                ],
                                placeImage: currentPlaceData!.placeImage,
                                locationImage: currentPlaceData!.locationImage,
                                addedAt: currentPlaceData!.addedAt,
                                placeDiscount: currentPlaceData!.placeDiscount,
                                successStatus: currentPlaceData!.successStatus,
                                addressDescription:
                                addressDescriptionController.text.trim(),
                              ),
                              placeImageFile: ref.watch(pickImageFileProvider),
                              locationImageFile: ref.watch(mapScreenshotProvider),
                            ).then((value) {
                              ref.read(progressBoolProvider.notifier)
                                  .updateProgressBool(false);
                            }).then((value) => Navigator.pop(context));

                          }



                        },
                        neutralText: 'Удалить',
                        neutralClick: () async {
                          //удаление адреса требует более подробного обдумывания т.к. за адресом имеются закзы
                          // ref.read(progressBoolProvider.notifier)
                          //     .updateProgressBool(true);
                          // await dbs.deletePlace(
                          //   userId: currentPlaceData!.userId,
                          //   placeId: currentPlaceData!.docId,
                          //   imageUrl: currentPlaceData!.placeImage,
                          //   locationImageUrl: currentPlaceData!.locationImage,
                          // ).whenComplete(() {
                          //   ref.read(progressBoolProvider.notifier)
                          //       .updateProgressBool(false);
                          // }).whenComplete(() => Navigator.pop(context));
                        },
                        negativeText: 'Отменить',
                        negativeClick: () => Navigator.pop(context),
                      )
                          : TwoButtonsBlock(
                        positiveText: 'Сохранить',
                        positiveClick: () async {
                          ref.read(progressBoolProvider.notifier)
                              .updateProgressBool(true);

                          await dbs.addPlace(
                            placeModel: PlaceModel(
                              userId: currentUserId!,
                              placeName: nameController.text.trim(),
                              description: '',
                              locationLatLng: [
                                ref.watch(centerPositionProvider).latitude,
                                ref.watch(centerPositionProvider).longitude
                              ],
                              placeImage: '',
                              locationImage: '',
                              addedAt: 0,
                              placeDiscount: 0,
                              successStatus: 0,
                              addressDescription:
                              addressDescriptionController.text.trim(),
                            ),
                            placeImageFile: ref.watch(pickImageFileProvider),
                            locationImageFile: ref.watch(mapScreenshotProvider),
                          )
                              .then((placeId) async {
                            PlaceModel place = PlaceModel.empty();
                            place.placeName = nameController.text.trim();
                            place.docId = placeId;

                            if (fromWhichScreen == 'cartScreen') {
                              await ref
                                  .read(multipleCartListProvider.notifier)
                                  .setCustomer(MultipleCartModel(
                                  projectRootId: currentRootId!,
                                  projectRootName: '',
                                  currentCartList: [],
                                  customerId: place.docId!,
                                  customerName: place.placeName))
                                  .then((value) async {
                                ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                              }).then((value) {
                                //фиксируем выбранный объект для сравнения с объектом в корзине при добавлении позиции
                                ref.read(currentPlaceProvider.notifier).createPlace(place);
                              }).then((value) => Navigator.pop(context,));
                            }
                            else {
                              ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                              Navigator.pop(context);
                            }
                          });
                        },
                        negativeText: 'Отменить',
                        negativeClick: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (ref.watch(progressBoolProvider)) const ProgressDialog(),
      ],
    );
  }

  Widget buildSearch({
    required VoidCallback categoryPressed,
    required VoidCallback onTapCart,
  }) =>
      MapsSearchWidget(
        text: query,
        hintText: 'уточните адрес доставки...',
        onChanged: findPlaceAutoCompleteSearch,
        categoryPressed: categoryPressed,
        onTapBack: () => Navigator.pop(context),
        onTapCart: onTapCart,
        isAvatarGlow: false,
      );

  void findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.isNotEmpty) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:KGZ";

      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch ==
          "Error Occurred, Failed. No Response.") {
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        List placePredictions = responseAutoCompleteSearch["predictions"];

        print('---------------------------placePredictions');
        print(responseAutoCompleteSearch);

        var placePredictionsList = (placePredictions)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();
        placesPredictedList = placePredictionsList;

        ref.read(placesPredictedListProvider.notifier).state =
            placesPredictedList;

        // setState(() {
        //   //Прогнозируемый список
        //   placesPredictedList = placePredictionsList;
        // });
      }
    } else {
      ref.read(placesPredictedListProvider.notifier).state = [];
    }
  }

  _getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => const ProgressDialog(),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    //print(responseApi);

    Navigator.pop(context);

    if (responseApi == "Error Occurred, Failed. No Response.") {
      return;
    }

    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      ref.read(centerPositionProvider.notifier).state = LatLng(
          responseApi["result"]["geometry"]["location"]["lat"],
          responseApi["result"]["geometry"]["location"]["lng"]);

      // setState(() {
      //   //userDropOffAddress = directions.locationName!;
      //
      //   print(directions.locationName!);
      // });

      //Navigator.pop(context, directions);
    }
  }
}
