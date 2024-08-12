import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

final ThemeData kLightTheme = ThemeData.light().copyWith(
    primaryColorDark: const Color(0xff7200ca),
    primaryColor: const Color(0xffaa00ff),
    primaryColorLight: const Color(0xffe254ff),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Color(0xffaa00ff),
      ),

      headlineMedium:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),

      headlineSmall: TextStyle(color: Colors.grey),

      bodyLarge: TextStyle(color: Colors.black87),

      //стандартный текстовый стиль
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black87),

      labelLarge: TextStyle(
        color: Color(0xffaa00ff),
      ),
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xff7200ca),
      elevation: 0.0,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),

    scaffoldBackgroundColor: Colors.white,

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
    ));

final ThemeData kDarkTheme = ThemeData.dark().copyWith(
  //primaryColor: Colors.white,
  //primaryColorDark: Colors.white,
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    color: Color.fromRGBO(5, 17, 29, 1),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color.fromRGBO(132, 157, 187, 1),
    elevation: 0.0,
  ),

  scaffoldBackgroundColor: const Color.fromRGBO(5, 17, 29, 1),

  primaryColorDark: const Color.fromRGBO(22, 35, 54, 1),
  primaryColor: const Color.fromRGBO(132, 157, 187, 1),
  //primaryColor: const Color.fromRGBO(132, 157, 187, 1),
  primaryColorLight: const Color.fromRGBO(133, 178, 232, 1),
);



//activeTextColor: Theme.of(context).primaryColorDark,
//inactiveTextColor: Theme.of(context).primaryColorDark,

class AppStyles {
  Color? testColor;
  Color? sideColor;
  Color? flexBackgroundColor;
  Color? chipBackgroundColor;
  Color? chip2BackgroundColor;
  Color? glowColor;
  Color? glowColorStop;
  Color? searchBackgroundColor;
  Color? switchActiveTextColor;
  Color? switchInactiveTextColor;
  Color? qrScaffoldBackgroundColor;
  Color? cursorColor;
  TextStyle? addToCartTitleStyle;
  TextStyle? addToCartPriceStyle;
  TextStyle? addToCartEditTextStyle;
  TextStyle? cartItemTitleStyle;
  TextStyle? motionTextStyle;
  TextStyle? appBarTitleTextStyle;
  TextStyle? appBarSubTitleTextStyle;
  TextStyle? headerTitleTextStyle;
  TextStyle? smalTitleTextStyle;
  TextStyle? worningTextStyle;
  TextStyle? calendarMarkerTextStyle;
  TextStyle? rich1TextStyle;
  CalendarStyle? calendarStyle;
  HeaderStyle? calendarHeaderStyle;
  DaysOfWeekStyle? daysOfWeekStyle;
  ButtonStyle? elevatedButtonStyle;
  BoxDecoration? stadiumBorder;
  BoxDecoration? calendarMarkerDecoration;
  BoxDecoration? positionBoxDecoration;
  BoxDecoration? switchBoxDecoration;
  BoxDecoration? cartQtyBoxDecoration;

  AppStyles({
    this.testColor,
    this.sideColor,
    this.flexBackgroundColor,
    this.chipBackgroundColor,
    this.chip2BackgroundColor,
    this.glowColor,
    this.glowColorStop,
    this.searchBackgroundColor,
    this.switchActiveTextColor,
    this.switchInactiveTextColor,
    this.qrScaffoldBackgroundColor,
    this.cursorColor,
    this.addToCartTitleStyle,
    this.addToCartPriceStyle,
    this.addToCartEditTextStyle,
    this.cartItemTitleStyle,
    this.motionTextStyle,
    this.appBarTitleTextStyle,
    this.appBarSubTitleTextStyle,
    this.headerTitleTextStyle,
    this.smalTitleTextStyle,
    this.worningTextStyle,
    this.calendarMarkerTextStyle,
    this.rich1TextStyle,
    this.calendarStyle,
    this.calendarHeaderStyle,
    this.daysOfWeekStyle,
    this.elevatedButtonStyle,
    this.stadiumBorder,
    this.calendarMarkerDecoration,
    this.positionBoxDecoration,
    this.switchBoxDecoration,
    this.cartQtyBoxDecoration,
  });

