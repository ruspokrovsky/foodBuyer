import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';

class CachedNetworkImg extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CachedNetworkImg({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return imageUrl.isNotEmpty
        ?

    // FutureBuilder<File>(
    //         future: DefaultCacheManager().getSingleFile(imageUrl),
    //         builder: (context, snapshot) {
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return const ProgressMini();
    //           } else if (snapshot.hasError) {
    //             return Center(child: Text('Error: ${snapshot.error}'));
    //           } else {
    //             if (snapshot.data != null) {
    //               // Файл найден в кэше, используем Image.file()
    //               return SizedBox(
    //                 width: height,
    //                 height: height,
    //                 child: Image.file(
    //                   snapshot.data!,
    //                   fit: BoxFit.cover, // Режим заполнения изображения
    //                 ),
    //               );
    //             } else {
    //               // Файл не найден в кэше, используем CachedNetworkImage
    //               return CachedNetworkImage(
    //                 imageUrl: imageUrl,
    //                 progressIndicatorBuilder:
    //                     (context, url, downloadProgress) =>
    //                         const ProgressMini(),
    //                 // placeholder: (context, url) =>
    //                 //     SvgPicture.asset('assets/icons/1.svg'),
    //                 errorWidget: (context, url, error) => const Icon(
    //                   Icons.error,
    //                   color: Colors.redAccent,
    //                 ),
    //                 fit: fit,
    //                 height: height,
    //                 width: width,
    //               );
    //             }
    //           }
    //         },
    //       )
    //     : Center(
    //         child: SizedBox(
    //           width: height,
    //           height: height,
    //           child: SvgPicture.asset(
    //             'assets/icons/povar.svg',
    //           ),
    //         ),
    //       );


      CachedNetworkImage(
      imageUrl: imageUrl,
      progressIndicatorBuilder:
          (context, url, downloadProgress) =>
      const ProgressMini(),
      // placeholder: (context, url) =>
      //     SvgPicture.asset('assets/icons/1.svg'),
      errorWidget: (context, url, error) => const Icon(
        Icons.error,
        color: Colors.redAccent,
      ),
      fit: fit,
      height: height,
      width: width,
    )
    :
      Center(
        child: SizedBox(
          width: height,
          height: height,
          //child: SvgPicture.asset('assets/icons/logo.svg',),
          child: Image.asset('assets/icons/logo.png',),
        ),
      );//SvgPicture.asset('assets/icons/1.svg');
  }
}

//'https://firebasestorage.googleapis.com/v0/b/yabazaar-68e33.appspot.com/o/%D0%B0%D1%81%D0%BE%D1%80%D1%82%D0%B8%D0%BC%D0%B5%D0%BD%D1%82-%D0%BD%D0%B0%D0%BF%D0%B8%D1%82%D0%BA%D0%BE%D0%B2.jpg?alt=media&token=6ca62d47-a2f8-43f4-95e9-4b39c5c87b59'
