import 'package:flutter/material.dart';
import 'package:ya_bazaar/theme.dart';

class SingleButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const SingleButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: styles.elevatedButtonStyle,
      child: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).primaryColor),
      ),
    );
  }
}
