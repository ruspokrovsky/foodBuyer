import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/models/accountability_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/users/users_controllers/accountability_controller.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class EmployeeAccountabilityScreen extends StatefulWidget {
  static const String routeName = 'employeeAccountabilityScreen';
  final UserModel userModel;

  const EmployeeAccountabilityScreen({super.key, required this.userModel});

  @override
  State<EmployeeAccountabilityScreen> createState() =>
      _EmployeeAccountabilityScreenState();
}

class _EmployeeAccountabilityScreenState
    extends State<EmployeeAccountabilityScreen> {
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
      int invoiceNum = 0;
      num totalIssued = 0;
      num totalSpent = 0;
      num totalRefund = 0;
      num totalBalance = 0;

      UserModel currentUser = ref.watch(currentUserProvider);

      List<AccountabilityModel> accountabilityDataList = [];
      var accountability =
          ref.watch(getAccountabilityByUserIdProvider(employeeData!.uId));
      AccountabilityListController accountabilityListController =
          ref.read(accountabilityListProvider.notifier);
      accountability.whenData((value) => accountabilityListController
        ..clearAccountabilityList()
        ..buildAccountabilityList(value));
      //заранее мапим balanceAmount для дальнейшего использования, balanceAmount локальная переменная

      accountabilityDataList = ref.watch(accountabilityListProvider).map((e) {
        e.balanceAmount = (e.amountIssued - (e.refundAmount + e.amountSpent));
        return e;
      }).toList();

      invoiceNum = accountabilityDataList.fold(
          1, (maxInvoice, order) => max(maxInvoice, order.invoiceNum + 1));

      //amountIssued - выданно
      //amountSpent - освоено
      //refundAmount - возврат

      List<num> allIssued =
          accountabilityDataList.map((e) => e.amountIssued).toList();
      List<num> allSpent =
          accountabilityDataList.map((e) => e.amountSpent).toList();
      List<num> allRefund =
          accountabilityDataList.map((e) => e.refundAmount).toList();

      if (allIssued.isNotEmpty) {
        totalIssued = allIssued.fold(0, (sum, advance) => sum + advance);
      }
      if (allSpent.isNotEmpty) {
        totalSpent = allSpent.fold(0, (sum, advance) => sum + advance);
      }
      if (allRefund.isNotEmpty) {
        totalRefund = allRefund.fold(0, (sum, advance) => sum + advance);
      }

      num totalSpentAndRefund = (totalSpent + totalRefund);

      if (totalSpentAndRefund < totalIssued) {
        totalBalance = (totalIssued - totalSpentAndRefund);
      } else if (totalSpentAndRefund > totalIssued) {
        totalBalance = (totalSpentAndRefund - totalIssued);
      }
      return BaseLayout(
        onWillPop: () {
          return Future.value(true);
        },
        isAppBar: true,
        appBarTitle: employeeData!.name,
        appBarSubTitle: 'История авансов',
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
                      title: 'Выдано: ',
                      data: Utils().numberParse(value: totalIssued),
                      postTitle: ' UZS')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Потрачено: ',
                      data: Utils().numberParse(value: totalSpent),
                      postTitle: ' UZS')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Возврат: ',
                      data: Utils().numberParse(value: totalRefund),
                      postTitle: ' UZS')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'В подотчете: ',
                      data: Utils().numberParse(value: totalBalance),
                      postTitle: ' UZS')),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: EditText(
                        labelText: 'Сумма аванса',
                        textInputType: TextInputType.number,
                        controller: accountabilitySumController,
                        focusNode: _focusNode,
                        onChanged: (v) {}),
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleButton(
                        title: 'Выдать',
                        onPressed: () {

                          if(currentUser.userRoles!.contains('admin')){

                            if(accountabilitySumController.text.isNotEmpty){
                              num accountabilitySum =  num.parse(accountabilitySumController.text.trim());
                              ref.read(progressBoolProvider.notifier).updateProgressBool(true);
                              UsersFBServices().addAccountability(
                                  accountabilityModel: AccountabilityModel(
                                      rootId: employeeData!.rootId!,
                                      userId: employeeData!.uId,
                                      amountIssued: accountabilitySum,
                                      amountSpent: 0,
                                      refundAmount: 0,
                                      accountabilityStatus: 0,
                                      invoiceNum: invoiceNum,
                                      addedAt: DateTime.now().millisecondsSinceEpoch)).then((value) {
                                ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                accountabilitySumController.text = '';
                                _focusNode.unfocus();
                              });
                            }
                            else {
                              Get.snackbar('Внимание!', 'Добвте сумму выдачи!');
                            }

                          }


                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
        flexibleSpaceBarTitle: const SizedBox.shrink(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(6.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: accountabilityDataList.length,
                (BuildContext context, int index) {

                  num newRefundSum = 0;

                  num status
                  = accountabilityDataList[index].accountabilityStatus;
                  num amountIssued =
                      accountabilityDataList[index].amountIssued; //выданно
                  num amountSpent =
                      accountabilityDataList[index].amountSpent; //освоено
                  num refundAmount =
                      accountabilityDataList[index].refundAmount; //возврат
                  num currentBalance = accountabilityDataList[index].balanceAmount!; //возврат + освоено

                  String invoiceNum
                  = '${accountabilityDataList[index].invoiceNum}/${Utils().monthParse(milliseconds: accountabilityDataList[index].addedAt)}';



                  return Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    decoration: styles.positionBoxDecoration,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Аванс № ',
                                  data: invoiceNum,
                                  postTitle: '')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Сумма аванса: ',
                                  data:
                                      Utils().numberParse(value: amountIssued),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Освоено: ',
                                  data: Utils().numberParse(value: amountSpent),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Возврат: ',
                                  data:
                                  Utils().numberParse(value: refundAmount),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'В подотчете: ',
                                  data:
                                      Utils().numberParse(value: currentBalance),
                                  postTitle: ' UZS')),
                          // RichSpanText(
                          //     spanText: SnapTextModel(
                          //         title: 'Перерасход: ',
                          //         data: Utils().numberParse(
                          //             value: overexpenditureAmount),
                          //         postTitle: ' UZS')),

                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Дата аванса: ',
                                  data: Utils().dateParse(
                                      milliseconds:
                                          accountabilityDataList[index]
                                              .addedAt),
                                  postTitle: '')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Статус: ',
                                  data: status.toString(),
                                  postTitle: '')),
                          const Divider(),
                          if (status == 0)
                            Row(
                              children: [
                                Expanded(
                                  child: EditText(
                                    labelText: 'Сумма возврата',
                                    controller: TextEditingController(),
                                    textInputType: TextInputType.number,
                                    onChanged: (v) {
                                      if (v.isNotEmpty) {
                                        newRefundSum = num.parse(v);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 6.0,
                                ),
                                Expanded(
                                  child: SingleButton(
                                      title: 'Принять возврат',
                                      onPressed: () async {

                                        if (newRefundSum != 0) {

                                          if(newRefundSum <= currentBalance){

                                            ref.read(progressBoolProvider.notifier).updateProgressBool(true);

                                            num newRefundAmount = (newRefundSum + refundAmount);
                                            num newTotal = (newRefundAmount + amountSpent);

                                            AccountabilityModel accountabilityModel = AccountabilityModel.empty();
                                            accountabilityModel.docId = accountabilityDataList[index].docId;
                                            accountabilityModel.userId = employeeData!.uId;
                                            accountabilityModel.refundAmount = newRefundAmount;

                                            if(amountIssued == newTotal){
                                            accountabilityModel.accountabilityStatus = 1;
                                            }
                                            else {
                                            accountabilityModel.accountabilityStatus = 0;
                                            }

                                            await fbs
                                                .updateRefund(accountabilityModel: accountabilityModel)
                                                .then((value) {
                                              ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                              FocusScope.of(context).requestFocus(FocusNode());
                                            });

                                          }
                                          else {
                                            Get.snackbar('Внимание!',
                                                'Сумма превышена!');
                                          }
                                        }
                                        else {
                                          Get.snackbar('Внимание!',
                                              'Ввидите сумму!');
                                        }
                                      }),
                                ),
                              ],
                            ),
                          if (status == 1)
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: SingleButton(
                                  title: 'Аванс закрыт!',
                                  onPressed: () {}),
                            ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          )
        ],
        isPinned: false,
        isProgress: ref.watch(progressBoolProvider),
        expandedHeight: 160.0,
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
