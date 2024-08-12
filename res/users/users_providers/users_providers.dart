import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/accountability_model.dart';
import 'package:ya_bazaar/res/models/employee_report_model.dart';
import 'package:ya_bazaar/res/models/expenses_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/positions/positions_controllers/discount_controller.dart';
import 'package:ya_bazaar/res/users/users_controllers/accountability_controller.dart';
import 'package:ya_bazaar/res/users/users_controllers/employee_report_controller.dart';
import 'package:ya_bazaar/res/users/users_controllers/employee_report_details_controller.dart';
import 'package:ya_bazaar/res/users/users_controllers/expenses_list_controller.dart';
import 'package:ya_bazaar/res/users/users_controllers/user_controller.dart';
import 'package:ya_bazaar/res/users/users_controllers/users_controller.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';

UsersFBServices fbServices = UsersFBServices();

final usersProvider = StreamProvider<QuerySnapshot>(
    (_) => fbServices.getUsers(),
    name: 'usersProvider');



final usersListProvider = StateNotifierProvider<UsersListController, List<UserModel>>(
        (_) => UsersListController([]),
    name: 'usersListProvider');

final rootUsersListProvider = StreamProvider.family<QuerySnapshot, String>(
        (_, rootId) => fbServices.getRootUsers(rootId),
    name: 'rootUsersListProvider');



final userProvider = StreamProvider.family<DocumentSnapshot,String>(
        (_, arg) => fbServices.getUser(arg),
    name: 'userProvider');


final userControllerProvider = StateNotifierProvider<UserController, UserModel>(
        (_) => UserController(),
    name: 'userControllerProvider');

final getAccountabilityByUserIdProvider = StreamProvider.family<QuerySnapshot, String>(
        (ref, param) => fbServices.getAccountabilityByUserId(param),
    name: 'getAccountabilityByUserIdProvider');
final accountabilityListProvider = StateNotifierProvider<AccountabilityListController, List<AccountabilityModel>>(
        (_) => AccountabilityListController([]),
    name: 'accountabilityListProvider');


final getEmployeeReportByUserIdProvider = StreamProvider.family<QuerySnapshot, String>(
        (ref, param) => fbServices.getEmployeeReportByUserId(param),
    name: 'getEmployeeReportByUserIdProvider');
final employeeReportListProvider = StateNotifierProvider<EmployeeReportController, List<EmployeeReportModel>>(
        (_) => EmployeeReportController([]),
    name: 'employeeReportListProvider');

final getEmployeeReportDetailsByUserIdProvider = StreamProvider.autoDispose.family<QuerySnapshot, EmployeeReportModel>(
        (ref, param) => fbServices.getEmployeeReporDetailsByUserId(employeeReportModel: param),
    name: 'getEmployeeReportDetailsByUserIdProvider',);
final employeeReporDetailstListProvider = StateNotifierProvider<EmployeeReportDetailsController, List<ExpensesModel>>(
        (_) => EmployeeReportDetailsController([]),
    name: 'employeeReporDetailstListProvider');


final localExpensesListProvider =
StateNotifierProvider<ExpensesListController, List<ExpensesModel>>(
        (_) => ExpensesListController([]),
    name: "expensesListProvider");



