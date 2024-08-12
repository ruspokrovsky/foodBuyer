import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:ya_bazaar/auth_checker.dart';
import 'package:ya_bazaar/generated/codegen_loader.g.dart';
import 'package:ya_bazaar/routers.dart';
import 'package:ya_bazaar/theme.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GetStorage.init();

  if(Platform.isAndroid){
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyA1r2EhsWUDB0s1fdYMx99K5ADYavYYHVY',
            appId: '1:365775860732:ios1:76e27780c42445357fb879',
            messagingSenderId: '365775860732',
            projectId: 'yabazaar-68e33',
            storageBucket: 'yabazaar-68e33.appspot.com'));
  }
  else {
    await Firebase.initializeApp();
  }

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        assetLoader: const CodegenLoader(),
        child: const MyApp()
  ),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      initial: AdaptiveThemeMode.light,
      light: kLightTheme,
      dark: kDarkTheme,
      builder: (ThemeData light, ThemeData dark) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: light,
          darkTheme: dark,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const AuthChecker(),
          //home: const HomeScreen(),
          onGenerateRoute: (settings) => generateRoute(settings) ,
        );
      },
    );
  }
}