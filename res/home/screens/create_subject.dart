import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/registration/registration_services/registration_services.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/three_buttons_block.dart';
import 'package:ya_bazaar/res/widgets/update_single_images_block.dart';

class CreateSubjectScreen extends ConsumerStatefulWidget {
  static const String routeName = 'createSubjectScreen';

  final UserModel userModel;
  const CreateSubjectScreen({super.key, required this.userModel});

  @override
  CreateSubjectScreenState createState() => CreateSubjectScreenState();
}



class CreateSubjectScreenState extends ConsumerState<CreateSubjectScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  UserModel? userData;

  @override
  void initState() {
    userData = widget.userModel;
    nameController.text = userData!.subjectName!;
    phoneController.text = userData!.userPhone;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        onWillPop: (){return Future.value(true);},
        isAppBar: false,
        isBottomNav: false,
        isFloatingContainer: false,
        flexibleContainerChild: Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            icon: Platform.isIOS
            ?
            Icon(Icons.arrow_back_ios_new, color: Theme.of(context).primaryColor,)
            :
            Icon(Icons.arrow_back, color: Theme.of(context).primaryColor,),
            onPressed: () {
              Navigator.pop(context);
            },),
        ),
        flexibleSpaceBarTitle: const SizedBox.shrink(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                UpdateSingleImagesBlock(
                    pickImageFromCamera: () {
                      Utils().pickFromCameraImage().then((img) => {
                        ref.read(pickImageFileProvider.notifier)
                            .updateImageFile(File(img.path)),
                      });
                    },
                    selectImageFromGallery: () {
                      Utils().pickFromGalleryImage().then((img) => {
                        ref.read(pickImageFileProvider.notifier)
                            .updateImageFile(File(img.path)),
                      });
                    },
                    deleteFileImg: () {
                      ref.read(pickImageFileProvider.notifier).clean();
                    },
                    imageFile: ref.watch(pickImageFileProvider),
                    imageNetwork: userData!.profilePhoto ?? ''),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16.0,),
                      EditText(
                          controller: nameController,
                          labelText: 'Имя',
                          onChanged: (v) {},),
                      const SizedBox(height: 16.0,),
                      EditText(
                          controller: phoneController,
                          labelText: 'Телефон',
                          onChanged: (v) {},),
                      const SizedBox(height: 16.0,),
                    ],
                  ),
                ),
                ThreeButtonsBlock(
                    positiveText: 'Сохранить',
                    positiveClick: () async {

                      ref.read(progressBoolProvider.notifier).updateProgressBool(true);
                      userData!.name = nameController.text.trim();

                      await Registration().updateUserData(userModel: userData!, imageFile: ref.watch(pickImageFileProvider),)
                          .whenComplete(() {
                            ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                          }).whenComplete(() => Navigator.pop(context));

                    },
                    neutralText: 'Удалить',
                    neutralClick: (){},
                    negativeText: 'Отменить',
                    negativeClick: (){
                      Navigator.pop(context);
                    }),
              ],
            ),
          )
        ],
        isProgress: ref.watch(progressBoolProvider),
        expandedHeight: 0.0,
        flexContainerColor: Colors.transparent,

    );
  }
}
