import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressMini extends StatelessWidget {
  final double? radius;
  const ProgressMini({Key? key, this.radius = 30}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CupertinoActivityIndicator(
          radius: radius!,
          color: Theme.of(context).primaryColor,
        ));
  }
}

class ProgressMiniSplash extends StatelessWidget {
  final double? radius;
  const ProgressMiniSplash({Key? key, this.radius = 30}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
          child: CupertinoActivityIndicator(
            radius: radius!,
            color: Theme.of(context).primaryColor,
          )),
    );
  }
}

