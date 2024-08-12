import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';

class ObjectsScreen extends ConsumerStatefulWidget {
  static const String routeName = "objectsScreen";
  const ObjectsScreen({super.key});

  @override
  ObjectsScreenState createState() => ObjectsScreenState();
}

class ObjectsScreenState extends ConsumerState<ObjectsScreen> {
  @override
  Widget build(BuildContext context) {

    print(ref.watch(allPositionListProvider));
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
