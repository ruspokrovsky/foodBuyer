import 'package:flutter/cupertino.dart';
import 'package:ya_bazaar/qr_scaner_screen.dart';
import 'package:ya_bazaar/registration/screens/google_sign_in_screen.dart';
import 'package:ya_bazaar/registration/screens/sign_screen.dart';
import 'package:ya_bazaar/registration/screens/sign_up_screen.dart';
import 'package:ya_bazaar/res/cart/screens/add_to_cart_screen.dart';
import 'package:ya_bazaar/res/cart/screens/cart_screen.dart';
import 'package:ya_bazaar/res/home/screens/create_account.dart';
import 'package:ya_bazaar/res/home/screens/create_subject.dart';
import 'package:ya_bazaar/res/home/screens/home_screen.dart';
import 'package:ya_bazaar/res/home/screens/qr_image_screen.dart';
import 'package:ya_bazaar/res/map/screens/map_screen.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/order_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/purchasing_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/objects/screens/objectScreens.dart';
import 'package:ya_bazaar/res/orders/screens/accept_position_screen.dart';
import 'package:ya_bazaar/res/orders/screens/order_positions_screen.dart';
import 'package:ya_bazaar/res/orders/screens/orders_screen.dart';
import 'package:ya_bazaar/res/orders/screens/root_order_positions_screen.dart';
import 'package:ya_bazaar/res/orders/screens/root_orders_screen.dart';
import 'package:ya_bazaar/res/orders/screens/shipment_position_screen.dart';
import 'package:ya_bazaar/res/places/screens/create_place_discount_screen.dart';
import 'package:ya_bazaar/res/places/screens/create_place_screen.dart';
import 'package:ya_bazaar/res/places/screens/places_screen.dart';
import 'package:ya_bazaar/res/places/screens/root_places_screen.dart';
import 'package:ya_bazaar/res/positions/screens/create_discount_screen.dart';
import 'package:ya_bazaar/res/positions/screens/create_position_screen.dart';
import 'package:ya_bazaar/res/positions/screens/owner_search_screen.dart';
import 'package:ya_bazaar/res/positions/screens/search_screen.dart';
import 'package:ya_bazaar/res/purchases/screens/acceptance_purchases_screen.dart';
import 'package:ya_bazaar/res/purchases/screens/actual_purchase_screen.dart';
import 'package:ya_bazaar/res/purchases/screens/purchase_list_screen.dart';
import 'package:ya_bazaar/res/purchases/screens/united_position_screen.dart';
import 'package:ya_bazaar/res/users/screens/create_expenses_screen.dart';
import 'package:ya_bazaar/res/users/screens/employee_accountability_screen.dart';
import 'package:ya_bazaar/res/users/screens/employee_reports_details_screen.dart';
import 'package:ya_bazaar/res/users/screens/employee_reports_screen.dart';
import 'package:ya_bazaar/res/users/screens/root_users_screen.dart';
import 'package:ya_bazaar/res/users/screens/select_roles_screen.dart';
import 'package:ya_bazaar/res/users/screens/users_screen.dart';
import 'package:ya_bazaar/res/widgets/category_selector.dart';
import 'package:ya_bazaar/res/widgets/full_photo_screen.dart';

import 'res/models/employee_report_model.dart';

class Navigation{

  void navigateToHomeScreen(BuildContext context, String userId) {
    Navigator.pushNamed(context, HomeScreen.routeName,
        arguments: userId);
  }

  // void navigateToHomePage(BuildContext context,) {
  //   Navigator.pushNamed(context, HomePage.routeName,);
  // }

  void navigateToObjectsScreen(BuildContext context) {
    Navigator.pushNamed(context, ObjectsScreen.routeName);
  }

  void navigateToMapScreen({required BuildContext context, required Map args,}) {
    Navigator.pushNamed(context, MapScreen.routeName, arguments: args);
  }

  Future navigateToCartScreen(BuildContext context, IntentRootPlaceArgs intentRootPlaceArgs) async {
    return await Navigator.pushNamed(context, CartScreen.routeName, arguments: intentRootPlaceArgs);
  }

  Future navigateToAddToCartScreen(BuildContext context, IntentPlacePositionRootUserArgs argsForCart) async {
    return await Navigator.pushNamed(context, AddToCartScreen.routeName, arguments: argsForCart);
  }

  Future navigateToSearchScreen(BuildContext context, IntentRootPlaceArgs navigateSearchArgs) async {
    return await Navigator.pushNamed(context, SearchScreen.routeName, arguments: navigateSearchArgs);
  }

  void navigateToOwnerSearchScreen(BuildContext context, IntentRootPlaceArgs navigateSearchArgs) {
    Navigator.pushNamed(context, OwnerSearchScreen.routeName, arguments: navigateSearchArgs);
  }

  Future navigateToCreatePlaceScreen(BuildContext context, IntentArguments args) async {
    return await Navigator.pushNamed(context, CreatePlaceScreen.routeName, arguments: args);
  }

  void navigateToOrdersScreen(BuildContext context, IntentCurrentUserIdObjectIdProjectRootId objectIdProjectRootId) {
    Navigator.pushNamed(context, OrdersScreen.routeName, arguments: objectIdProjectRootId);
  }

  Future navigateToRootOrdersScreen(BuildContext context, IntentCurrentUserIdObjectIdProjectRootId objectIdProjectRootId) async {
    return Navigator.pushNamed(context, RootOrdersScreen.routeName, arguments: objectIdProjectRootId);
  }

