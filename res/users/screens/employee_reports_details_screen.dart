import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/employee_report_model.dart';
import 'package:ya_bazaar/res/models/expenses_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/users/users_controllers/employee_report_details_controller.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/theme.dart';

class EmployeeReportDetailsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'employeeReportsDetailsScreen';
  final EmployeeReportModel employeeReportModel;

  const EmployeeReportDetailsScreen({super.key, required this.employeeReportModel});

  @override
  EmployeeReportDetailsScreenState createState() => EmployeeReportDetailsScreenState();
}

class EmployeeReportDetailsScreenState extends ConsumerState<EmployeeReportDetailsScreen> {
  UsersFBServices fbs = UsersFBServices();
  EmployeeReportModel? employeeReportData;
  UserModel? currentUserData;

  @override
  void initState() {
    employeeReportData = widget.employeeReportModel;
    currentUserData = employeeReportData!.userModel;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          List<ExpensesModel> employeeReportDetailsList = [];
          var employeeReportDetails = ref.watch(getEmployeeReportDetailsByUserIdProvider(employeeReportData!));
          EmployeeReportDetailsController employeeReportDetailsController = ref.read(employeeReporDetailstListProvider.notifier);

      return employeeReportDetails.when(
        data: (value){

          employeeReportDetailsController
          ..clearEmployeeReportDetailsList()
          ..buildEmployeeReportDetailsList(value);

        employeeReportDetailsList = ref.watch(employeeReporDetailstListProvider);

        return BaseLayout(
          onWillPop: () {
            return Future.value(true);
          },
          isAppBar: true,
          appBarTitle: currentUserData!.name,
          avatarUrl: currentUserData!.profilePhoto,
          appBarSubTitle: 'Отчеты по расходам',
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
                        title: 'Отчет по расходам от: ',
                        data: Utils().dateParse(milliseconds: employeeReportData!.addedAt),
                        postTitle: '')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'Всего позиций: ',
                        data: '${employeeReportDetailsList.length}',
                        postTitle: '')),
                RichSpanText(
                    spanText: SnapTextModel(
                        title: 'На сумму: ',
                        data: Utils().numberParse(value: employeeReportData!.expensesTotal),
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
                  childCount: employeeReportDetailsList.length,
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
                                    title: 'Наименование расхода: ',
                                    data: employeeReportDetailsList[index].expensesName!,
                                    postTitle: '')),
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'Цена расхода: ',
                                    data: Utils().numberParse(
                                        value:
                                        employeeReportDetailsList[index].expensesPrice),
                                    postTitle: ' UZS')),
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'Описание: ',
                                    data: employeeReportDetailsList[index].description!,
                                    postTitle: '')),
                            const Divider(),

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
          expandedHeight: 110.0,
        );
      },
          error: (_,__) => const Placeholder(),
          loading: () => const ProgressMiniSplash(),);
    });
  }

}
