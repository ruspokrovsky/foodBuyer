
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/subscribers_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';

class QrScanerScreen extends ConsumerStatefulWidget {
  static const routeName = 'qrScanerScreen';
  final UserModel userData;
  const QrScanerScreen({super.key, required this.userData});

  @override
  QrScanerScreenState createState() => QrScanerScreenState();
}

class QrScanerScreenState extends ConsumerState<QrScanerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  UsersFBServices fbs =  UsersFBServices();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  List<dynamic> notSubscribersList = [];
  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {

        notSubscribersList
        = ref.watch(subscribersSortProvider).notSubscribersList
            .map((e) => e.rootId).toList();

        return Scaffold(
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  overlay: QrScannerOverlayShape(
                    borderColor: Theme.of(context).primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: scanArea,
                  ),
                  onQRViewCreated: widget.userData.fromWhichScreen == 'placesScreen' ? _scanerCustomerSubscrib : _scanerEmployeeSubscrib,
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: (result != null)
                      ? Text(
                      'Barcode Type: ${describeEnum(result!.format)}\nData: ${result!.code}\ncurrentId: ${widget.userData.uId}')
                      : const Text('Scan a code'),
                ),
              )
            ],
          ),
        );
      },
    );
  }



  _scanerEmployeeSubscrib(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if(notSubscribersList.contains(result!.code!)){
        // Передаем данные сканирования для обновления в базе данных
        await fbs.updateUserRootId(
          currentUserId: widget.userData.uId,
          scanData: result!.code!,
        );
        SystemNavigator.pop();
      }
      else {
        Get.snackbar('Не актуальный QRCode','Не актуальный QRCode');
        controller.dispose();
      }
    });
  }

  _scanerCustomerSubscrib(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if(notSubscribersList.contains(result!.code!)){
        SubscribersModel subscribersModel = SubscribersModel(
          customerId: widget.userData.uId,
          projectRootId: result!.code!,
          addedAt: DateTime.now().millisecondsSinceEpoch,
          discountPercent: 0,
          limit: 0,
        );

        // Передаем данные сканирования для обновления в базе данных
        await fbs.addSubscribers(subscribersModel: subscribersModel);
        SystemNavigator.pop();
      }
      else {

        Get.snackbar('Не актуальный QRCode','Не актуальный QRCode');
        controller.dispose();
      }
    });
  }



  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}


