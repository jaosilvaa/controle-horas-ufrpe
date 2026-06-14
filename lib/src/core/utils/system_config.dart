import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:controle_horas/src/core/theme/app_colors.dart';

Future<void> prepareSystemUI() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
}

void updateSystemUI(ThemeMode mode) {
  final isDark = mode == ThemeMode.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          isDark ? AppColors.darkScaffold : AppColors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor:
          isDark ? AppColors.darkScaffold : AppColors.white,
    ),
  );
}
