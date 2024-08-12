// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> ru = {
  "You_have_pushed_the_button_this_many_times": "Количество нажатий на кнопку",
  "home_app_title": "Домашняя страница",
  "add_category": "Добавить категорию",
  "save": "Сохранить",
  "cancel": "Отменить",
  "add_sub_category": "Добавить подкатегорию",
  "add_sub_categoryq": "Add subCategory3"
};
static const Map<String,dynamic> en = {
  "You_have_pushed_the_button_this_many_times": "You have pushed the button this many times",
  "home_app_title": "home title",
  "add_category": "Add category",
  "save": "Save",
  "cancel": "cancel",
  "add_sub_category": "Add subCategory",
  "add_sub_categoryq": "Add subCategory2"
};
static const Map<String,dynamic> uz = {
  "You_have_pushed_the_button_this_many_times": "Узбекча",
  "home_app_title": "Узбекча title",
  "add_category": "Узбекча category",
  "save": "Узбекча save",
  "cancel": "Узбекча cancel",
  "add_sub_categoryq": "Add subCategory4"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"ru": ru, "en": en, "uz": uz};
}
