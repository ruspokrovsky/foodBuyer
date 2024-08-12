
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/generated/locale_keys.g.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/push_notifications/push_notification_system.dart';
import 'package:ya_bazaar/registration/registration_providers/registration_providers.dart';
import 'package:ya_bazaar/registration/registration_services/registration_services.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/home/home_services/home_services.dart';
import 'package:ya_bazaar/res/map/map_providers/map_providers.dart';
import 'package:ya_bazaar/res/models/all_position_model.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/place_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/positions/positions_services/positions_services.dart';
import 'package:ya_bazaar/res/utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String routeName = "homeScreen";

  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _textEditingKey = GlobalKey<FormFieldState>();
  late HomeFBServices dbs = HomeFBServices();
  List<AllPositionModel> allPositionList = [];

  bool themeStatus = true;

  bool isPositioned = false;
  int queryLength = 0;
  String query = '';
  List<int> queryArray = [];
  double productQty = 0.0;
  double amount = 0.0;

  bool _loading = false;

  bool get loading => _loading;

  set loading(bool bln) {
    _loading = bln;
  }

  Future<void> getCurrentUserData() async {
    late Registration dbs = Registration();
    var streamUser = dbs.getCurrentUser(widget.currentUserId);
    streamUser.listen(
          (userData) {
        ref.read(currentUserProvider.notifier).buildCurrentUser(userData);
      },

    );

  }

  Future<void> getAllPosition() async {
    loading = true;
    late HomeFBServices dbs = HomeFBServices();
    var streamAllPosition = dbs.getAllPosition();

    streamAllPosition.listen(
      (data) {
        ref.read(allPositionListProvider.notifier)
          ..clearAllPosition()
          ..buildAllPositionList(data,);
        loading = false;
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    //getCurrentUserData();
    _readFCMInformation(context, widget.currentUserId);
    //getAllPosition();
    super.initState();
  }

  bool ddd = true;

  @override
  Widget build(BuildContext context) {

    print(ref.watch(allPositionListProvider));

    //_readCurrentDriverInformation(context, 'uId');
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            Text(ref.watch(currentUserProvider).uId,),
            Text(ref.watch(currentUserProvider).userPhone,),
            Text(ref.watch(currentUserProvider).name,),
            Text(ref.watch(centerPositionProvider).toString(),),
            Text(LocaleKeys.add_category.tr()),




            // Expanded(
            //     child: ListView.builder(
            //       itemCount: ref.watch(allPositionListProvider).length,
            //       itemBuilder: (BuildContext context, int index){
            //
            //
            //           return ListTile(
            //             title: Text(ref.watch(allPositionListProvider)[index].productName),
            //           );
            //         }),
            // ),


            _testingButton(
              context: context,
              placesTap: () => Navigation().navigationToPlacesScreen(context, PlaceModel.empty()),
              cartTap: () async {
                var willPopCartScreen = await Navigation().navigateToCartScreen(context, PlaceModel.empty());
                if (willPopCartScreen == 'willPopCartScreen') {
                  setState(() {});
                }
              },
              expandTap: () {

                // PositionsFBServices fbs = PositionsFBServices();
                //
                // List<AllPositionModel> ddd = ref.watch(allPositionListProvider);
                //
                //
                // for(int i = 0; i < (ddd.length - 706); i++){
                //
                //   fbs.addPosition2(
                //     projectRootId: 'LHODf8WrD8UJKNQEDEWlvWMXbZL2',
                //     positionModel: PositionModel(
                //       projectRootId: 'LHODf8WrD8UJKNQEDEWlvWMXbZL2',
                //       productName: ddd[i].productName,
                //       productMeasure: ddd[i].productMeasure,
                //       productFirsPrice: 0,
                //       productPrice: 0,
                //       productQuantity: 0,
                //       marginality: 0,
                //       deliverSelectedTime: 0,
                //       available: false,
                //       subCategoryName: ddd[i].categoryProduct,
                //       subCategoryId: '',
                //       deliverId: '',
                //       deliverName: '',
                //       cartQty: 0,
                //       amount: 0,
                //       united: 0,
                //       productImage: '',
                //       unitedList: []),
                //     positionImage: File(''),
                //
                //   ).then((value) => print('position migrate success!!!'));
                // }



                // ref.watch(allPositionListProvider).forEach((element) {
                //    fbs.addPosition2(
                //       projectRootId: 'LHODf8WrD8UJKNQEDEWlvWMXbZL2',
                //       positionModel: PositionModel(
                //       projectRootId: 'LHODf8WrD8UJKNQEDEWlvWMXbZL2',
                //       productName: element.productName,
                //       productMeasure: element.productMeasure,
                //       productFirsPrice: 0,
                //       productPrice: 0,
                //       productQuantity: 0,
                //       marginality: 0,
                //       deliverSelectedTime: 0,
                //       available: false,
                //       subCategoryName: element.categoryProduct,
                //       subCategoryId: '',
                //       deliverId: '',
                //       deliverName: '',
                //       cartQty: 0,
                //       amount: 0,
                //       united: 0,
                //       productImage: '', ),
                //     positionImage: File(''),
                //   ).then((value) => print('position migrate success!!!'));
                //
                // });

              },
              addCategoryTap: () {
                Utils().showBottomSheet(
                  context: context,
                  title: LocaleKeys.add_category.tr(),
                  positiveTap: (value) {
                    if (value.isNotEmpty) {
                      CategoryModel categoryModel = CategoryModel(
                        categoryName: value,
                      );
                      dbs.addCategory(categoryModel: categoryModel);
                    }
                  },
                );
              },
              mapTap: () => Navigation().navigateToMapScreen(context: context,args: {}),
              languageTap: () {

                print(context.locale);

                if (context.locale == const Locale('ru')) {
                  context.setLocale(const Locale('en'));
                } else {
                  context.setLocale(const Locale('ru'));
                }

                setState(() {});
              },
              onThemBoolValue: themeStatus,
              onChangedThem: (value) {
                themeStatus = value;

                if (themeStatus) {
                  AdaptiveTheme.of(context).setLight();
                } else {
                  AdaptiveTheme.of(context).setDark();
                }
                setState(() {});
              },
              searchScreenTap: () =>
                  Navigation().navigateToSearchScreen(context,PlaceModel.empty()),
              ordersScreenTap: () =>
                  Navigation().navigateToOrdersScreen(context,
                      IntentCurrentUserIdObjectIdProjectRootId(
                      projectRootId: '',
                      placeId: '',)),
              unitedScreenTap: () {

                Navigation()
                    .navigateToUnitedPositionScreen(context);
              },
              purchasingScreenTap: () =>
                  Navigation().navigateToPurchaseListScreen(context),
              signUpScreenTap: () =>
                  Navigation().navigationToSignUpScreen(context,'homePage'),
              exitTap: () {

                ref.watch(authenticationProvider).signOut();
                SystemNavigator.pop();
              }, homePageTap: (){},
            )
          ]),
        ),

      ]),
    );
  }

}


