import 'package:flutter/material.dart';
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
import 'package:ya_bazaar/res/models/employee_report_model.dart';
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

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case HomeScreen.routeName:
      String userid = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => HomeScreen(currentUserId: userid,));

    case ObjectsScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => const ObjectsScreen());

    case MapScreen.routeName:
      Map arguments = routeSettings.arguments as Map;
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => MapScreen(args:arguments));

    case CartScreen.routeName:
      IntentRootPlaceArgs? intentRootPlaceArgs = routeSettings.arguments as IntentRootPlaceArgs;
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => CartScreen(navigateSearchArgs: intentRootPlaceArgs,));

    case AddToCartScreen.routeName:
      IntentPlacePositionRootUserArgs argsForCart = routeSettings.arguments as IntentPlacePositionRootUserArgs;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => AddToCartScreen(arguments: argsForCart,));

    case SearchScreen.routeName:
      IntentRootPlaceArgs navigateSearchArgs  = routeSettings.arguments as IntentRootPlaceArgs;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => SearchScreen(navigateSearchArgs: navigateSearchArgs,));

    case OwnerSearchScreen.routeName:
      IntentRootPlaceArgs navigateSearchArgs  = routeSettings.arguments as IntentRootPlaceArgs;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => OwnerSearchScreen(navigateSearchArgs: navigateSearchArgs,));

    case CreatePlaceScreen.routeName:
      IntentArguments args = routeSettings.arguments as IntentArguments;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => CreatePlaceScreen(
            arguments: args,
              ));

    case OrdersScreen.routeName:
      IntentCurrentUserIdObjectIdProjectRootId arguments = routeSettings.arguments as IntentCurrentUserIdObjectIdProjectRootId;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => OrdersScreen(arguments: arguments,));


    case RootOrdersScreen.routeName:
      IntentCurrentUserIdObjectIdProjectRootId arguments = routeSettings.arguments as IntentCurrentUserIdObjectIdProjectRootId;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => RootOrdersScreen(arguments: arguments,));

    case OrderPositionsScreen.routeName:
      IntentArguments intentArguments = routeSettings.arguments as IntentArguments;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => OrderPositionsScreen(intentArguments: intentArguments,
              ));

    case RootOrderPositionsScreen.routeName:
      OrderDetailsModel orderDetailsPosition = routeSettings.arguments as OrderDetailsModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => RootOrderPositionsScreen(orderDetailsPosition: orderDetailsPosition,
          ));

    case UnitedPositionScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const UnitedPositionScreen());

    case PurchaseListScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => const PurchaseListScreen());

    case ActualPurchaseScreen.routeName:
      PurchasingModel purchasingModel =
          routeSettings.arguments as PurchasingModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) =>
              ActualPurchaseScreen(purchasingModel: purchasingModel));

    case AcceptPositionScreen.routeName:
      OrderModel orderModel = routeSettings.arguments as OrderModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => AcceptPositionScreen(
                orderModel: orderModel,
              ));

    case ShipmentPositionScreen.routeName:
      OrderModel orderModel = routeSettings.arguments as OrderModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ShipmentPositionScreen(
                orderModel: orderModel,
              ));

    case SignUpScreen.routeName:
      String whoScreen = routeSettings.arguments as String;
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => SignUpScreen(whoScreen: whoScreen,));

    case SignScreen.routeName:
      String whoScreen = routeSettings.arguments as String;
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => SignScreen(whoScreen: whoScreen,));

    case GoogleSignInScreen.routeName:
      String whoScreen = routeSettings.arguments as String;
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => GoogleSignInScreen(whoScreen: whoScreen,));

    case PlacesScreen.routeName:
      IntentArguments args = routeSettings.arguments as IntentArguments;
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => PlacesScreen(arguments: args,));

    case RootPlacesScreen.routeName:
      IntentArguments args = routeSettings.arguments as IntentArguments;
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => RootPlacesScreen(arguments: args,));

    case CreatePositionScreeen.routeName:
      PositionModel positionModel =
          routeSettings.arguments as PositionModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) =>
              CreatePositionScreeen(positionModel: positionModel));

    case AcceptancePurchasesScreen.routeName:
      PurchasingModel purchasingModel =
          routeSettings.arguments as PurchasingModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => AcceptancePurchasesScreen(
                purchasingModel: purchasingModel,
              ));
    case FullPhotoScreen.routeName:
      String imageUrl = routeSettings.arguments as String;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => FullPhotoScreen(url: imageUrl,));

    case UsersScreen.routeName:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const UsersScreen());

    case CategorySelector.routeName:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const CategorySelector());

    case QrImageScreen.routeName:
      UserModel rootUserData = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => QrImageScreen(rootUserData: rootUserData,));

    case QrScanerScreen.routeName:
      UserModel currentUserData = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => QrScanerScreen(userData: currentUserData,));

    case RootUsersScreen.routeName:
      UserModel userModel = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => RootUsersScreen(userModel: userModel,));

    case SelectRolesScreen.routeName:
      UserModel userData = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => SelectRolesScreen(userData: userData,));

    case CreateDiscountScreen.routeName:
      PositionModel posArgs = routeSettings.arguments as PositionModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => CreateDiscountScreen(positionModel: posArgs,));

    case CreatePlaceDiscountScreen.routeName:
      UserModel args = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => CreatePlaceDiscountScreen(userData: args,));

    case CreateAccountScreen.routeName:
      UserModel userArgs = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => CreateAccountScreen(userModel: userArgs,));

    case CreateSubjectScreen.routeName:
      UserModel userArgs = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => CreateSubjectScreen(userModel: userArgs,));

    case EmployeeAccountabilityScreen.routeName:
      UserModel userArgs = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => EmployeeAccountabilityScreen(userModel: userArgs,));

    case CreateExpensesScreen.routeName:
      UserModel userArgs = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => CreateExpensesScreen(userModel: userArgs,));

    case EmployeeReportsScreen.routeName:
      UserModel userArgs = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => EmployeeReportsScreen(userModel: userArgs,));

    case EmployeeReportDetailsScreen.routeName:
      EmployeeReportModel employeeReportModel = routeSettings.arguments as EmployeeReportModel;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => EmployeeReportDetailsScreen(employeeReportModel: employeeReportModel,));

    default:
      return MaterialPageRoute(
          builder: (_) => const Scaffold(
                body: Center(
                  child: Text("Нет такой страницы"),
                ),
              ));
  }
}
