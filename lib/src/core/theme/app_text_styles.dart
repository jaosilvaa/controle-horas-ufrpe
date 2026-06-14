import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const TextStyle headline1 = TextStyle(fontSize: 32, fontWeight: bold);
  static const TextStyle headline2 = TextStyle(fontSize: 28, fontWeight: bold);
  static const TextStyle headline3 = TextStyle(fontSize: 24, fontWeight: semiBold);
  static const TextStyle headline4 = TextStyle(fontSize: 20, fontWeight: semiBold);
  static const TextStyle headline5 = TextStyle(fontSize: 18, fontWeight: semiBold);
  static const TextStyle headline6 = TextStyle(fontSize: 16, fontWeight: medium);

  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: regular);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: regular);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: regular);

  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: medium);
  static const TextStyle labelMedium = TextStyle(fontSize: 13, fontWeight: medium);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: medium);
}
