import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ya_bazaar/res/models/accountability_model.dart';
import 'package:ya_bazaar/res/models/employee_report_model.dart';
import 'package:ya_bazaar/res/models/expenses_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/purchases/purchase_providers/purchase_providers.dart';
import 'package:ya_bazaar/res/users/users_controllers/accountability_controller.dart';
import 'package:ya_bazaar/res/users/users_controllers/expenses_list_controller.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/edit_text.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class CreateExpensesScreen extends StatefulWidget {
  static const String routeName = 'createExpensesScreen';
  final UserModel userModel;

  const CreateExpensesScreen({super.key, required this.userModel});

  @override
  State<CreateExpensesScreen> createState() => _CreateExpensesScreenState();
}

class _CreateExpensesScreenState extends State<CreateExpensesScreen> {
  UsersFBServices fbs = UsersFBServices();
  UserModel? employeeData;
  final FocusNode _focusNode = FocusNode();
  TextEditingController dropdownMenuController = TextEditingController(text: 'Расходов нет');
  TextEditingController accountabilitySumController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController reportDescriptionController = TextEditingController();

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
      final List<String> menuItems = [
        'Расходов нет',
        'Тачка',
        'Грузчики',
        'Разнорабочие',
        'Такси',
        'Доставка',
        'Стоянка',
        'ГСМ',
        'Штраф',
        'Завтрак',
        'Обед',
        'Ужин',
        'Представительские расходы',
      ];
      int menuIndex = 0;
      num totalExpenses = 0;
      ExpensesListController expensesListController = ref.read(localExpensesListProvider.notifier);

      List<AccountabilityModel> accountabilityDataList = [];
      var accountability
      = ref.watch(getAccountabilityByUserIdProvider(employeeData!.uId));
      AccountabilityListController accountabilityListController
      = ref.read(accountabilityListProvider.notifier);
      accountability.whenData((value) => accountabilityListController
        ..clearAccountabilityList()
        ..buildAccountabilityList(value));

      accountabilityDataList = ref
          .watch(accountabilityListProvider)
          .where((advance) => advance.accountabilityStatus != 1)
          .toList()
          .map((e) {
        e.balanceAmount = (e.amountIssued - (e.refundAmount + e.amountSpent));
        return e;
      }).toList();

      num totalAdvance = accountabilityDataList.fold(0,(sum, advanceSum)
      => sum + advanceSum.balanceAmount!); // Общая сумма открытых авансов

      num allTotalAdvance = (totalAdvance + employeeData!.currentPurchaseAmount!);

      //List<ExpensesModel> localExpensesList = List.from(ref.watch(expensesListProvider).reversed);
      List<ExpensesModel> localExpensesList = ref.watch(localExpensesListProvider);
      if (localExpensesList.isNotEmpty) {
        totalExpenses = localExpensesList.map((e) => e.expensesPrice!).reduce((v, e) => v + e);
      }

      num allTotalExpenses = (totalExpenses + employeeData!.currentPurchaseAmount!);

