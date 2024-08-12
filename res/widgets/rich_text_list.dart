import 'package:flutter/material.dart';
import 'package:ya_bazaar/res/models/navigate_args_model.dart';
import 'package:ya_bazaar/theme.dart';

class RichSpanText extends StatelessWidget {

  final SnapTextModel spanText;

  const RichSpanText({super.key, required this.spanText});



  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return RichText(
      text: TextSpan(
        text: spanText.title,
        style: Theme.of(context).textTheme.bodyMedium,
        children: <TextSpan>[
          TextSpan(
            text: spanText.data,
            style: styles.rich1TextStyle,
          ),
          TextSpan(text: spanText.postTitle),
        ],
      ),
    );
  }
}

class RichSpanTextMini extends StatelessWidget {

  final SnapTextModel spanText;

  const RichSpanTextMini({super.key, required this.spanText});



  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return RichText(
      text: TextSpan(
        text: spanText.title,
        style: Theme.of(context).textTheme.bodySmall,
        children: <TextSpan>[
          TextSpan(
            text: spanText.data,
            style: styles.rich1TextStyle!,
          ),
          TextSpan(text: spanText.postTitle),
        ],
      ),
    );
  }
}
