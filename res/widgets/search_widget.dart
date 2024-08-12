import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:ya_bazaar/theme.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? categoryPressed;
  final VoidCallback? onTapBack;
  final VoidCallback? onTapJoinPosition;
  final VoidCallback? onTapCart;
  final bool? isAvatarGlow;
  final bool? isAdditionalBtn;

  const SearchWidget({
    super.key,
    required this.text,
    required this.onChanged,
    required this.hintText,
    this.categoryPressed,
    this.onTapBack,
    this.onTapJoinPosition,
    this.onTapCart,
    this.isAvatarGlow,
    this.isAdditionalBtn,
  });

  @override
  SearchWidgetState createState() => SearchWidgetState();
}

class SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppStyles styles = AppStyles.appStyle(context);
    //const styleActive = TextStyle(color: Colors.black);
    TextStyle styleActive = TextStyle(color: styles.cursorColor);
    //const styleHint = TextStyle(color: Colors.black54);
    TextStyle styleHint = TextStyle(color: styles.cursorColor);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 50,
      //margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: styles.searchBackgroundColor,
        border: Border.all(color: Theme.of(context).primaryColor,width: 2.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: controller,
        showCursor: true,
        cursorColor: style.color,
        //cursorWidth: 2.0,
        // cursorHeight:2.0,
        decoration: InputDecoration(

          icon: widget.isAdditionalBtn!
            ? GestureDetector(
              onTap: widget.onTapBack,
              child: Icon(Icons.arrow_back_ios_new, color: style.color))
          :
          null,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.search,),
              if(widget.isAdditionalBtn!)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //Icon(Icons.search, color: style.color),
                  IconButton(
                    tooltip: 'Показать все',
                      onPressed: widget.onTapJoinPosition,
                      icon: Icon(Icons.join_inner, color: style.color)),
                  IconButton(
                      tooltip: 'Фильтр по категориям',
                      onPressed: widget.categoryPressed,
                  icon: Icon(Icons.category, color: style.color)),


                  AvatarGlow(
                    //startDelay: const Duration(milliseconds: 1000),
                    glowColor: Colors.white ,
                    glowShape: BoxShape.circle,
                    animate: widget.isAvatarGlow ?? false,
                    curve: Curves.fastOutSlowIn,
                    child: Center(
                      child: IconButton(
                          tooltip: 'Корзина',
                          onPressed: widget.onTapCart,
                          icon: Icon(Icons.shopping_cart_outlined,

                              color: widget.isAvatarGlow??false
                                  ?
                              Colors.deepOrange
                                  :
                              style.color)),
                    ),
                  ),

                  // AvatarGlow(
                  //   //endRadius: 60.0,
                  //   animate: widget.isAvatarGlow?? false,
                  //   glowColor: Colors.deepOrange,
                  //   duration: const Duration(milliseconds: 2000),
                  //   child: Center(
                  //     child: IconButton(
                  //         tooltip: 'Корзина',
                  //         onPressed: widget.onTapCart,
                  //         icon: Icon(Icons.shopping_cart_outlined,
                  //
                  //             color: widget.isAvatarGlow??false
                  //             ?
                  //             Colors.deepOrange
                  //             :
                  //             style.color)),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          hintText: widget.hintText,
          hintStyle: style,
          border: InputBorder.none,
        ),
        style: style,
        onChanged: widget.onChanged,
      ),
    );
  }
}


