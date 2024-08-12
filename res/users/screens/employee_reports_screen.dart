
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/res/models/accountability_model.dart';
import 'package:ya_bazaar/res/models/employee_report_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/users/users_controllers/employee_report_controller.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/theme.dart';

class EmployeeReportsScreen extends StatefulWidget {
  static const String routeName = 'employeeReportsScreen';
  final UserModel userModel;

  const EmployeeReportsScreen({super.key, required this.userModel});

  @override
  State<EmployeeReportsScreen> createState() =>
      _EmployeeReportsScreenState();
}

class _EmployeeReportsScreenState extends State<EmployeeReportsScreen> {
  UsersFBServices fbs = UsersFBServices();
  UserModel? employeeData;
  final FocusNode _focusNode = FocusNode();
  TextEditingController accountabilitySumController = TextEditingController();

  @override
  void initState() {
    employeeData = widget.userModel;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      num expensesTotal = 0;
      num purchasingTotal = 0;
      List<EmployeeReportModel> employeeReportDataList = [];
      var employeeReport = ref.watch(getEmployeeReportByUserIdProvider(employeeData!.uId));
      EmployeeReportController employeeReportController = ref.read(employeeReportListProvider.notifier);
      employeeReport.whenData((value) => employeeReportController
        ..clearEmployeeReportList()
        ..buildEmployeeReportList(value));
      employeeReportDataList = ref.watch(employeeReportListProvider);

      List<num> allExpensesTotal
      = employeeReportDataList.map((e) => e.expensesTotal).toList();
      List<num> allPurchasingTotal =
          employeeReportDataList.map((e) => e.purchasingTotal).toList();

      if (allExpensesTotal.isNotEmpty) {
        expensesTotal = allExpensesTotal.fold(0, (sum, expenses) => sum + expenses);
      }
      if (allPurchasingTotal.isNotEmpty) {
        purchasingTotal = allPurchasingTotal.fold(0, (sum, advance) => sum + advance);
      }

      num totalPurchasingAndExpenses = (purchasingTotal + expensesTotal);

      return BaseLayout(
        onWillPop: () {
          return Future.value(true);
        },
        isAppBar: true,
        appBarTitle: employeeData!.name,
        appBarSubTitle: 'Отчеты',
        avatarUrl: employeeData!.profilePhoto,
        isBottomNav: false,
        isFloatingContainer: false,
        flexibleContainerChild: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            padding: EdgeInsets.zero,
            //shrinkWrap:true,
            children: [
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Всего позиций: ',
                      data: '${employeeReportDataList.length}',
                      postTitle: '')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Сумма закупа: ',
                      data: Utils().numberParse(value: purchasingTotal),
                      postTitle: ' UZS')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Сумма расходов: ',
                      data: Utils().numberParse(value: expensesTotal),
                      postTitle: ' UZS')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Всего: ',
                      data: Utils().numberParse(value: totalPurchasingAndExpenses),
                      postTitle: ' UZS')),
              const Divider(),
            ],
          ),
        ),
        flexibleSpaceBarTitle: const SizedBox.shrink(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(6.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: employeeReportDataList.length,
                (BuildContext context, int index) {
                  num overexpenditureAmount = 0;
                  num balanceAmount = 0;
                  num refundSum = 0;

                  num expensesTotal =
                      employeeReportDataList[index].expensesTotal; //расход
                  num purchasingTotal =
                      employeeReportDataList[index].purchasingTotal; //закуп
                  num refundAmount =
                      employeeReportDataList[index].employeeReportStatus!; //возврат
                  num refundAndSpent =
                      (refundAmount + purchasingTotal); //возврат + освоено

                  if (expensesTotal < refundAndSpent) {
                    overexpenditureAmount = (refundAndSpent - expensesTotal);
                  } else if (expensesTotal > refundAndSpent) {
                    balanceAmount = (expensesTotal - refundAndSpent);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    decoration: styles.positionBoxDecoration,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Дата отчета: ',
                                  data: Utils().dateParse(
                                      milliseconds:
                                      employeeReportDataList[index]
                                          .addedAt),
                                  postTitle: '')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Сумма закупа: ',
                                  data: Utils().numberParse(value: purchasingTotal),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Сумма расхода: ',
                                  data:
                                      Utils().numberParse(value: expensesTotal),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Всего: ',
                                  data: Utils().numberParse(value: (expensesTotal + purchasingTotal)),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Статус: ',
                                  data: employeeReportDataList[index]
                                      .docId
                                      .toString(),
                                  postTitle: '')),
                          const Divider(),

                        ],
                      ),
                      onTap: () {
                        if(expensesTotal > 0){
                          EmployeeReportModel employeeReportModel = employeeReportDataList[index];
                          employeeReportModel.userModel = employeeData;
                          Navigation().navigationToEmployeeReportsDetailsScreen(context, employeeReportModel);
                        }
                        else {
                          Get.snackbar('Дополнительных расходов нет!','Дополнительных расходов нет!');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          )
        ],
        isPinned: false,
        isProgress: ref.watch(progressBoolProvider),
        expandedHeight: 110.0,
      );
    });
  }



  Future<void> distributeAmount({
    required List<AccountabilityModel> advances,
    required availableAmount}) async {

    AccountabilityModel accountabilityModel = AccountabilityModel.empty();

    List<AccountabilityModel> openAdvanceList = advances.where((advance) => advance.accountabilityStatus != 2).toList(); // список сумм открытых авансов
    num totalOpenAmount = openAdvanceList.fold(0, (sum, advanceSum) => sum + advanceSum.amountIssued); // Общая сумма открытых авансов

    // Цикл для вычитания каждого числа из доступной суммы
    for (var advance in openAdvanceList) {
      // Проверка, чтобы availableAmount было больше или равно текущему числу в массиве
      if (availableAmount >= advance.amountIssued) {
        availableAmount -= advance.amountIssued;

        accountabilityModel.docId = advance.docId;
        accountabilityModel.userId = advance.userId;
        accountabilityModel.amountSpent = advance.amountSpent;
        accountabilityModel.accountabilityStatus = 0;

        await fbs.updateAccountabilityStatus(accountabilityModel: accountabilityModel);

        print('сумма аванса:: $advance');
        print('остаток по расходам:: $availableAmount');

      } else {
        // Если availableAmount меньше числа в массиве, выводим сообщение об этом
        print('Недостаточно доступной суммы для вычета: $advance');
      }
    }

    // Печать результата
    print('Доступная сумма после вычитания: $availableAmount');
  }


