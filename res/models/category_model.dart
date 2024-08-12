import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String? categoryId;
  String categoryName;

  CategoryModel({this.categoryId, required this.categoryName});


  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "categoryName": categoryName,
      };

  static CategoryModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;

    return CategoryModel(
      categoryId: docId,
      categoryName: snapshot['categoryName'] ?? 'categoryName',
    );
  }

  static CategoryModel empty() {
    return CategoryModel(categoryName: '');
  }
}

class SubCategoryModel {
  String? docId;
  String? categoryId;
  String subCategoryName;
  String? otherValue;

  SubCategoryModel({
    this.docId,
    this.categoryId,
    required this.subCategoryName,
    this.otherValue,

  });

  Map<String, dynamic> toJsonForDb() => {
        "categoryId": categoryId,
        "subCategoryName": subCategoryName,

      };

  Map<String, dynamic> toJson() => {
        "docId": docId,
        "categoryId": categoryId,
        "subCategoryName": subCategoryName,
      };

  static SubCategoryModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var docId = snap.id;
    return SubCategoryModel(
      docId: docId,
      categoryId: snapshot['categoryId'] ?? 'categoryId',
      subCategoryName: snapshot['subCategoryName'] ?? 'subCategoryName',

    );
  }

  static empty(){
    return SubCategoryModel(categoryId: '', subCategoryName: '');
  }
}

class SegmentModel {
  String segmentId;
  String segmentName;
  String? categoryId;
  String? subCategoryId;
  String? segmentImg;
  List? segmentWhoList;
  bool? isSelected;

  SegmentModel(
      {required this.segmentId,
      required this.segmentName,
      this.categoryId,
      this.subCategoryId,
      this.segmentImg,
      this.segmentWhoList,
      this.isSelected});

  Map<String, dynamic> toJsonForDb() => {
        "categoryId": categoryId,
        "subCategoryId": subCategoryId,
        "segmentName": segmentName,
        "segmentImg": segmentImg,
      };

  Map<String, dynamic> toJson() => {
        "segmentId": segmentId,
        "subCategoryId": subCategoryId,
        "categoryId": categoryId,
        "segmentName": segmentName,
        "segmentImg": segmentImg,
      };

  static SegmentModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var segmentId = snap.id;

    return SegmentModel(
      segmentId: segmentId,
      categoryId: snapshot['categoryId'] ?? 'categoryId',
      subCategoryId: snapshot['subCategoryId'] ?? 'subCategoryId',
      segmentName: snapshot['segmentName'] ?? 'segmentName',
      segmentImg: snapshot['segmentImg'] ?? 'segmentImg',
    );
  }

  static SegmentModel empty() {
    return SegmentModel(segmentId: '', segmentName: '');
  }
}

class SubSegmentModel {
  String subSegmentId;
  String subSegmentName;

  SubSegmentModel({
    required this.subSegmentId,
    required this.subSegmentName,
  });

  Map<String, dynamic> toJson() => {
        "subSegmentId": subSegmentId,
        "subSegmentName": subSegmentName,
      };

  static SubSegmentModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map;
    var segmentId = snap.id;

    return SubSegmentModel(
      subSegmentId: snapshot['subSegmentId'] ?? '',
      subSegmentName: snapshot['subSegmentName'] ?? '',
    );
  }

  static SubSegmentModel empty() {
    return SubSegmentModel(subSegmentId: '', subSegmentName: '');
  }
}

class OfferOptionModel {
  String offerOption;
  String? offerId;
  List? offerSomeList;

  OfferOptionModel({
    required this.offerOption,
    this.offerId,
    this.offerSomeList,
  });
}
