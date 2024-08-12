import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';

class HeroContainer extends StatelessWidget {
  final String heroTag;
  final String imgPatch;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit boxFit;
  const HeroContainer({
    super.key,
    required this.heroTag,
    required this.imgPatch,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.boxFit,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child:  Material(
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            child: CachedNetworkImg(
                imageUrl: imgPatch,
                width: width,
                height: height,
                fit: boxFit),
          ),
        ),
      ),
    );
  }
}
