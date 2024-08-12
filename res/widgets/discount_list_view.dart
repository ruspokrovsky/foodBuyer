import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/models/discount_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/positions/positions_controllers/discount_controller.dart';
import 'package:ya_bazaar/res/positions/positions_providers.dart';
import 'package:ya_bazaar/res/widgets/progress_mini.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';
import 'package:ya_bazaar/theme.dart';

class DiscountListView extends ConsumerWidget {
  final DiscountModel arguments;

  const DiscountListView({super.key,
    required this.arguments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStyles styles = AppStyles.appStyle(context);
    return arguments.positionId.isEmpty
      ? const SizedBox.shrink()
      : Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        List<DiscountModel> discountList = [];
        var discoundData = ref.watch(getPositionsDiscountProvider(arguments));
        DiscountController discountController = ref.read(discountListProvider.notifier);
        return discoundData.when(data: (QuerySnapshot snap){
          discountController..clean()..buildPositionDiscountList(snap);
          discountList = ref.watch(discountListProvider);
          return discountList.isEmpty
              ?
              const SizedBox.shrink()
              : Container(
            color: styles.flexBackgroundColor,
            //padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              itemCount: discountList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Table(
                  //border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Количество: ',
                                  data: discountList[index].quantity.toString(),
                                  postTitle: '')),),
                        TableCell(
                          child: RichSpanText(
                              spanText: SnapTextModel(
                                  title: 'Скидка: ',
                                  data: discountList[index].percent.toString(),
                                  postTitle: ' %')),),


                      ],
                    ),
                    // Добавьте другие строки или ячейки по мере необходимости
                  ],
                );
              },
            ),
          );
        },
            error: (_,__) => const Placeholder(),
            loading: ()=> const ProgressMini());
      },
    );
  }


}


// Widget _discountListView2({
//   required List<DiscountModel> discountList,
//   required AppStyles styles,
//   required String projectRootId,
//   required String positionId,
// }){
//   DiscountModel arguments = DiscountModel(
//       rootId: projectRootId,
//       positionId: positionId, quantity: 0, percent: 0);
//   return Consumer(
//     builder: (BuildContext context, WidgetRef ref, Widget? child) {
//       List<DiscountModel> discountList = [];
//       var discoundData = ref.watch(getPositionsDiscountProvider(arguments));
//       DiscountController discountController = ref.read(discountListProvider.notifier);
//       return discoundData.when(data: (QuerySnapshot snap){
//         discountController..clean()..buildPositionDiscountList(snap);
//         discountList = ref.watch(discountListProvider);
//         return Container(
//           color: const Color.fromRGBO(255, 251, 230, 1),
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: ListView.builder(
//             itemCount: discountList.length,
//             shrinkWrap: true,
//             itemBuilder: (context, index) {
//               return Table(
//                 //border: TableBorder.all(),
//                 children: [
//                   TableRow(
//                     children: [
//                       TableCell(
//                         child: RichText(
//                           text: TextSpan(
//                             text: 'Количество: ',
//                             style: styles.worningTextStyle,
//                             children: <TextSpan>[
//                               TextSpan(
//                                   text: discountList[index].quantity.toString(),
//                                   style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
//
//                             ],
//                           ),
//                         ),),
//                       TableCell(
//                         child: RichText(
//                           text: TextSpan(
//                             text: 'Скидка: ',
//                             style: styles.worningTextStyle,
//                             children: <TextSpan>[
//
//                               TextSpan(
//                                   text: discountList[index].percent.toString(),
//                                   style: const TextStyle(
//                                       color: Colors.redAccent,
//                                       fontWeight: FontWeight.bold)),
//
//                               TextSpan(
//                                 text: ' %',
//                                 style: styles.worningTextStyle,),
//                             ],
//                           ),
//                         ),),
//                     ],
//                   ),
//                   // Добавьте другие строки или ячейки по мере необходимости
//                 ],
//               );
//             },
//           ),
//         );
//       },
//           error: (_,__) => const Placeholder(),
//           loading: ()=> const ProgressMini());
//     },
//   );
// }
