import 'package:flutter/material.dart';

class AppThemeState extends ChangeNotifier {
  var isDarkModeEnabled = false;
  void setLightTheme() {
    isDarkModeEnabled = false;
    notifyListeners();
  }

  void setDarkTheme() {
    isDarkModeEnabled = true;
    notifyListeners();
  }
}
