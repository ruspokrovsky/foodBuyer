import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ya_bazaar/navigation.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/models/event_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/order_details_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/orders/orders_providers/orders_providers.dart';
import 'package:ya_bazaar/res/orders/orders_services/order_services.dart';
import 'package:ya_bazaar/res/providers/providers.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/base_layout.dart';
import 'package:ya_bazaar/res/widgets/progress_dialog.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';
import 'package:ya_bazaar/theme.dart';

class RootOrdersScreen extends ConsumerStatefulWidget {
  static const String routeName = 'rootOrdersScreen';

  final IntentCurrentUserIdObjectIdProjectRootId arguments;

  const RootOrdersScreen({super.key, required this.arguments});

  @override
  RootOrdersScreenState createState() => RootOrdersScreenState();
}

class RootOrdersScreenState extends ConsumerState<RootOrdersScreen> {
  IntentCurrentUserIdObjectIdProjectRootId? objectIdProjectRootId;
  List<OrderDetailsModel> ordesList = [];

  //late StreamSubscription streamSubscription;

  late IntentCurrentUserIdObjectIdProjectRootId ordersArguments;

  // Future<void> getOrdersByArguments(
  //     {required String currentUserId,
  //     required String projectRootId,
  //     required String objectId}) async {
  //   late OrderFBServices dbs = OrderFBServices();
  //   var streamOrders = dbs.getOrdersForRoot(
  //     //var streamOrders = dbs.getOrdersByObjectId435(
  //     arguments: IntentCurrentUserIdObjectIdProjectRootId(
  //         currentUserid: currentUserId,
  //         projectRootId: projectRootId,
  //         placeId: objectId),
  //   );
  //   streamSubscription = streamOrders.listen(
  //     (data) {
  //       ref.read(ordersDetailListProvider.notifier)
  //         ..clearOrdersyList()
  //         ..buildOrdersForRoot(
  //           data,
  //         );
  //       ordesList = ref.watch(ordersDetailListProvider);
  //       setState(() {});
  //     },
  //   );
  // }

  DateTime _today = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedIndex;

  void _onDaySelected(DateTime day, DateTime focusDay) {
    setState(() {
      _today = day;
      _selectedDay = _today;
      _selectedIndex = -1;
    });
  }