  Future navigateToOrderPositionsScreen(BuildContext context, IntentArguments intentArguments) async {
    return await Navigator.pushNamed(context, OrderPositionsScreen.routeName, arguments: intentArguments);
  }

  Future navigateToRootOrderPositionsScreen(BuildContext context, OrderDetailsModel orderDetailsPosition) async {
    return Navigator.pushNamed(context, RootOrderPositionsScreen.routeName, arguments: orderDetailsPosition);
  }

  Future navigateToUnitedPositionScreen(BuildContext context,) async {
    return await Navigator.pushNamed(context, UnitedPositionScreen.routeName,);
  }

  void navigateToPurchaseListScreen(BuildContext context,) {
    Navigator.pushNamed(context, PurchaseListScreen.routeName,);
  }

  void navigateToActualPurchaseScreen(BuildContext context, PurchasingModel purchasingModel) {
    Navigator.pushNamed(context, ActualPurchaseScreen.routeName, arguments: purchasingModel);
  }

  Future navigationToAcceptPositionScreen(BuildContext context, OrderModel orderPositionsModel) async {
    return await Navigator.pushNamed(context, AcceptPositionScreen.routeName,arguments: orderPositionsModel);

  }

  Future navigationToShipmentPositionScreen(BuildContext context, OrderModel orderPositionsModel) async {
    return await Navigator.pushNamed(context, ShipmentPositionScreen.routeName,arguments: orderPositionsModel);

  }

  Future navigationToSignUpScreen(BuildContext context, String whoScreen) async {
    return await Navigator.pushNamed(context, SignUpScreen.routeName, arguments: whoScreen);
  }

  Future navigationToSignScreen(BuildContext context, String whoScreen) async {
    return await Navigator.pushNamed(context, SignScreen.routeName, arguments: whoScreen);
  }

  Future navigationToGoogleSignInScreen(BuildContext context, String whoScreen) async {
    return await Navigator.pushNamed(context, GoogleSignInScreen.routeName, arguments: whoScreen);
  }

  Future navigationToPlacesScreen(BuildContext context, IntentArguments args) {
    return Navigator.pushNamed(context, PlacesScreen.routeName, arguments: args);

  }

  Future navigationToRootPlacesScreen(BuildContext context, IntentArguments args) {
    return Navigator.pushNamed(context, RootPlacesScreen.routeName, arguments: args);

  }

  Future navigationToCategorySelector(BuildContext context,) {
    return Navigator.pushNamed(context, CategorySelector.routeName,);

  }

  Future navigationToCreatePlaceDiscountScreen(BuildContext context, UserModel args) {
    return Navigator.pushNamed(context, CreatePlaceDiscountScreen.routeName, arguments: args);

  }

  void navigationToCreatePositionScreeen(BuildContext context, PositionModel positionModel) {
    Navigator.pushNamed(context, CreatePositionScreeen.routeName, arguments: positionModel);

  }

  void navigationToAcceptancePurchasesScreen(BuildContext context, PurchasingModel purchasingModel) {
    Navigator.pushNamed(context, AcceptancePurchasesScreen.routeName, arguments: purchasingModel);

  }
  void navigationToFullPhotoScreen(BuildContext context, String imageUrl) {
    Navigator.pushNamed(context, FullPhotoScreen.routeName, arguments: imageUrl);

  }
  void navigationToUsersScreen(BuildContext context,) {
    Navigator.pushNamed(context, UsersScreen.routeName,);

  }
  void navigationToRootUsersScreen(BuildContext context, UserModel userModel) {
    Navigator.pushNamed(context, RootUsersScreen.routeName, arguments:  userModel);

  }

  void navigationToQrImageScreen(BuildContext context, UserModel rootUser) {
    Navigator.pushNamed(context, QrImageScreen.routeName, arguments: rootUser);

  }

  void navigationToSelectRolesScreen(BuildContext context, UserModel userData) {
    Navigator.pushNamed(context, SelectRolesScreen.routeName, arguments: userData);

  }

  Future navigationToQrScanerScreen(BuildContext context, UserModel rootUser) {
    return Navigator.pushNamed(context, QrScanerScreen.routeName, arguments: rootUser);

  }

  void navigationToCreateDiscountScreen(BuildContext context, PositionModel posArgs) {
    Navigator.pushNamed(context, CreateDiscountScreen.routeName, arguments: posArgs);

  }

  void navigationToCreateAccountScreen(BuildContext context, UserModel userData) {
    Navigator.pushNamed(context, CreateAccountScreen.routeName, arguments: userData);

  }

  void navigationToCreateSubjectScreen(BuildContext context, UserModel userData) {
    Navigator.pushNamed(context, CreateSubjectScreen.routeName, arguments: userData);

  }

  void navigationToEmployeeAccountabilityScreen(BuildContext context, UserModel userData) {
    Navigator.pushNamed(context, EmployeeAccountabilityScreen.routeName, arguments: userData);

  }
  void navigationToEmployeeReportsScreen(BuildContext context, UserModel userData) {
    Navigator.pushNamed(context, EmployeeReportsScreen.routeName, arguments: userData);

  }

  Future navigationToCreateExpensesScreen(BuildContext context, UserModel userData) {
    return Navigator.pushNamed(context, CreateExpensesScreen.routeName, arguments: userData);

  }

  void navigationToEmployeeReportsDetailsScreen(BuildContext context, EmployeeReportModel employeeReportModel) {
    Navigator.pushNamed(context, EmployeeReportDetailsScreen.routeName, arguments: employeeReportModel);

  }

}