import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pickImageFileProvider = StateNotifierProvider<PickImage,File>(
        (ref) => PickImage(),
name: 'pickImageFileProvider');

class PickImage extends StateNotifier<File>{
  PickImage({File? file}): super(File(''));

  void updateImageFile(File file){
    state = file;
  }

  void clean(){
    state = File('');
  }

}
//-----------------------------------------------------------------
final progressBoolProvider = StateNotifierProvider<ProgressBool,bool>(
        (ref) => ProgressBool(),
    name: 'progressBoolProvider');

class ProgressBool extends StateNotifier<bool>{
  ProgressBool({bool? progBool}): super(false);

  void updateProgressBool(bool progBool){
    state = progBool;
  }

}
//-----------------------------------------------------------------