  final CalendarFormat _calendarFormat = CalendarFormat.week;
  final Map<DateTime, List<Event>> _kEventSource = {};

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return _kEventSource[day] ?? [];
  }

  @override
  void initState() {
    objectIdProjectRootId = widget.arguments;

    ordersArguments = IntentCurrentUserIdObjectIdProjectRootId(
        currentUserid: objectIdProjectRootId!.currentUserid!,
        projectRootId: objectIdProjectRootId!.projectRootId,
        placeId: objectIdProjectRootId!.placeId);

    // getOrdersByArguments(
    //     currentUserId: objectIdProjectRootId!.currentUserid!,
    //     projectRootId: objectIdProjectRootId!.projectRootId,
    //     objectId: objectIdProjectRootId!.placeId);

    super.initState();
  }

  @override
  void dispose() {
    //streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return ref.watch(ordersByRootIdProvider(ordersArguments)).when(
            data: (data) {
              num allTotal = 0;
              num totalFromDate = 0;
              num lengthFromDate = 0;
              ref.read(ordersDetailListProvider.notifier)
                ..clearOrdersyList()
                ..buildOrdersForRoot(data);
              _kEventSource.clear();

              if (_selectedDay != null) {
                ordesList = ref.watch(ordersDetailListProvider).where((elem) {
                  DateTime orderDate =
                      DateTime.fromMillisecondsSinceEpoch(elem.addedAt);
                  return orderDate.day == _today.day &&
                      orderDate.month == _today.month &&
                      orderDate.year == _today.year;
                }).toList();

                List<num> totalSList =
                    ordesList.map((e) => e.totalSum).toList();
                if (totalSList.isNotEmpty) {
                  totalFromDate = ordesList
                      .map((e) => e.totalSum)
                      .toList()
                      .reduce((value, element) => value + element);
                  lengthFromDate = ordesList.length;
                } else {
                  ordesList = ref.watch(ordersDetailListProvider);
                  lengthFromDate = 0;
                }
              } else {
                ordesList = ref.watch(ordersDetailListProvider);
                totalFromDate = allTotal;
                lengthFromDate = 0;
              }

              if (ordesList.isNotEmpty) {
                allTotal =
                    ref.read(ordersDetailListProvider.notifier).allTotal();
              }

              for (var element in ref.watch(ordersDetailListProvider)) {
                DateTime milliseconds =
                    DateTime.fromMillisecondsSinceEpoch(element.addedAt);

                // Создаем событие на основе дня
                Event event = Event(
                    '${milliseconds.year}${milliseconds.month}${milliseconds.day}',
                    0);

                // Создаем DateTime.utc() для использования в качестве ключа
                DateTime dateTimeFromMilliseconds = DateTime.utc(
                  milliseconds.year,
                  milliseconds.month,
                  milliseconds.day,
                );

                // Проверяем, существует ли уже список событий для данного дня
                if (_kEventSource.containsKey(dateTimeFromMilliseconds)) {
                  // Добавляем событие в существующий список
                  _kEventSource[dateTimeFromMilliseconds]!.add(event);
                  // Сортируем список событий по дням
                  _kEventSource[dateTimeFromMilliseconds]!
                      .sort((a, b) => a.title.compareTo(b.title));
                } else {
                  // Создаем новый список событий для данного дня и добавляем событие в него
                  _kEventSource[dateTimeFromMilliseconds] = [event];
                }
              }

              return BaseLayout(
                onWillPop: () {
                  return Future.value(true);
                },
                isAppBar: true,
                isBottomNav: false,
                isFloatingContainer: false,
                appBarTitle: 'Заказы',
                flexibleContainerChild: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    //shrinkWrap:true,
                    children: [
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Заказчик: ',
                              data: objectIdProjectRootId!.place!.placeName,
                              postTitle: '')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Кешбэк: ',
                              data: objectIdProjectRootId!.place!.placeDiscount
                                  .toString(),
                              postTitle: '')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Всего заказов: ',
                              data: ref
                                  .watch(ordersDetailListProvider)
                                  .length
                                  .toString(),
                              postTitle: '')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Сумма всех заказов: ',
                              data: Utils().numberParse(value: allTotal),
                              postTitle: ' UZS')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Всего заказов по дате: ',
                              data: lengthFromDate.toString(),
                              postTitle: '')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Сумма по дате: ',
                              data: Utils().numberParse(value: totalFromDate),
                              postTitle: ' UZS')),
                      TableCalendar<Event>(
                        locale: "ru_RU",
                        firstDay: kFirstDay,
                        lastDay: kLastDay,
                        focusedDay: _today,
                        availableGestures: AvailableGestures.all,
                        selectedDayPredicate: (day) => isSameDay(day, _today),
                        calendarFormat: _calendarFormat,
                        eventLoader: _getEventsForDay,

                        calendarStyle: styles.calendarStyle!,
                        headerStyle: styles.calendarHeaderStyle!,
                        daysOfWeekStyle: styles.daysOfWeekStyle!,

                        startingDayOfWeek: StartingDayOfWeek.monday,
                        onDaySelected: _onDaySelected,
                        // onPageChanged: (focusedDay) {
                        //   _today = focusedDay;
                        // },

                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              return Stack(children: [
                                Positioned(
                                  right: 10.0,
                                  bottom: -6.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3.0),
                                    decoration:
                                        styles.calendarMarkerDecoration!,
                                    child: Text(
                                      '${events.length}',
                                      style: styles.calendarMarkerTextStyle,
                                    ),
                                  ),
                                ),
                              ]);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                flexibleSpaceBarTitle: const SizedBox.shrink(),
                slivers: [
                  _contentListView(
                    context: context,
                    ref: ref,
                    ordesList: ordesList,
                  )
                ],
                isProgress: ref.watch(progressBoolProvider),
                isPinned: false,
                radiusCircular: 0.0,
                flexContainerColor: const Color.fromRGBO(255, 251, 230, 1),
                expandedHeight: 276.0,
              );
            },
            error: (_, __) => const Placeholder(),
            loading: () => const ProgressMiniSplash());
      },
    );
  }

  Widget _contentListView({
    required BuildContext context,
    required WidgetRef ref,
    required List<OrderDetailsModel> ordesList,
  }) {

    UserModel userData = ref.watch(currentUserProvider);
    AppStyles styles = AppStyles.appStyle(context);

    return SliverPadding(
      padding: const EdgeInsets.all(6.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: ordesList.length,
          (BuildContext context, int index) {
            String invoiceName =
                '${ordesList[index].invoice}/${Utils().monthParse(milliseconds: ordesList[index].addedAt)}';
            String orderStatus = '';

            Color indicatorChip = Theme.of(context).primaryColor;
            if (ordesList[index].orderStatus == 1) {
              orderStatus = 'Заказ принят на доставку';
            } else if (ordesList[index].orderStatus == 2) {
              orderStatus = 'Заказ отгружен';
            } else if (ordesList[index].orderStatus == 3) {
              orderStatus = 'Заказ доставлен';
            } else if (ordesList[index].orderStatus == 4) {
              orderStatus = 'Имеются отмененные позиции';
            } else if (ordesList[index].orderStatus == 5) {
              orderStatus = 'Заказ закрыт';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              decoration: styles.positionBoxDecoration!,
              child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Заказ № $invoiceName',
                        style: styles.worningTextStyle,
                      ),
                      const Divider(),RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Дата заказа: ',
                              data: Utils().dateTimeParse(
                                  milliseconds: ordesList[index].addedAt),
                              postTitle: '')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Сумма заказа: ',
                              data: Utils().numberParse(
                                  value: ordesList[index].totalSum),
                              postTitle: ' UZS')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Оплачено: ',
                              data: Utils().numberParse(
                                  value: ordesList[index].debtRepayment),
                              postTitle: ' UZS')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Задолжность: ',
                              data: Utils().numberParse(
                                  value: (ordesList[index].totalSum - ordesList[index].debtRepayment)),
                              postTitle: ' UZS')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Доставщик: ',
                              data: ordesList[index].deliverName,
                              postTitle: '')),
                      RichSpanText(
                          spanText: SnapTextModel(
                              title: 'Доставка принята : ',
                              data: Utils().dateTimeParse(
                                  milliseconds:
                                      ordesList[index].deliverSelectedTime),
                              postTitle: '')),
                      //RichSpanText(spanText: SnapTextModel(title: 'Статус : ', data: ordesList[index].orderStatus.toString(), postTitle: '')),
                      //const Divider(),
                      const SizedBox(
                        height: 8.0,
                      ),
                      if (ordesList[index].orderStatus == 0)
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SingleButton(
                                title: 'Принять доcтавку',
                                onPressed: () async {
                                  if (ref.watch(currentUserProvider).userRoles!.contains('deliveryman')) {

                                    showDialog<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          insetPadding: EdgeInsets.zero,
                                          actionsPadding: EdgeInsets.zero,
                                          contentPadding:
                                          const EdgeInsets.all(8.0),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          title: const Text('Принять доставку?', textAlign: TextAlign.center,),
                                          content: Stack(
                                            children: [
                                              Text(
                                                '${userData.name}, Вы принимате ответственность за комплектацию и доставку текущего заказа клиенту: "${objectIdProjectRootId!.place!.placeName}", будьте внимательны, убедитесь в наличии всех позиий!',
                                                style: styles.worningTextStyle,
                                              ),
                                              if(ref.watch(progressBoolProvider))
                                              const ProgressMini(),
                                            ]
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge,
                                              ),
                                              onPressed: () async {
                                                await _updateOrderStatus(
                                                deliverId: userData.uId,
                                                deliverName: userData.name,
                                                customerId: ordesList[index].userId,
                                                objectId: ordesList[index].objectId,
                                                orderId: ordesList[index].docId!).whenComplete(() {
                                                  ref.read(progressBoolProvider.notifier).updateProgressBool(false);
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: const Text('Принять'),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                textStyle: Theme.of(context).textTheme.labelLarge,
                                              ),
                                              child: const Text('Отменить'),
                                              onPressed: () {
                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    Get.snackbar('Вы не можете принять доставку!',
                                        'Вы не можете принять доставку');
                                  }
                                }))
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(50.0))),
                          child: Center(
                            child: Text(
                              orderStatus,
                              style: TextStyle(color: indicatorChip),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () async {
                    await Navigation()
                        .navigateToRootOrderPositionsScreen(
                      context,
                      ordesList[index],
                    )
                        .then((value) {
                      setState(() {});
                    });
                  }),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _updateOrderStatus({
  required String deliverId,
  required String deliverName,
  required String customerId,
  required String objectId,
  required String orderId,
}) async {
  await OrderFBServices().addOrderDeliver(
    orderStatus: 1,
    deliverId: deliverId,
    deliverName: deliverName,
    customerId: customerId,
    objectId: objectId,
    orderId: orderId,
  );
}
