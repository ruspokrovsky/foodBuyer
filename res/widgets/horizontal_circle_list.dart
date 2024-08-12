import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/models/circle_horizontal_list_model.dart';

class CircleHorizontalList extends ConsumerWidget {
  final List<CircleHorizontalListModel> cHorizontalListModel;
  final Function onTapElement;
  final Function? onDoubleTapElement;
  final Function? onTapPopUpMenu;
  final double? height;

  const CircleHorizontalList({
    super.key,
    required this.cHorizontalListModel,
    required this.onTapElement,
    this.onDoubleTapElement,
    this.onTapPopUpMenu,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: cHorizontalListModel.length,
        itemBuilder: (context, index) {
          return InkWell(
            highlightColor: Theme.of(context).primaryColorLight,
            splashColor: Theme.of(context).primaryColor,
            customBorder: const CircleBorder(),
            onTap: () => onTapElement(cHorizontalListModel[index].id,
                cHorizontalListModel[index].name),
            onDoubleTap: () => onDoubleTapElement!(
                cHorizontalListModel[index].id,
                cHorizontalListModel[index].name),
            child: Stack(
                children: [
              Center(
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  margin: const EdgeInsets.all(2.5),
                  // decoration: BoxDecoration(
                  //   // border: Border.all(
                  //   //   width: 0.8,
                  //   //   color: Theme.of(context).primaryColorDark,
                  //   // ),
                  //   //borderRadius: BorderRadius.circular(50),
                  //   shape: BoxShape.circle,
                  // ),
                  child: ArcText(
                      //stretchAngle: 5.0,
                      radius: 30,
                      text: cHorizontalListModel[index].name,
                      textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic),
                      startAngle: -pi / 2.2,
                      startAngleAlignment: StartAngleAlignment.start,
                      placement: Placement.outside,
                      direction: Direction.clockwise),
                ),
              ),
              Positioned(
                left: 0.0,
                top: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Center(
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      child: SvgPicture.asset(
                        File('assets/icons/povar.svg').path,
                        //color: imgColor,
                      ),

                      // Image.asset(
                      //   'assets/images/ГАСТРОНОМ.png',
                      //   fit: BoxFit.cover,
                      // )
                    ),
                  ),
                ),
              ),
              if (ref.watch(currentUserProvider).userStatus == 'owner')
                Positioned(
                  left: 0.0,
                  //top: 0.0,
                  //right: 0.0,
                  bottom: 0.0,
                  child: _popUpMenuBtn(
                    context: context,
                    onSelected: (int pressedIndex)
                    => onTapPopUpMenu!(pressedIndex,cHorizontalListModel[index].id,cHorizontalListModel[index].name),
                  ),
                ),
            ]),
          );
        },
      ),
    );
  }
}

Widget _popUpMenuBtn({
  required BuildContext context,
  required Function onSelected,
}) {
  return PopupMenuButton<int>(
      icon: Icon(
        Icons.add_circle_outline,
        color: Theme.of(context).primaryColor,
      ),
      onSelected: (int itemIndex) => onSelected(itemIndex),
      itemBuilder: (BuildContext context) => [
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 0,
                child: const Text('Добавить категорию')),
            PopupMenuItem(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                value: 1,
                child: const Text('Добавить подкатегорию')),
          ]);
}
