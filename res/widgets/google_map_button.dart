import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/theme.dart';

class GoogleMapButton extends StatelessWidget {
  final LatLng? whoLocation;
  final VoidCallback onTapCreateLocation;
  final File locationImage;
  final String networkLocationImg;
  final double borderRadius;
  final double height;

  const GoogleMapButton({
    Key? key,
    required this.onTapCreateLocation,
    required this.locationImage,
    required this.networkLocationImg,
    required this.borderRadius,
    this.whoLocation,
    this.height = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: GestureDetector(
        onTap: onTapCreateLocation,
        child: Stack(
          children: [
            Positioned(
              right: 0.0,
              left: 0.0,
              top: 0.0,
              bottom: 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: locationImage.existsSync()
                    ? Image.file(
                  locationImage,
                  fit: BoxFit.cover,
                  //width: 60,
                )
                    : networkLocationImg.isNotEmpty
                    ? CachedNetworkImg(
                  imageUrl: networkLocationImg,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                )
                    : Image.asset(
                  'assets/images/anpsthemes-gmaps.jpg',
                  fit: BoxFit.cover,
                ),
              ),

            ),
            if(!locationImage.existsSync())
            Positioned(
                right: 0.0,
                left: 0.0,
                top: 0.0,
                bottom: 0.0,
                child: Container(
                  color: Colors.white70,
                  child: Center(
                    child: Text('Если нет нужного адреса в списке, определите позицию на карте...',
                      textAlign: TextAlign.center,
                      style: styles.worningTextStyle,),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
