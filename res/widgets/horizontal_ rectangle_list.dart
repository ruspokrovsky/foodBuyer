import 'dart:io';
import 'dart:math';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ya_bazaar/res/models/circle_horizontal_list_model.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/res/models/user_model.dart';
import 'package:ya_bazaar/res/utils.dart';
import 'package:ya_bazaar/res/widgets/cached_network_image.dart';
import 'package:ya_bazaar/res/widgets/rich_text_list.dart';

class RectangleHorizontalList extends ConsumerWidget {
  final List<UserModel> rootUsersList;
  final Function onTapElement;
  final Function? onDoubleTapElement;
  final double? height;
  final bool? isAnimate;
  final bool? isSubContent;
  final Color? textColor;
  final int? selectedIndex;

  const RectangleHorizontalList({
    super.key,
    required this.rootUsersList,
    required this.onTapElement,
    this.onDoubleTapElement,
    this.height = 120.0,
    this.isAnimate = false,
    this.isSubContent = false,
    this.textColor,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        //shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: rootUsersList.length,
        itemBuilder: (context, index) {
          Utils utils = Utils();
          bool isSelected = (selectedIndex == index) ? true : false;
          bool isSelected2 = rootUsersList[index].isSelectedElement!;
          String limit = '';
          String dept = '';
          String limitRemainder = '';
          num limitSum = rootUsersList[index].limit!;

          if(limitSum == 0){
            limit = '#';
            dept = '#';
            limitRemainder = '#';
          }
          else {
            limit = utils.numberParse(value: rootUsersList[index].limit!);
            dept = utils.numberParse(value: rootUsersList[index].debt??0);
            limitRemainder = utils.numberParse(value: rootUsersList[index].limitRemainder??0);
          }


          return Container(
            margin: const EdgeInsets.only(left: 6.0),
            decoration: isSubContent!
              ?
            BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                    width: 1,
                    color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)))
            : null,
            child: InkWell(
              //highlightColor: Theme.of(context).primaryColorDark,
              //splashColor: Theme.of(context).primaryColorDark,
              customBorder: const CircleBorder(),
              onTap: () => onTapElement(rootUsersList[index], index),
              onDoubleTap: () => onDoubleTapElement!(rootUsersList[index]),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Stack(children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: isSelected2 || isSelected
                            ? const EdgeInsets.all(2.0)
                            : const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 3,
                                color: isSelected2 || isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent)),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50.0)),
                          child: CachedNetworkImg(
                              imageUrl: rootUsersList[index].profilePhoto,
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover),
                        ),
                      ),
                      Text(
                        rootUsersList[index].name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (rootUsersList[index].discountPercent != null ||
                          rootUsersList[index].discountPercent == 0)
                      if (isSubContent!)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'Кешбэк: ',
                                    data: rootUsersList[index].discountPercent.toString(),
                                    postTitle: '  %')),
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'Лимит всего: ',
                                    data: limit.toString(),
                                    postTitle: '')),
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'Лимит остатаок: ',
                                    data: limitRemainder.toString(),
                                    postTitle: '')),
                            RichSpanText(
                                spanText: SnapTextModel(
                                    title: 'Задолжность: ',
                                    data: dept.toString(),
                                    postTitle: '')),


                          ],
                        ),
                    ],
                  ),
                  // Positioned(
                  //   //left: isSelected? 15.0 : 0.0,
                  //   //top: 0.0,
                  //   right: 0.0,
                  //   bottom: 0.0,
                  //   child: ClipRRect(
                  //       borderRadius: const BorderRadius.all(Radius.circular(50)),
                  //       child: AvatarGlow(
                  //         animate: rootUsersList[index].isSelectedElement!
                  //             ? true
                  //             : false,
                  //         glowRadiusFactor: 50.0,
                  //         child: const Icon(
                  //           Icons.shopping_cart_outlined,
                  //           color: Colors.deepOrange,
                  //         ),
                  //       )),
                  // ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
