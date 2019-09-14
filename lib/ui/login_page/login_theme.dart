import 'dart:ui';
import 'package:flutter/cupertino.dart';

class Colors {
  const Colors();
  
  // static const Color loginGradienStart = const Color(0xFFf1f2b5);
  // static const Color loginGradienEnd = const Color(0xFF135058);
  static const Color loginGradienStart = const Color(0xFFbdc3c7);
  static const Color loginGradienEnd = const Color(0xFF2c3e50);

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradienStart,loginGradienEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