Widget _testingButton({
  required BuildContext context,
  required VoidCallback homePageTap,
  required VoidCallback unitedScreenTap,
  required VoidCallback ordersScreenTap,
  required VoidCallback cartTap,
  required VoidCallback expandTap,
  required VoidCallback addCategoryTap,
  required VoidCallback mapTap,
  required VoidCallback languageTap,
  required VoidCallback searchScreenTap,
  required VoidCallback purchasingScreenTap,
  required VoidCallback signUpScreenTap,
  required VoidCallback exitTap,
  required bool onThemBoolValue,
  required Function onChangedThem,
  required VoidCallback placesTap,
}) {

  double size = MediaQuery.of(context).size.width /2.5;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: IconButton(
            onPressed: placesTap,
            icon: const Icon(Icons.wordpress, size: 100,),
          ),
        ),

        Container(
          width: size,
          height: size,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: IconButton(
            onPressed: searchScreenTap,
            icon: const Icon(Icons.search,size: 100,),
          ),
        ),
        Container(
          width: size,
          height: size,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: IconButton(
            onPressed: unitedScreenTap,
            icon: const Icon(Icons.format_underline, size: 100,),
          ),
        ),

        Container(
          width: size,
          height: size,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          child: IconButton(
            onPressed: purchasingScreenTap,
            icon: const Icon(Icons.cameraswitch_sharp, size: 100,),
          ),
        ),

        IconButton(
          onPressed: homePageTap,
          icon: const Icon(Icons.home),
        ),
        IconButton(
          onPressed: ordersScreenTap,
          icon: const Icon(Icons.add_chart),
        ),

        IconButton(
          onPressed: cartTap,
          icon: const Icon(Icons.add_shopping_cart),
        ),
        IconButton(
          onPressed: expandTap,
          icon: const Icon(Icons.expand),
        ),
        IconButton(
          tooltip: LocaleKeys.add_category.tr(),
          onPressed: addCategoryTap,
          icon: const Icon(Icons.settings_applications),
        ),
        IconButton(
          onPressed: mapTap,
          icon: const Icon(Icons.map),
        ),
        IconButton(
          onPressed: languageTap,
          icon: const Icon(Icons.language),
        ),
        IconButton(
          onPressed: signUpScreenTap,
          icon: const Icon(Icons.how_to_reg_rounded),
        ),
        IconButton(
          onPressed: exitTap,
          icon: const Icon(Icons.sensor_door_outlined),
        ),
        Switch(
            value: onThemBoolValue, onChanged: (state) => onChangedThem(state)),
      ],
    ),
  );
}


_readFCMInformation(BuildContext context, String uId) async {
  PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
  pushNotificationSystem.initializeCloudMessaging(context);
  pushNotificationSystem.generateAndGetToken(uId);
}