  static appStyle(BuildContext context) {
    Color color = const Color.fromRGBO(5, 17, 29, 1);
    Color color2 = const Color.fromRGBO(22, 35, 54, 1);
    Color color3 = const Color.fromRGBO(132, 157, 187, 1);
    Color color4 = const Color.fromRGBO(133, 178, 232, 1);
    Color color5 = const Color.fromRGBO(255, 251, 230, 1);

    if (AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light) {
      return AppStyles(
        testColor: Colors.deepOrange,
        flexBackgroundColor: color5,
        chipBackgroundColor: Colors.grey,
        glowColor: Theme.of(context).primaryColorLight,
        glowColorStop: Colors.white,
        chip2BackgroundColor: Colors.black38,
        searchBackgroundColor: Colors.white,
        switchActiveTextColor: Theme.of(context).primaryColor,
        switchInactiveTextColor: Theme.of(context).primaryColor,
        qrScaffoldBackgroundColor: color3,
        sideColor: Colors.grey,
        cursorColor: Colors.black,

        addToCartTitleStyle: const TextStyle(
          fontSize: 18.0,
          color: Colors.black54,
        ),
        cartItemTitleStyle: const TextStyle(
          fontSize: 22.0,
          color: Colors.black54,
        ),
        addToCartPriceStyle: const TextStyle(
          fontSize: 18.0,
          color: Colors.black54,
        ),
        addToCartEditTextStyle: const TextStyle(
          fontSize: 18.0,
          color: Colors.black54,
        ),
        worningTextStyle: const TextStyle(
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
          color: Colors.black54,
        ),
        motionTextStyle: const TextStyle(
            fontSize: 22.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic),
        appBarTitleTextStyle: TextStyle(
          fontSize: 18.0,
          color: color5,
          fontWeight: FontWeight.bold,
        ),
        appBarSubTitleTextStyle: TextStyle(
          fontSize: 16.0,
          color: color5,
          //fontWeight: FontWeight.bold,
        ),
        headerTitleTextStyle: const TextStyle(
          fontSize: 22.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        smalTitleTextStyle: TextStyle(
          fontSize: 16.0,
          color: color5,
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
//стили текущего дня
          //todayTextStyle: const TextStyle(color: Colors.red),
//стили дней
          //defaultTextStyle: const TextStyle(color: Colors.red),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            shape: BoxShape.circle,
          ),
        ),
        calendarHeaderStyle: const HeaderStyle(
            //titleTextStyle: TextStyle(color: Colors.red),
            //leftChevronIcon: Icon(Icons.chevron_left, color: Colors.red,),
            //rightChevronIcon: Icon(Icons.chevron_right, color: Colors.red,),
            formatButtonVisible: false,
            titleCentered: true),
        daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Theme.of(context).primaryColor),
        weekendStyle: const TextStyle(color: Colors.deepOrange),),
        elevatedButtonStyle: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        calendarMarkerDecoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        calendarMarkerTextStyle: TextStyle(
          //fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor),

        positionBoxDecoration: BoxDecoration(
            border: Border.all(
                width: 2.0,
                color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(12.0))),

        rich1TextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),

        switchBoxDecoration: BoxDecoration(
          border: Border.all(width: 1.0, color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(50),
        ),
        cartQtyBoxDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(color: Theme.of(context).primaryColor),
            color: Colors.white),



      );
    }

    else

    {
      return AppStyles(
        testColor: Colors.green,
        flexBackgroundColor: color2,
        chipBackgroundColor: color,
        glowColor: Colors.white,
        glowColorStop: const Color(0xff7200ca),
        chip2BackgroundColor: Colors.black38,
        searchBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        switchActiveTextColor: color4,
        switchInactiveTextColor: color4,
        qrScaffoldBackgroundColor: color3,
        sideColor: Colors.grey,
        cursorColor: color5,


        appBarTitleTextStyle: TextStyle(
          fontSize: 18.0,
          color: color5,
          fontWeight: FontWeight.bold,
        ),
        appBarSubTitleTextStyle: TextStyle(
          fontSize: 16.0,
          color: color5,
          //fontWeight: FontWeight.bold,
        ),

        addToCartTitleStyle: TextStyle(
          fontSize: 18.0,
          color: color4,
        ),
        addToCartPriceStyle: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
        addToCartEditTextStyle: const TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
        motionTextStyle: const TextStyle(
            fontSize: 22.0,
            color: Color.fromRGBO(133, 178, 232, 1),
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
//стили текущего дня
          //todayTextStyle: const TextStyle(color: Colors.red),
//стили дней
          defaultTextStyle: TextStyle(color: color4),
            weekendTextStyle:TextStyle(color: color4),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            shape: BoxShape.circle,
          ),
        ),
        calendarHeaderStyle: HeaderStyle(
            titleTextStyle: TextStyle(color: color4),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: color4,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: color4,
            ),
            formatButtonVisible: false,
            titleCentered: true),
        daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Color(0xffe254ff)),
            weekendStyle: TextStyle(color: Colors.deepOrangeAccent),),
        elevatedButtonStyle: ElevatedButton.styleFrom(
          backgroundColor: color2,
          shape: const StadiumBorder(),
        ),
        calendarMarkerDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),

        calendarMarkerTextStyle: const TextStyle(
          //fontWeight: FontWeight.bold,
         color: Colors.white),

        positionBoxDecoration: BoxDecoration(
            border: Border.all(
                width: 1.0,
                color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(12.0))),

        rich1TextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),

        switchBoxDecoration: BoxDecoration(
          border: Border.all(width: 1.0, color: color4),
          borderRadius: BorderRadius.circular(50),
        ),

        cartQtyBoxDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(color: Theme.of(context).primaryColor),
            color: color),



      );
    }
  }
}
