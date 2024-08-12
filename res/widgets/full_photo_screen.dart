import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoScreen extends StatelessWidget {
  static const routeName = 'fullPhotoScreen';
  final String url;

  const FullPhotoScreen({Key? key, required this.url}) : super(key: key);

  //var file =  DefaultCacheManager().getSingleFile(url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black
      ),
      body: FutureBuilder(
        future: DefaultCacheManager().getSingleFile(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              return PhotoView(
                imageProvider: FileImage(snapshot.data as dynamic),
                // используйте FileImage с вашим файлом в качестве imageProvider
                initialScale: PhotoViewComputedScale.contained,
                // установите начальный масштаб по желанию
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}