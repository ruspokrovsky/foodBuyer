
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/assistants/request_assistant.dart';
import 'package:ya_bazaar/global/map_key.dart';
import 'package:ya_bazaar/res/models/directions.dart';
import 'package:ya_bazaar/res/models/predicted_places.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/google_map_button.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/theme.dart';

class CreatePlaceForm extends ConsumerWidget {
  final signUpFormKey = GlobalKey<FormState>();
  final TextEditingController nameController;
  final TextEditingController? addressController;
  final TextEditingController descriptionController;
  final bool? isInfoActive;
  final Widget carouselSlider;
  final Widget bottomButton;

  final VoidCallback onTapGoogleMapsItem;
  final File locationImage;
  final String networkLocationImg;
  final double borderRadius;
  final ValueChanged<String>? onChanged;
  final List<PredictedPlaces> placesPredictedList;

  final Function onTapAddressItem;
  final FocusNode? focusNode;
  final bool? autofocus;
  final Function? onSubmitted;

  CreatePlaceForm({
    Key? key,
    required this.nameController,
    required this.descriptionController,
    required this.carouselSlider,
    required this.bottomButton,
    this.isInfoActive,

    required this.locationImage,
    required this.networkLocationImg,
    required this.onTapGoogleMapsItem,
    required this.borderRadius,
    this.onChanged,
    required this.placesPredictedList,
    this.addressController,
    this.focusNode,
    this.autofocus,
    this.onSubmitted,
    required this.onTapAddressItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
AppStyles styles = AppStyles.appStyle(context);
    return Form(
      key: signUpFormKey,
      child: Column(
        children: [

          //const Divider(),

          // TextField(
          //   controller: TextEditingController(),
          //   cursorColor: Theme.of(context).primaryColor,
          //   decoration: InputDecoration(
          //     icon: const Icon(Icons.location_on_outlined,color: Colors.grey,),
          //     hintText: "уточните адрес доставки...",
          //     helperStyle: Theme.of(context).textTheme.bodyMedium,
          //     fillColor: Colors.white54,
          //     filled: true,
          //     border: InputBorder.none,
          //   ),
          //   style: Theme.of(context).textTheme.bodyMedium,
          //   onChanged: onChanged!,
          // ),

          //const Divider(),
          SizedBox(
              height: placesPredictedList.length * 50,
              child: ListView.separated(
                itemCount: placesPredictedList.length,
                itemBuilder: (BuildContext context, int index){
                  return GestureDetector(
                    onTap: ()=> onTapAddressItem(placesPredictedList[index].placeId),
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      child: Text('${placesPredictedList[index].mainText.toString()} ${placesPredictedList[index].secondaryText.toString()}'),

                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },)),

          GoogleMapButton(
            locationImage: locationImage,
            onTapCreateLocation: onTapGoogleMapsItem,
            networkLocationImg: networkLocationImg,
            borderRadius: borderRadius,
          ),
          const Divider(),

          carouselSlider,
          const Divider(),


          TextField(
            controller: addressController,
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              //hintText: 'Наименование объекта,',
              //hintStyle: style,
              border: InputBorder.none,

              labelText: 'дом №, кв №, этаж, примечания... ',
              labelStyle: Theme.of(context).textTheme.labelLarge,
            ),
            style: Theme.of(context).textTheme.bodyMedium,

          ),
          const Divider(),
          TextField(
            controller: nameController,
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              //hintText: 'Наименование объекта,',
              //hintStyle: style,
              border: InputBorder.none,

              labelText: 'Наименование объекта',
              labelStyle: Theme.of(context).textTheme.labelLarge,
            ),
            style: Theme.of(context).textTheme.bodyMedium,

          ),
         const Divider(),
          bottomButton,
          const Divider(),
        ],
      ),
    );
  }




  validateForm() {
    // if(nameController.text.length < 3)
    // {
    //
    //   Get.snackbar("Ошибка", "Введите имя");
    // }
    // else if(!emailController.text.contains("@"))
    // {
    //   Get.snackbar("Ошибка", "email");
    // }
    // else if(passwordController.text.isEmpty)
    // {
    //   Get.snackbar("Ошибка", "Введите пароль");
    // } else {
    //
    // }
  }
}

//nameController;
// emailController;
// passwordController
