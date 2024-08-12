import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class MapsSearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback categoryPressed;
  final VoidCallback onTapBack;
  final VoidCallback onTapCart;
  final bool isAvatarGlow;

  const MapsSearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
    required this.categoryPressed,
    required this.onTapBack,
    required this.onTapCart,
    required this.isAvatarGlow,
  }) : super(key: key);

  @override
  MapsSearchWidgetState createState() => MapsSearchWidgetState();
}

class MapsSearchWidgetState extends State<MapsSearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const styleActive = TextStyle(color: Colors.black);
    const styleHint = TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return TextField(
      controller: controller,
      cursorColor: Theme.of(context).primaryColor,

      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(3.0),
        suffixIcon:
        controller.text.isNotEmpty
        ?
        GestureDetector(
          child: Icon(
            Icons.close,
              color: style.color
          ),
          onTap: () {
            controller.clear();
            widget.onChanged('');
            FocusScope.of(context).requestFocus(FocusNode());
          },
        )
        :
        Icon(Icons.search, color: style.color),
        //hintText: widget.hintText,

        labelText: widget.hintText,
        labelStyle: Theme.of(context).textTheme.labelLarge,

        hintStyle: style,
        border: InputBorder.none,
      ),
      style: style,
      onChanged: widget.onChanged,
    );
  }
}


