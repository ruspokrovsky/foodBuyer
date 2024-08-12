import 'package:flutter/material.dart';
import 'package:ya_bazaar/theme.dart';

class ChipButton extends StatelessWidget {
  final String lable;
  final Icon? avatar;
  final Color? color;
  final VoidCallback onTap;

  const ChipButton({super.key,
    required this.lable,
    this.avatar,
    this.color,
    required this.onTap,

  });

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        //side: const BorderSide(width: 0,color: Colors.grey),
        shape: const StadiumBorder(side: BorderSide(color: Colors.transparent),),
        backgroundColor: color ?? styles.chipBackgroundColor,
        labelPadding: const EdgeInsets.all(2.0),
        //padding: const EdgeInsets.all(5.0),
        label: Text(lable,
          style: Theme.of(context).textTheme.titleSmall,),
        avatar: avatar??avatar,
      ),
    );
  }
}
