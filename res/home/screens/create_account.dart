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

class CreateAccountScreen extends ConsumerStatefulWidget {
  static const String routeName = 'createAccount';

  final UserModel userModel;
  const CreateAccountScreen({super.key, required this.userModel});

  @override
  CreateAccountScreenState createState() => CreateAccountScreenState();
}



class CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  UserModel? userData;

  @override
  void initState() {
    userData = widget.userModel;
    nameController.text = userData!.name;
    phoneController.text = userData!.userPhone;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        onWillPop: (){
          return Future.value(true);
        },
        isAppBar: true,
        appBarTitle: 'Редактировать' ,
        avatarUrl: '',
        isBottomNav: false,
        isFloatingContainer: false,
        flexibleContainerChild: const SizedBox.shrink(),
        flexibleSpaceBarTitle: const SizedBox.shrink(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                  Column(
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
            ),
          )
        ],
        isProgress: ref.watch(progressBoolProvider),
        expandedHeight: 0.0,
        isPinned: false,
        flexContainerColor: Colors.transparent,
        radiusCircular: 0.0,

    );
  }
}
