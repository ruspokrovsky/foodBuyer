import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/models/category_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/position_model.dart';
import 'package:ya_bazaar/res/models/subscribers_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/users/users_providers/users_providers.dart';

class SubscribersController extends StateNotifier<List<SubscribersModel>> {
  SubscribersController() : super([]);

  clearSubscribersList() {
    state.clear();

  }

  buildSubscribersList(subscribersData) {
    var data = subscribersData.docs.map((DocumentSnapshot doc)
    => SubscribersModel.fromSnap(doc).toJson()).toList();
    for (var element in data) {
      state.add(SubscribersModel(
          docId: element['docId'],
          customerId: element['customerId'],
          projectRootId: element['projectRootId'],
          discountPercent: element['discountPercent'],
          limit: element['limit']??0,
          addedAt: element['addedAt'],)
      );
    }
  }

  buildSubscribAndNotSubscrib(WidgetRef ref,) {
    var subscribersRootIdList = state.map((e) => e.projectRootId).toList();
    ref.watch(usersListProvider).forEach((UserModel value) {
      if(value.uId != ref.watch(currentUserProvider).uId){
        if(subscribersRootIdList.contains(value.uId)){
          ref.read(subscribersSortProvider.notifier).buildSubscribeUsersList(value);
        }
        else {
          ref.read(subscribersSortProvider.notifier).buildNotSubscribeUsersList(value);
        }
      }
    });
  }


  buildCustomerSubscribers(WidgetRef ref,) {
    if(ref.watch(currentUserProvider).userStatus == 'owner'){
      ref.watch(usersListProvider).forEach((UserModel user) {
        for (SubscribersModel stateElem in state) {
          if(stateElem.customerId == user.uId){
            user.discountPercent = stateElem.discountPercent;
            user.limit = stateElem.limit;
            ref.read(subscribersSortProvider.notifier).buildSubscribeCustomersList(user);
          }
        }
      });
    }
  }

  buildOwnerSubscribers(WidgetRef ref,) {
    if(ref.watch(currentUserProvider).userStatus == 'customer'){
      ref.watch(usersListProvider).forEach((UserModel user) {
        for (SubscribersModel stateElem in state) {
          if(stateElem.projectRootId == user.uId){
            user.discountPercent = stateElem.discountPercent;
            user.limit = stateElem.limit;
            ref.read(subscribersSortProvider.notifier).buildSubscribeOwnerList(user);
          }
        }
      });
    }
  }


}


class SubscribersSortController extends StateNotifier<SubscribersSortModel> {
  SubscribersSortController() : super(SubscribersSortModel.empty());


  clearSubscribersSort() {
    state = SubscribersSortModel.empty();
  }

  clearSubscribersSortLists() {
   state.subscribersList.clear();
   state.subscribersIdList.clear();
   state.notSubscribersList.clear();
   state.notSubscribersIdList.clear();
  }

  clearSubscribCustomersSortLists() {
    state.subscribCustomersIdList.clear();
    state.subscribCustomersList.clear();
  }

  clearSubscribOwnerSortLists() {
    state.subscribOwnerIdList.clear();
    state.subscribOwnerList.clear();
  }

  buildSubscribeCustomersList(UserModel value){
    state.subscribCustomersList.add(value);
    state.subscribCustomersIdList.add(value.uId);
  }

  buildSubscribeOwnerList(UserModel value){
    state.subscribOwnerList.add(value);
    state.subscribOwnerIdList.add(value.uId);
  }

  buildSubscribeUsersList(UserModel value){
    state.subscribersList.add(value);
    state.subscribersIdList.add(value.uId);
  }

  buildNotSubscribeUsersList(UserModel value){
    state.notSubscribersList.add(value);
    state.notSubscribersIdList.add(value.uId);

  }




}