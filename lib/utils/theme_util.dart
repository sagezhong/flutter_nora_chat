import 'package:flutter/material.dart';

class ThemeUtil {

  static ThemeData getDarkTheme() {
    return ThemeData(
      primaryColor: Colors.grey[850],
      accentColor: Colors.white,
      brightness: Brightness.dark,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }
  static ThemeData getLightTheme() {
    return ThemeData(
      primaryColor: Colors.white,
      accentColor: Colors.black87,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black87)
    );
  }
}