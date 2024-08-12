import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';

class TwoButtonsBlock extends StatelessWidget {
  final String positiveText;
  final String negativeText;
  final VoidCallback positiveClick;
  final VoidCallback negativeClick;

  const TwoButtonsBlock({
    super.key,
    required this.positiveText,
    required this.positiveClick,
    required this.negativeText,
    required this.negativeClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: SingleButton(title: positiveText, onPressed: positiveClick)

        ),
        const SizedBox(width: 8.0,),
        Expanded(
          child: SingleButton(title: negativeText, onPressed: negativeClick)

        )
      ],
    );
  }
}
