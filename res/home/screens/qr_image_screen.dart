import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/theme.dart';

class QrImageScreen extends StatelessWidget {
  static const String routeName = 'qrImageScreen';
  final UserModel rootUserData;
  const QrImageScreen({super.key, required this.rootUserData});

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Scaffold(
      //backgroundColor: styles.qrScaffoldBackgroundColor,
      appBar: AppBar(),
      body: Center(
        child: QrImageView(data: rootUserData.rootId!),
      ),
    );
  }
}
