import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/theme.dart';

class UpdateSingleImagesBlock extends StatelessWidget {
  final VoidCallback pickImageFromCamera;
  final VoidCallback selectImageFromGallery;
  final VoidCallback deleteFileImg;
  final File imageFile;
  final String imageNetwork;

  const UpdateSingleImagesBlock({
    Key? key,
    required this.pickImageFromCamera,
    required this.selectImageFromGallery,
    required this.deleteFileImg,
    required this.imageFile,
    required this.imageNetwork,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(imageFile.existsSync())
        imgFileView(context,imageFile),
        if(imageNetwork.isNotEmpty && !imageFile.existsSync())
        networkImgView(context,imageNetwork,),
        if(imageNetwork.isEmpty && !imageFile.existsSync())
        iconView(context,styles),
          //infoView(context),
        navButton(context),
      ],
    );
  }

  Widget navButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if(imageFile.existsSync())
                IconButton(
                  onPressed: deleteFileImg,
                  icon: Icon(
                    Icons.delete_outlined,
                    color: Theme
                        .of(context)
                        .primaryColorDark,
                  ),
                ),
                IconButton(
                  onPressed: pickImageFromCamera,
                  icon: Icon(
                    Icons.add_a_photo,
                    size: 33.0,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: selectImageFromGallery,
                  icon: Icon(
                    Icons.folder_open,
                    size: 33.0,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imgFileView(BuildContext context,File imageFile) {
    return SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height / 3,
      child: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 3,
        ),
      ),
    );
  }

  Widget networkImgView(BuildContext context, String imageNetwork,) {
    return SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height / 3,
      child: Center(
        child: CachedNetworkImg(
          imageUrl: imageNetwork,
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 3,
          fit: BoxFit.cover,),
      ),
    );
  }

  Widget iconView(BuildContext context,styles) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          // const Center(
          //   child: Icon(Icons.image_outlined, size: 90.0,color: Colors.grey),
          // ),

          Positioned(
              right: 0.0,
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                color: Colors.white70,
                child: Center(
                  child: Text(
                    'Добавление фотографии объекта, может ускорить процесс доставки...',
                    textAlign: TextAlign.center,
                    style: styles.worningTextStyle,),
                ),
              )),
        ],
      ),
    );
  }

  Widget infoView(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 6,
      child: Container(

        width: MediaQuery.of(context).size.width,
        color: Colors.black12,
        child: const Center(
          child: Text(
              'Если Вы регестрируете точку общественного питания, '
                  'добавте фотографию, желательно Фасад здания с вывеской,'
                  ' для оптимизации доставки',
          textAlign: TextAlign.center,),
        ),
      ),
    );
  }


}