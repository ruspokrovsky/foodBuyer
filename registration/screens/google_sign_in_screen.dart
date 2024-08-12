
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ya_bazaar/theme.dart';

class GoogleSignInScreen extends ConsumerStatefulWidget {
  static const String routeName = 'googleSignInScreen';
  final String whoScreen;

  const GoogleSignInScreen({super.key, required this.whoScreen});

  @override
  GoogleSignInScreenState createState() => GoogleSignInScreenState();
}

class GoogleSignInScreenState extends ConsumerState<GoogleSignInScreen> {

  Future<void> signOutWithGoogle() async {
    // Получите экземпляр объекта GoogleSignIn
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Выход из учетной записи Google
      await googleSignIn.signOut();

      // Выход из учетной записи Firebase
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Обработайте возможные ошибки
      print("Error signing out with Google: $e");
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Запуск потока аутентификации
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Получить данные авторизации из запроса
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Создать новые учетные данные
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // После входа в систему верните UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  void initState() {

    signInWithGoogle();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return const Scaffold();
  }

}

