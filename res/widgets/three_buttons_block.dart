import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/widgets/single_button.dart';

class ThreeButtonsBlock extends StatelessWidget {
  final String positiveText;
  final VoidCallback positiveClick;
  final String neutralText;
  final VoidCallback neutralClick;
  final String negativeText;
  final VoidCallback negativeClick;

  const ThreeButtonsBlock({
    super.key,
    required this.positiveText,
    required this.positiveClick,
    required this.neutralText,
    required this.neutralClick,
    required this.negativeText,
    required this.negativeClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SingleButton(title: positiveText, onPressed: positiveClick),
        SingleButton(title: neutralText, onPressed: neutralClick),
        SingleButton(title: negativeText, onPressed: negativeClick),
      ],
    );
  }
}
