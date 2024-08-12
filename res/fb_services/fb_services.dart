import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class FbService {
  var firebaseStorage = FirebaseStorage.instance;
  var fireStore = FirebaseFirestore.instance;
  final Rx<File?> searchImageQuery = Rx(null);
  List downloadUrl = [];

  Future<String> uploadSingleImgToStorage(
      {required String dirName1, required String fileName, required File imageFile}) async {
    Reference ref;
    String fileNm;
    if(fileName.isNotEmpty){
      fileNm = fileName;
    }
    else {
      fileNm = imageFile.path.split('/').last;
    }

    ref = firebaseStorage.ref().child(dirName1).child(fileNm);

    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadSingleImg(
      {required String dirName1, required String fileName, required File imageFile}) async {
    Reference ref;

    ref = firebaseStorage.ref().child(dirName1).child(fileName);

    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteSingleImgFromStorage(String imagesPath) async {
    try {
      await firebaseStorage.refFromURL(imagesPath).delete();
    } catch (e) {
      print("deleteSingleImgFromStorage-------exception");
      print(e);
    }
  }
}