      return BaseLayout(
        onWillPop: () {
          return Future.value(true);
        },
        isAppBar: true,
        appBarTitle: employeeData!.name,
        appBarSubTitle: 'Оформление отчета',
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
                      title: 'Сумма закупа: ',
                      data: Utils().numberParse(
                          value: employeeData!.currentPurchaseAmount),
                      postTitle: ' UZS')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'Сумма расходов: ',
                      data: Utils().numberParse(value: totalExpenses),
                      postTitle: ' UZS')),
              RichSpanText(
                  spanText: SnapTextModel(
                      title: 'В подотчете: ',
                      data: Utils().numberParse(value: allTotalAdvance),
                      postTitle: ' UZS')),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownMenu<String>(
                      controller: dropdownMenuController,
                      inputDecorationTheme: InputDecorationTheme(
                        isDense: false,
                        contentPadding: const EdgeInsets.all(8.0),
                        constraints:
                        BoxConstraints.tight(const Size.fromHeight(50)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      label: const Text('Расходов нет'),
                      dropdownMenuEntries:
                      menuItems.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(
                            value: value, label: value);
                      }).toList(),
                      onSelected: (String? v) {
                        menuIndex = menuItems.indexOf(v!);
                        print(menuIndex);
                      }),

                  IconButton(onPressed: (){}, icon: Icon(Icons.receipt_long, size: 38.0,color: Theme.of(context).primaryColor,))
                ]
              ),
              const SizedBox(
                height: 8.0,
              ),
              EditText(
                  labelText: 'Другое',
                  textInputType: TextInputType.text,
                  controller: dropdownMenuController,
                  onChanged: (String? v) {}),
              const SizedBox(
                height: 8.0,
              ),
              EditText(
                  labelText: 'Описание',
                  textInputType: TextInputType.text,
                  controller: descriptionController,
                  onChanged: (String? v) {}),
              const SizedBox(
                height: 8.0,
              ),
              EditText(
                  labelText: 'Сумма UZS',
                  textInputType: TextInputType.number,
                  controller: accountabilitySumController,
                  onChanged: (v) {}),
              const SizedBox(
                height: 8.0,
              ),
              const SizedBox(
                height: 8.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: SingleButton(
                        title: 'Сохранить',
                        onPressed: () async {
                          ref
                              .read(progressBoolProvider.notifier)
                              .updateProgressBool(true);

                          await _distributeAmount(
                            openAdvanceList: accountabilityDataList,
                            availableAmount: allTotalExpenses,
                            //availableAmount: totalExpenses,
                          ).then((value) async {
                            UsersFBServices()
                                .addEmployeeReport(
                                    employeeReportModel: EmployeeReportModel(
                              userId: employeeData!.uId,
                              rootId: employeeData!.rootId!,
                              purchasingTotal: employeeData!.currentPurchaseAmount!,
                              expensesTotal: totalExpenses,
                              description: reportDescriptionController.text.trim(),
                              purchasingIdList: employeeData!.purchasingIdList!,
                              expensesList: localExpensesList,
                              addedAt: DateTime.now().millisecondsSinceEpoch,
                            ))
                                .then((value) {
                              accountabilitySumController.text = '';
                              dropdownMenuController.text = '';
                              descriptionController.text = '';
                              ref.read(localExpensesListProvider.notifier).clearExpensesList();
                              ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                              Navigator.pop(context, 'createExpensesSuccess');
                            });
                          });
                        }),
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Expanded(
                    child: SingleButton(
                        title: 'Добавить',
                        onPressed: () {
                          if (accountabilitySumController.text.isNotEmpty &&
                              dropdownMenuController.text.isNotEmpty) {
                            ExpensesModel expensesModel = ExpensesModel.empty();

                            expensesModel.userId = employeeData!.rootId!;
                            expensesModel.userId = employeeData!.uId;
                            expensesModel.expensesName = dropdownMenuController.text.trim();
                            expensesModel.expensesPrice = num.parse(accountabilitySumController.text);
                            expensesModel.description = descriptionController.text.trim();
                            expensesModel.addedAt = DateTime.now().millisecondsSinceEpoch;
                            expensesListController.addExpenses(expensesModel);
                            FocusScope.of(context).requestFocus(FocusNode());
                          } else {
                            Get.snackbar('Внимание', 'Введите значения!');
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
                childCount: localExpensesList.length,
                (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    decoration: styles.positionBoxDecoration,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Расход № ',
                                  data: '${index + 1}',
                                  postTitle: '')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title:
                                      '${localExpensesList[index].expensesName}: ',
                                  data: Utils().numberParse(
                                      value: localExpensesList[index]
                                          .expensesPrice),
                                  postTitle: ' UZS')),
                          RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Описание: ',
                                  data: localExpensesList[index].description!,
                                  postTitle: '')),
                          const Divider(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SingleButton(
                                title: 'Удалить',
                                onPressed: () {
                                  localExpensesList.removeAt(index);
                                  setState(() {});
                                }),
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ),
          if(localExpensesList.isEmpty)
           SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Если у Вас нет дополнительных расходов, нажмите кнопку "Сохранить", это создаст Ваш отчет по закупу без дополнительных расходов.',
                style: styles.worningTextStyle,),
              ),
            ),
          )
        ],
        isPinned: false,
        isFloating: true,
        isProgress: ref.watch(progressBoolProvider),
        expandedHeight: 383.0,
      );
    });
  }

  Future<String> _distributeAmount({
    required List<AccountabilityModel> openAdvanceList,
    required num availableAmount,
  }) async {

    for (var advance in openAdvanceList) {
      AccountabilityModel accountabilityModel = AccountabilityModel.empty();
      accountabilityModel.docId = advance.docId;
      accountabilityModel.userId = advance.userId;
      num spent = advance.amountSpent;
      num balanceAmount = advance.balanceAmount!;
      // Если доступная сумма достаточна для полного закрытия аванса,
      // добавляем к списанию сумму, равную остатку баланса аванса
      if (availableAmount >= balanceAmount) {
        accountabilityModel.amountSpent = (balanceAmount + spent);
        accountabilityModel.accountabilityStatus = 1;
        availableAmount -= advance.balanceAmount!;
      } else if (availableAmount < balanceAmount) {
        accountabilityModel.amountSpent = (availableAmount + spent);
        accountabilityModel.accountabilityStatus = 0;
        availableAmount = 0;
      }
      // Отправляем обновленную модель в Firebase
      await fbs.updateAccountabilityStatus(
          accountabilityModel: accountabilityModel);
    }

    // Печать результата
    print('Доступная сумма после вычета: $availableAmount');

    return 'success';
  }

  Future<String> _distributeAmount2(
      {required List<AccountabilityModel> openAdvanceList,
      required availableAmount}) async {
    for (var advance in openAdvanceList) {
      AccountabilityModel accountabilityModel = AccountabilityModel
          .empty(); // Создаем новый экземпляр для каждого advance

      // Обновляем баланс
      advance.balanceAmount =
          advance.amountIssued - (advance.refundAmount + advance.amountSpent);

      accountabilityModel.docId = advance.docId;
      accountabilityModel.userId = advance.userId;

      num spentAndAvailableAmount = availableAmount + advance.amountSpent;

      if (availableAmount >= advance.balanceAmount!) {
        accountabilityModel.amountSpent = advance.balanceAmount!;
        accountabilityModel.accountabilityStatus = 1;
        availableAmount -= accountabilityModel.amountSpent;
      } else {
        accountabilityModel.amountSpent = spentAndAvailableAmount;
        accountabilityModel.accountabilityStatus = 0;
        availableAmount -= spentAndAvailableAmount;
      }

      await fbs.updateAccountabilityStatus(
          accountabilityModel: accountabilityModel);
    }

    // Печать результата
    print('Доступная сумма после вычитания: $availableAmount');

    return 'success';
  }

  Future<void> distributeAmount(
      {required List<AccountabilityModel> advances,
      required availableAmount}) async {
    AccountabilityModel accountabilityModel = AccountabilityModel.empty();

    List<AccountabilityModel> openAdvanceList = advances
        .where((advance) => advance.accountabilityStatus != 1)
        .toList(); // список сумм открытых авансов

    // Цикл для вычитания каждого числа из доступной суммы
    for (var advance in openAdvanceList) {
      // Проверка, чтобы availableAmount было больше или равно текущему числу в массиве
      if (availableAmount >= advance.amountIssued) {
        availableAmount -= advance.amountIssued;

        accountabilityModel.docId = advance.docId;
        accountabilityModel.userId = advance.userId;
        accountabilityModel.amountSpent = advance.amountSpent;
        accountabilityModel.accountabilityStatus = 0;

        await fbs.updateAccountabilityStatus(
            accountabilityModel: accountabilityModel);

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
}
