import 'package:flutter/material.dart';
import 'package:loginlogoutbasic/themes/dark_mode.dart';
import 'package:loginlogoutbasic/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier{
  // light mode as default
  ThemeData _themeData = lightMode;

  // get theme
  ThemeData get themeData => _themeData;

  // determines if it is in dark mode
  bool get isDarkMode => _themeData == darkMode;

  // set theme
  set themeData(ThemeData themeData){
    _themeData = themeData;

    // update ui
    notifyListeners();
  }

  // toggle theme
  void toggleTheme() {
    if(_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}