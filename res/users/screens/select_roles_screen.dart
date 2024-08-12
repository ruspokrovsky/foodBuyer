import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/two_buttons_block.dart';
import 'package:ya_bazaar/theme.dart';

class SelectRolesScreen extends ConsumerStatefulWidget {
  static const routeName = 'selectRolesScreen';
  final UserModel userData;

  const SelectRolesScreen({super.key, required this.userData});

  @override
  SelectRolesScreenState createState() => SelectRolesScreenState();
}

class SelectRolesScreenState extends ConsumerState<SelectRolesScreen> {
  late UserModel userData;
  List<String> rolesList = [
    'admin',
    'buyer',
    'deliveryman',
    'warehouseManager',
    'sorter',
  ];
  List<dynamic> acceptRolesList = [];

  @override
  void initState() {
    userData = widget.userData;
    acceptRolesList = userData.userRoles!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: Text(
            userData.name,
            style: styles.appBarTitleTextStyle,
          ),
        ),
        body: Column(
          children: [
            ListView.builder(
                shrinkWrap: true,
                itemCount: rolesList.length,
                itemBuilder: (BuildContext context, int index) {
                  String subTitle = '';

                  if (index == 0) {
                    subTitle = 'Админ';
                  } else if (index == 1) {
                    subTitle = 'Закупщик';
                  } else if (index == 2) {
                    subTitle = 'Доставщик';
                  } else if (index == 3) {
                    subTitle = 'Завсклад';
                  } else if (index == 4) {
                    subTitle = 'Сортировщик';
                  }

                  return CheckboxListTile(
                    checkColor: Colors.redAccent,
                    activeColor: Colors.white,
                    title: Text(
                      rolesList[index],
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(subTitle),
                    value: acceptRolesList.contains(rolesList[index]),
                    onChanged: (bool? value) =>
                        _onCategorySelected(value!, rolesList[index]),
                  );
                }),

            const SizedBox(height: 50.0,),
            TwoButtonsBlock(
                positiveText: 'Сохранить',
                positiveClick: () async {
                  ref.read(progressBoolProvider.notifier).updateProgressBool(true);
                  await UsersFBServices()
                      .updateRootUserStatus(
                          rootUserId: userData.uId, userRoles: acceptRolesList)
                      .whenComplete(() => ref.read(progressBoolProvider.notifier).updateProgressBool(false))
                      .whenComplete(() => Navigator.pop(context));
                },
                negativeText: 'Отменить',
                negativeClick: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
      ref.watch(progressBoolProvider)
          ? const ProgressDialog()
          : const SizedBox.shrink()
    ]);
  }

  void _onCategorySelected(bool selected, String role) {
    if (!selected) {
      setState(() {
        acceptRolesList.remove(role);
      });
    } else {
      setState(() {
        acceptRolesList.add(role);
      });
    }
  }
}
