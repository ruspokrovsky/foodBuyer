import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:ya_bazaar/theme.dart';

class LocalSwitch extends StatelessWidget {
  final bool value;
  final String activeText;
  final String inactiveText;
  final Function onToggle;

  const LocalSwitch({
    super.key,
    required this.value,
    required this.activeText,
    required this.inactiveText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    return Container(
      decoration: styles.switchBoxDecoration,
      child: FlutterSwitch(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        toggleSize: 30.0,
        value: value,
        borderRadius: 50.0,
        showOnOff: true,
        activeText: activeText,
        inactiveText: inactiveText,
        activeTextColor: styles.switchActiveTextColor!,
        inactiveTextColor: styles.switchInactiveTextColor!,
        activeColor: Colors.transparent,
        inactiveColor: Colors.transparent,
        activeIcon: Icon(
          Icons.arrow_back_ios,
          color: styles.switchActiveTextColor,
        ),
        inactiveIcon: Icon(
          Icons.arrow_forward_ios,
          color: styles.switchInactiveTextColor,
        ),
        inactiveToggleColor: Colors.transparent,
        activeToggleColor: Colors.transparent,
        onToggle: (val) => onToggle(val),
      ),
    );
  }
}
