import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ya_bazaar/generated/locale_keys.g.dart';

class EditText extends StatelessWidget {
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final VoidCallback? onTapEditText;
  final String labelText;
  final ValueKey? textEditingKey;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final double? borderRadius;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final IconButton? suffixIconBtn;
  final FocusNode? focusNode;
  const EditText({super.key,
    this.textInputType = TextInputType.text,
    this.onTapEditText,
    required this.labelText,
    this.controller,
    this.textEditingKey,
    this.onChanged,
    this.maxLines = 1,
    this.borderRadius = 50,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.suffixIconBtn,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      autofocus: false,
      focusNode: focusNode,
      showCursor: true,
      controller: controller,
      key: textEditingKey,
      keyboardType: textInputType,
      enableInteractiveSelection: false,
      maxLines: maxLines,
      cursorColor: Theme.of(context).primaryColor,
      textAlign: textAlign ?? TextAlign.start,
      style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
          suffixIcon: suffixIconBtn,
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.labelLarge,
          contentPadding: const EdgeInsets.all(8),
          border: OutlineInputBorder(
            borderRadius:  BorderRadius.all(
              Radius.circular(borderRadius!),
            ),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:  BorderRadius.all(
                Radius.circular(borderRadius!)),
            borderSide: const BorderSide(color: Colors.grey),

          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:  BorderRadius.all(
                Radius.circular(borderRadius!)),
            borderSide: const BorderSide(color: Colors.grey),

          )
      ),
      onTap: onTapEditText,
      onChanged: onChanged!,
    );
  }
}
