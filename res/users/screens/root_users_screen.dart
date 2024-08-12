
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/users/users_controllers/users_controller.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/theme.dart';

class RootUsersScreen extends StatefulWidget {
  static const String routeName = 'rootUsersScreen';
  final UserModel userModel;
  const RootUsersScreen({super.key, required this.userModel});

  @override
  State<RootUsersScreen> createState() => _RootUsersScreenState();
}

class _RootUsersScreenState extends State<RootUsersScreen> {

  UsersFBServices fbs = UsersFBServices();
  Utils utils = Utils();
  UserModel rootUserModel  = UserModel.empty();

  @override
  void initState() {
    rootUserModel = widget.userModel;
    super.initState();
  }

  Widget _popUpMenuBtn(BuildContext context, UserModel userData){
      return PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          onSelected: (int itemIndex) async {
            if (itemIndex == 0) {
              if(rootUserModel.userRoles!.contains('admin')){
                Navigation().navigationToSelectRolesScreen(context, userData);
              }

            }
            else if(itemIndex == 1){
              if(rootUserModel.userRoles!.contains('admin')){
                await UsersFBServices().deleteRootUser(currentUserId: userData.uId,);
              }

            }
            else if(itemIndex == 2){
              Navigation().navigationToEmployeeAccountabilityScreen(context, userData);
            }
            else if(itemIndex == 3){
              Navigation().navigationToEmployeeReportsScreen(context, userData);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 0,
                child: const Text('Добавить роль')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 1,
                child: const Text('Уволить')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 2,
                child: const Text('Авансы')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 3,
                child: const Text('Отчеты')),
          ]);



  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Root Пользователи', style: styles.appBarTitleTextStyle),
            actions: [
              IconButton(
                  onPressed: (){
                    rootUserModel.rootId = rootUserModel.rootId;
                    Navigation().navigationToQrImageScreen(context, rootUserModel);
                  },
                  icon: const Icon(Icons.qr_code))
            ],
          ),

          body: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              List<UserModel> usersDataList = [];
              var rootUsers = ref.watch(rootUsersListProvider(rootUserModel.rootId!));
              UsersListController usersListController = ref.read(usersListProvider.notifier);
              rootUsers.whenData((value) => usersListController..clearUsersList()..buildUsersList(value));
              usersDataList = ref.watch(usersListProvider);
              return ListView.builder(
                  itemCount: usersDataList.length,
                  itemBuilder: (BuildContext context, int index){
                    return ListTile(
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: CachedNetworkImg(
                            imageUrl: usersDataList[index].profilePhoto,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover),
                      ),
                      title: Text(usersDataList[index].name, style: styles.smalTitleTextStyle),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('addedAt: ${utils.dateParse(milliseconds: usersDataList[index].addedAt!)}'),
                          Text('userPhone: ${usersDataList[index].userPhone}',),
                          Text('userRoles: ${usersDataList[index].userRoles}',),
                          Text('userStatus: ${usersDataList[index].userStatus!}',),
                          Text('statusList: ${usersDataList[index].statusList!}',),
                          Text('uId: ${usersDataList[index].uId}',),
                          Text('rootId: ${usersDataList[index].rootId!}',),
                        ],
                      ),
                      trailing: _popUpMenuBtn(context,usersDataList[index],),
                    );
                  });

            },
          ),
        )
      ],
    );
  }
}