// void distributeAmount({required List<AccountabilityModel> advances}) {
//   double availableAmount = 3500.0; // Доступная для распределения сумма
//   List<AccountabilityModel> openAdvances = advances.where((advance) => advance.accountabilityStatus != 1).toList(); // Фильтруем открытые авансы
//   double totalOpenAmount = openAdvances.fold(0.0, (sum, advance) => sum + advance.amountIssued); // Общая сумма открытых авансов
//
//   // Если нет открытых авансов или доступная сумма равна 0, выходим из функции
//   if (openAdvances.isEmpty || availableAmount == 0) {
//     print('There are no open advances to distribute to, or available amount is 0.');
//     return;
//   }
//
//   // Распределение суммы пропорционально суммам открытых авансов
//   for (var advance in openAdvances) {
//     // Рассчитываем долю текущего аванса от общей суммы всех открытых авансов
//     double portion = advance.amountIssued / totalOpenAmount;
//
//     // Рассчитываем, сколько можно распределить для текущего аванса
//     num distributeAmount = portion * availableAmount;
//
//     // Если сумма для распределения больше, чем сумма аванса, берем сумму аванса
//     if (distributeAmount > advance.amountIssued) {
//       distributeAmount = advance.amountIssued;
//     }
//
//     // Уменьшаем доступную сумму на распределенную сумму
//     availableAmount -= distributeAmount;
//
//     // Увеличиваем сумму текущего аванса на распределенную сумму
//     advance.amountIssued += distributeAmount;
//   }
//
//   print('remainingAmount: $availableAmount');
// }

