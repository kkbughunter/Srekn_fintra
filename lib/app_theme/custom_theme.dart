import 'package:flutter/material.dart';

class CustomTheme {

  static TextStyle h1([Color color = Colors.black]) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: color, 
    );
  }
}
