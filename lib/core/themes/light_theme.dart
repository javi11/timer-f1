import 'package:flutter/material.dart';

var lightThemeData = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.indigo),
      actionsIconTheme: IconThemeData(color: Colors.indigo),
    ),
    textTheme: TextTheme(
      bodyText2: TextStyle(
        color: Colors.black,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      unselectedItemColor: Colors.indigo.shade100,
      backgroundColor: Colors.indigo,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.grey.shade300,
    ));
