import 'package:flutter/material.dart';

class FAButton extends StatelessWidget {
  final String heroTag;
  final VoidCallback onPressed;
  final Widget fabChild;
  final Color? backgroundColor;
  const FAButton({
    super.key,
    required this.heroTag,
    required this.onPressed,
    required this.fabChild,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      shape: const CircleBorder(),
      child: fabChild,

    );
  }
}
