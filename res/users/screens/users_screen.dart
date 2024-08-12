import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/users/users_controllers/users_controller.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';
import 'package:ya_bazaar/res/users/users_services/users_services.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/theme.dart';

class UsersScreen extends StatefulWidget {
  static const String routeName = 'usersScreen';
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  UsersFBServices fbs = UsersFBServices();
  Utils utils = Utils();

  Widget _popUpMenuBtn(BuildContext context, WidgetRef ref, String currentUserId, String userId){
      return PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          onSelected: (int itemIndex) async {
            if (itemIndex == 0) {

              String statusOwner = 'owner';
              //String statusOwner = 'owner-${DateTime.now().millisecondsSinceEpoch}';

              await fbs.updateUserStatus(userId: userId, userStatus: statusOwner)
                  .whenComplete(() => print('updateUserStatusSuccess'));

            }
            else if(itemIndex == 1){

              String statusCustomer = 'customer';
              //String statusCustomer = 'customer-${DateTime.now().millisecondsSinceEpoch}';

              await fbs.updateUserStatus(userId: userId, userStatus: statusCustomer)
                  .whenComplete(() => print('updateUserStatusSuccess'));

            }
            else if(itemIndex == 2) {


              await fbs.unSubscribers(currentUserId: currentUserId, subscribersUid: userId)
                  .whenComplete((){


                //ref.read(subscribersListProvider.notifier).buildProduct(ref);


                print('unSubscriberSuccess');
              }
              );

            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 0,
                child: const Text('owner')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 1,
                child: const Text('customer')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 2,
                child: const Text('отписаться')),
          ]);



  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return
      Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Пользователи', style: styles.appBarTitleTextStyle),
          ),

          body: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              List<UserModel> usersDataList = [];
              var users = ref.watch(usersProvider);
              UsersListController usersListController = ref.read(usersListProvider.notifier);
              users.whenData((value) => usersListController..clearUsersList()..buildUsersList(value));
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
                          Text(usersDataList[index].uId,style: const TextStyle(fontSize: 12),),
                          Text('addedAt: ${utils.dateParse(milliseconds: usersDataList[index].addedAt!)}'),
                          Text('userPhone: ${usersDataList[index].userPhone}',),
                          Text('userRole: ${usersDataList[index].userRole}',),
                          Text('userStatus: ${usersDataList[index].userStatus!}',),
                        ],
                      ),
                      trailing: _popUpMenuBtn(context,ref,ref.watch(currentUserProvider).uId, usersDataList[index].uId,),
                    );
                  });

            },
          ),
        )
      ],
    );
  }
}