// void distributeAmount({required List<AccountabilityModel> advances}) {
//   double availableAmount = 3500.0;
//   List<AccountabilityModel> openAdvances = advances.where((advance) => advance.accountabilityStatus != 1).toList();
//   double totalOpenAmount = openAdvances.fold(0.0, (sum, advance) => sum + advance.amountIssued);
//
//   // Если общая сумма открытых авансов равна 0, выходим из функции
//   if (totalOpenAmount == 0) {
//     print('There are no open advances to distribute to.');
//     return;
//   }
//
//   // Распределение суммы пропорционально суммам открытых авансов
//   for (var advance in openAdvances) {
//     // Рассчитываем долю текущего аванса от общей суммы всех открытых авансов
//     double portion = advance.amountIssued / totalOpenAmount;
//
//     // Рассчитываем, сколько можно распределить для текущего аванса
//     num distributeAmount = portion * availableAmount;
//     print('distributeAmount: $distributeAmount');
//     // Если сумма для распределения больше, чем сумма аванса, берем сумму аванса
//     if (distributeAmount > advance.amountIssued) {
//       distributeAmount = advance.amountIssued;
//
//     }
//
//     // Уменьшаем доступную сумму на распределенную сумму
//     availableAmount -= distributeAmount;
//
//     // Увеличиваем сумму текущего аванса на распределенную сумму
//     advance.amountIssued += distributeAmount;
//   }
//
//   print('remainingAmount: $availableAmount');
// }

// void distributeAmount({required List<AccountabilityModel> advances}) {
//   num availableAmount = 3500;
//   List<AccountabilityModel> openAdvances = advances.where((advance) => advance.accountabilityStatus != 1).toList();
//   double totalOpenAmount = openAdvances.fold(0.0, (sum, advance) => sum + advance.amountIssued);
//
//   // Если общая сумма открытых авансов равна 0, выходим из функции
//   if (totalOpenAmount == 0) {
//     print('There are no open advances to distribute to.');
//     return;
//   }
//
//   // Распределение суммы пропорционально суммам открытых авансов
//   for (var advance in openAdvances) {
//     // Рассчитываем долю текущего аванса от общей суммы всех открытых авансов
//     num portion = (advance.amountIssued / totalOpenAmount) * availableAmount;
//
//     // Рассчитываем, сколько можно распределить для текущего аванса
//     num distributeAmount = portion <= advance.amountIssued ? portion : advance.amountIssued;
//
//     print(distributeAmount);
//
//     // Уменьшаем доступную сумму на распределенную сумму
//     availableAmount -= distributeAmount;
//
//     // Увеличиваем сумму текущего аванса на распределенную сумму
//     advance.amountIssued += distributeAmount;
//   }
//
//   print('remainingAmount: $availableAmount');
// }

// void distributeAmount({required List<AccountabilityModel> advances}) {
//   double availableAmount = 3500.0;
//   List<AccountabilityModel> openAdvances = advances.where((advance) => advance.accountabilityStatus != 1).toList();
//   double totalOpenAmount = openAdvances.fold(0.0, (sum, advance) => sum + advance.amountIssued);
//   double distributedAmount = 0.0;
//
//   // Распределение суммы пропорционально суммам открытых авансов
//   for (var advance in openAdvances) {
//     // Проверяем, есть ли доступная сумма и открытый аванс не является закрытым
//     if (availableAmount > 0 && advance.amountIssued > 0) {
//       // Рассчитываем порцию для текущего аванса
//       double portion = (advance.amountIssued / totalOpenAmount) * availableAmount;
//
//       print(portion);
//
//       // Учитываем порцию в сумме аванса
//       advance.amountIssued += portion;
//
//       // Учитываем порцию в общей распределенной сумме
//       distributedAmount += portion;
//     }
//   }
//
//   // Обновление доступной суммы (остаток)
//   availableAmount -= distributedAmount;
//
//   print('remainingAmount: $availableAmount');
// }

// Функция для распределения освоенной суммы по авансам
// void distributeAmount({
//   required List<AccountabilityModel> advances,
//   required num remainingAmount}) {
//   num ostatok = 0;
//   num dlyaRaspred2 = 0;
//   List<AccountabilityModel> openAdvances = advances.where((advance) => advance.accountabilityStatus != 1).toList();
//   num totalOpenAmount = openAdvances.fold(0, (sum, advance) => sum + advance.amountIssued);
//
//   print(remainingAmount);
//
//
//
//     ostatok = (totalOpenAmount - remainingAmount);
//
//     // Распределение суммы пропорционально суммам открытых авансов
//     for (var advance in openAdvances) {
//
//       num portion = (advance.amountIssued / totalOpenAmount) * remainingAmount;
//
//       print(portion);
//
//       if(remainingAmount < totalOpenAmount){
//         if((advance.amountIssued - portion).abs() < 0.0001){
//
//           print(advance.invoiceNum);
//           print(advance.docId);
//
//         }
//       }
//
//
//     }
//
//
//
//
//
// }
}
